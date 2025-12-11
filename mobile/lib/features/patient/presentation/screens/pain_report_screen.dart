import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/aura_app_bar.dart';

class PainReportScreen extends StatefulWidget {
  const PainReportScreen({super.key});

  @override
  State<PainReportScreen> createState() => _PainReportScreenState();
}

class _PainReportScreenState extends State<PainReportScreen> {
  double _painLevel = 0;

  Color _getPainColor(double level) {
    if (level < 4) return AppColors.success;
    if (level < 7) return AppColors.warning;
    return AppColors.error;
  }

  String _getPainLabel(double level) {
    if (level == 0) return "No Pain";
    if (level < 4) return "Mild";
    if (level < 7) return "Moderate";
    if (level < 9) return "Severe";
    return "Excruciating";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuraAppBar(title: "Report Pain"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("How much pain are you in?", style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text("Slide to adjust level", style: AppTypography.bodyMedium),
            const SizedBox(height: 48),

            // Pain Visualization Circle
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPainColor(_painLevel).withOpacity(0.2),
                border: Border.all(color: _getPainColor(_painLevel), width: 4),
              ),
              child: Center(
                child: Text(
                  _painLevel.toInt().toString(),
                  style: AppTypography.headlineLarge.copyWith(color: _getPainColor(_painLevel), fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getPainLabel(_painLevel),
              style: AppTypography.titleLarge.copyWith(color: _getPainColor(_painLevel)),
            ),

            const SizedBox(height: 48),

            // Slider
            CupertinoSlider(
              value: _painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: _getPainColor(_painLevel),
              onChanged: (val) => setState(() => _painLevel = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0", style: AppTypography.bodySmall),
                Text("10", style: AppTypography.bodySmall),
              ],
            ),

            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: () async {
                  try {
                    // Patient ID 1 hardcoded for demo
                    await ApiService().reportPain(1, _painLevel.toInt());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pain report sent to your doctor."))
                      );
                      context.pop();
                    }
                  } catch (e) {
                     if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error)
                      );
                    }
                  }
                },
                child: const Text("Submit Report"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
