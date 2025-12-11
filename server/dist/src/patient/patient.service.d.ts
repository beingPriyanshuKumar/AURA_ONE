import { PrismaService } from '../prisma/prisma.service';
export declare class PatientService {
    private prisma;
    constructor(prisma: PrismaService);
    getDigitalTwin(id: number): Promise<{
        metadata: {
            name: string;
            mrn: string;
            bed: string;
            ward: string;
        };
        current_state: {
            heart_rate: any;
            blood_pressure: any;
            spo2: any;
            risk_score: number;
            pain_level: number;
            pain_reported_at: Date;
        };
        risk_predictions: {
            hypotension_6h: number;
            cardiac_event_24h: number;
            deterioration_prob: number;
        };
        trend_summary: string[];
    }>;
    private getLatestVital;
    createPatient(data: any): Promise<{
        id: number;
        userId: number;
        mrn: string;
        dob: Date;
        gender: string;
        bed: string | null;
        ward: string | null;
        riskScore: number | null;
        diagnosis: string | null;
        painLevel: number | null;
        painReportedAt: Date | null;
        latestVitals: import("@prisma/client/runtime/library").JsonValue | null;
        createdAt: Date;
        updatedAt: Date;
    }>;
    findAll(): Promise<({
        user: {
            id: number;
            createdAt: Date;
            updatedAt: Date;
            email: string;
            password: string;
            name: string;
            role: import(".prisma/client").$Enums.Role;
        };
    } & {
        id: number;
        userId: number;
        mrn: string;
        dob: Date;
        gender: string;
        bed: string | null;
        ward: string | null;
        riskScore: number | null;
        diagnosis: string | null;
        painLevel: number | null;
        painReportedAt: Date | null;
        latestVitals: import("@prisma/client/runtime/library").JsonValue | null;
        createdAt: Date;
        updatedAt: Date;
    })[]>;
    reportPain(patientId: number, level: number): Promise<{
        id: number;
        userId: number;
        mrn: string;
        dob: Date;
        gender: string;
        bed: string | null;
        ward: string | null;
        riskScore: number | null;
        diagnosis: string | null;
        painLevel: number | null;
        painReportedAt: Date | null;
        latestVitals: import("@prisma/client/runtime/library").JsonValue | null;
        createdAt: Date;
        updatedAt: Date;
    }>;
}
