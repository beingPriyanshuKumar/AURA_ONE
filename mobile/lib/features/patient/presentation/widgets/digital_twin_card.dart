import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class DigitalTwinCard extends StatefulWidget {
  final double riskScore;

  const DigitalTwinCard({super.key, required this.riskScore});

  @override
  State<DigitalTwinCard> createState() => _DigitalTwinCardState();
}

class _DigitalTwinCardState extends State<DigitalTwinCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceHighlight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Grid / Tech Effect
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          
          // "3D" Model Placeholder with Breath Animation
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.person_crop_circle_fill,
                    size: 120,
                    color: _getRiskColor(widget.riskScore).withOpacity(0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.riskScore > 70 ? "Status: Critical" : "Status: Stable",
                    style: AppTypography.titleMedium.copyWith(
                      color: _getRiskColor(widget.riskScore),
                      shadows: [
                        BoxShadow(
                          color: _getRiskColor(widget.riskScore).withOpacity(0.5),
                          blurRadius: 10,
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Risk Score Indicator
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRiskColor(widget.riskScore)),
              ),
              child: Row(
                children: [
                   Icon(CupertinoIcons.heart_fill, size: 14, color: _getRiskColor(widget.riskScore)),
                   const SizedBox(width: 6),
                   Text(
                     "Risk Score: ${widget.riskScore.toInt()}%",
                     style: AppTypography.labelLarge.copyWith(color: _getRiskColor(widget.riskScore)),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(double score) {
    if (score < 30) return AppColors.success;
    if (score < 70) return AppColors.warning;
    return AppColors.error;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
