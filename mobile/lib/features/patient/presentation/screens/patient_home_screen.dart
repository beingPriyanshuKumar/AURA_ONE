import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_fab.dart';
import '../../../../core/widgets/aura_navigation_bar.dart';
import '../../../../services/api_service.dart';
import '../widgets/digital_twin_card.dart';
import '../widgets/vitals_summary_card.dart';
import '../widgets/vitals_graphs.dart';
import '../widgets/vitals_card.dart';
import '../../../../services/health_service.dart';
import '../../../../services/socket_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Request HealthKit access on load
    // Request HealthKit access on load
    HealthService().requestPermissions();
    // Subscribe to Real-time Vitals Room (Patient 1)
    SocketService().subscribePatient(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to extend behind standard navbar area
      appBar: const AuraAppBar(
        title: "My Digital Twin",
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(CupertinoIcons.bell_fill, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        // Hardcoded ID 1 for verified user for now
        future: ApiService().getPatientTwin(1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}", style: AppTypography.bodyMedium.copyWith(color: AppColors.error)));
          }

          final data = snapshot.data!;
          // Default to sane values if null
          final riskScore = (data['risk_score'] ?? 0).toDouble(); 
          final heartRate = data['heart_rate']?.toString() ?? "--";
          final bp = data['blood_pressure']?.toString() ?? "--/--";
          final oxygen = data['oxygen_saturation']?.toString() ?? "--";

          return Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DigitalTwinCard(riskScore: riskScore),
                    const SizedBox(height: 24),
                    
                    // --- HEART RATE ---
                    StreamBuilder<int>(
                      stream: SocketService().vitalsStream.map((d) => d['hr'] as int? ?? 0).distinct(),
                      builder: (context, snap) {
                         final val = (snap.data != null && snap.data! > 0) ? snap.data.toString() : heartRate;
                         return VitalsCard(
                           title: "Heart Rate",
                           value: val,
                           unit: "bpm",
                           icon: CupertinoIcons.heart_fill,
                           color: AppColors.success,
                           graph: SizedBox(
                             height: 150,
                             child: HeartRateGraph(
                               color: AppColors.success,
                               bpmStream: HealthService().heartRateStream,
                               waveStream: SocketService().vitalsStream.map((d) => (d['ecg'] as num?)?.toDouble() ?? 0.0),
                             ),
                           ),
                         );
                      },
                    ),

                    // --- BLOOD PRESSURE ---
                    StreamBuilder<Map>(
                      stream: SocketService().vitalsStream.map((d) => d['bp'] as Map? ?? {}),
                      builder: (context, snap) {
                         final bpMap = snap.data ?? {};
                         final val = (bpMap.isNotEmpty) ? "${bpMap['sys']}/${bpMap['dia']}" : bp;
                         return VitalsCard(
                           title: "Blood Pressure",
                           value: val,
                           unit: "mmHg",
                           icon: CupertinoIcons.waveform_path_ecg,
                           color: AppColors.accent,
                           graph: const SizedBox(
                             height: 150,
                             child: BloodPressureGraph(color: AppColors.accent),
                           ),
                         );
                      },
                    ),

                    // --- OXYGEN SATURATION ---
                    StreamBuilder<int>(
                      stream: SocketService().vitalsStream.map((d) => (d['spo2'] as num?)?.toInt() ?? 0).distinct(),
                      builder: (context, snap) {
                         final val = (snap.data != null && snap.data! > 0) ? snap.data.toString() : oxygen;
                         return VitalsCard(
                           title: "Oxygen Saturation",
                           value: val,
                           unit: "%",
                           icon: CupertinoIcons.drop_fill,
                           color: AppColors.info,
                           graph: SizedBox(
                             height: 150,
                             child: OxygenGraph(
                               color: AppColors.info,
                               waveStream: SocketService().vitalsStream.map((d) => (d['spo2_wave'] as num?)?.toDouble() ?? 0.0),
                             ),
                           ),
                         );
                      },
                    ),

                    const SizedBox(height: 32),
                    
                     GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildFeatureCard(
                          context, 
                          "Scan Meds", 
                          CupertinoIcons.barcode_viewfinder, 
                          AppColors.primary, 
                          '/medication'
                        ),
                        // Keep simple summary cards as well? Maybe redundant now.
                        // Let's replace them with useful actions or keep "Family" link
                         _buildFeatureCard(
                          context, 
                          "Family Access", 
                          CupertinoIcons.person_2_fill, 
                          AppColors.info, 
                          '/family/home' // Or relevant route
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bottom Navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: AuraNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    if (index == 2) {
                      context.push('/navigation');
                    }
                  },
                ),
              ),
            ],
          );
        }
      ),
      floatingActionButton: AuraFAB(
        onPressed: () => context.push('/chat'),
        icon: CupertinoIcons.chat_bubble_2_fill, // More modern bubble
        // label: "AI Assistant", // Removed to fit in dock
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFeatureCard(BuildContext context, String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighlight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.titleMedium),
          ],
        ),
      ),
    );
  }
}
