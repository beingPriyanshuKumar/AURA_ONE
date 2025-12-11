import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayInit,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { PrismaService } from '../prisma/prisma.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class EventsGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  
  // Throttle updates to DB to avoid spam (Map<patientId, lastUpdateTime>)
  private lastUpdate = new Map<number, number>();

  constructor(private prisma: PrismaService) {}

  afterInit(server: Server) {
    console.log('EventsGateway initialized');
  }

  handleConnection(client: Socket, ...args: any[]) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('subscribe.patient')
  handleSubscribePatient(client: Socket, data: { patientId: number }) {
    const room = `patient_${data.patientId}`;
    client.join(room);
    console.log(`Client ${client.id} subscribed to patient ${data.patientId}`);
    return { event: 'subscribed', data: { room } };
  }

  @SubscribeMessage('unsubscribe.patient')
  handleUnsubscribePatient(client: Socket, data: { patientId: number }) {
    const room = `patient_${data.patientId}`;
    client.leave(room);
    console.log(`Client ${client.id} unsubscribed from patient ${data.patientId}`);
    return { event: 'unsubscribed', data: { room } };
  }

  @SubscribeMessage('simulate_vitals')
  async handleSimulateVitals(client: Socket, data: any) {
    // 1. Broadcast to room immediately for live view
    // Ensure we broadcast to the room corresponding to the patient ID in the data
    if (data && data.patientId) {
        this.server.to(`patient_${data.patientId}`).emit('vitals.update', data);

        // 2. Persist to DB (Throttled: e.g. every 5 seconds)
        const now = Date.now();
        const last = this.lastUpdate.get(data.patientId) || 0;
        
        // Save snapshot every 5 seconds to keep "latest known state" fresh in DB
        if (now - last > 5000) {
            this.lastUpdate.set(data.patientId, now);
            try {
                // We use updateMany or simple update. Since we have ID, update is fine.
                // We store the whole data object as 'latestVitals' (JSON)
                await this.prisma.patient.update({
                    where: { id: parseInt(data.patientId) },
                    data: { latestVitals: data }
                });
            } catch (e) {
                console.error(`Failed to persist vitals snapshot for patient ${data.patientId}`, e);
            }
        }
    }
  }
}
