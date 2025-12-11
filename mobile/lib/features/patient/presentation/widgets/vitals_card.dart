import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VitalsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color color;
  final Widget? graph;
  final Widget? action;

  const VitalsCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    required this.color,
    this.graph,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            Color(0xFF252525), 
            AppColors.surface,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.4),
            blurRadius: 24, // Softer, larger shadow
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          // Inner light hint (simulated via outer shadow with negative spread? No, standard Flutter shadow)
          BoxShadow(
            color: color.withOpacity(0.1), // Subtle colored glow matching vital type
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                if (action != null) action!,
              ],
            ),
          ),

          // Value
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 42, 
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 6),
                    Text(unit!, style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Graph
          if (graph != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: graph,
            ),
        ],
      ),
    );
  }
}
