import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/a_app_bar.dart';
import '../../../../core/widgets/a_fab.dart';
import '../../../../core/widgets/a_tab_bar.dart';
import '../../../../services/api_service.dart';
import '../widgets/digital_twin_card.dart';
import '../widgets/vitals_summary_card.dart';
import '../widgets/ecg_graph_widget.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to extend behind standard navbar area
      appBar: const AAppBar(
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
                    
                    Text("Real-Time Telemetry (AURA Live)", style: AppTypography.titleLarge),
                    const SizedBox(height: 12),
                    // Hardcoded Patient ID 1
                    const EcgGraphWidget(patientId: 1),
                    const SizedBox(height: 24),

                    Text("Live Vitals", style: AppTypography.titleLarge),
                    const SizedBox(height: 16),
                    
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
                        VitalsSummaryCard(
                          label: "Heart Rate",
                          value: heartRate,
                          unit: "bpm",
                          icon: CupertinoIcons.heart_fill,
                          color: AppColors.error,
                        ),
                        VitalsSummaryCard(
                          label: "Blood Pressure",
                          value: bp,
                          unit: "mmHg",
                          icon: CupertinoIcons.drop_fill,
                          color: AppColors.accent,
                        ),
                        VitalsSummaryCard(
                          label: "Oxygen Sat",
                          value: oxygen,
                          unit: "%",
                          icon: CupertinoIcons.wind,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bottom Navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: ATabBar(
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
      floatingActionButton: AFAB(
        onPressed: () => context.push('/chat'),
        icon: CupertinoIcons.chat_bubble_text_fill,
        label: "AI Assistant",
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
