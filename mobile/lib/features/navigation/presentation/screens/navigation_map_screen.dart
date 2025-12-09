import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../services/api_service.dart';

class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({super.key});

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  // Hardcoded for demo, normally fetched from API
  List<Map<String, dynamic>> pathNodes = [];
  bool isLoading = false;

  void _findPath() async {
    setState(() => isLoading = true);
    try {
      // Fetch path from Entry (1) to Ward 1 (5)
      final result = await ApiService().getNavigationPath(1, 5);
      setState(() {
        pathNodes = List<Map<String, dynamic>>.from(result['path']);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching path: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Navigation")),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CustomPaint(
                painter: MapPainter(pathNodes: pathNodes),
                size: Size.infinite,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.surfaceHighlight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Room 204", style: AppTypography.headlineMedium),
                Text("Cardiology Ward", style: AppTypography.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _findPath,
                  icon: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.navigation),
                  label: Text(isLoading ? "Calculating..." : "Start Navigation"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> pathNodes;

  MapPainter({required this.pathNodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceHighlight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = 10.0; // Zoom factor

    // Draw Grid (Floor)
    for (double i = -20; i <= 20; i += 5) {
      canvas.drawLine(
        Offset((i * scale) + center.dx, (-20 * scale) + center.dy),
        Offset((i * scale) + center.dx, (20 * scale) + center.dy),
        Paint()..color = Colors.grey.withOpacity(0.1),
      );
      canvas.drawLine(
        Offset((-20 * scale) + center.dx, (i * scale) + center.dy),
        Offset((20 * scale) + center.dx, (i * scale) + center.dy),
        Paint()..color = Colors.grey.withOpacity(0.1),
      );
    }

    // Draw Hardcoded Map Structure (Simulated walls)
    final wallPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4;
    canvas.drawLine(Offset((-10 * scale) + center.dx, (0 * scale) + center.dy), Offset((10 * scale) + center.dx, (0 * scale) + center.dy), wallPaint);


    // Draw Path
    if (pathNodes.isNotEmpty) {
      final pathPaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      // Start
      path.moveTo((pathNodes[0]['x'] as num).toDouble() * scale + center.dx, (pathNodes[0]['y'] as num).toDouble() * scale + center.dy);
      
      for (int i = 1; i < pathNodes.length; i++) {
        path.lineTo((pathNodes[i]['x'] as num).toDouble() * scale + center.dx, (pathNodes[i]['y'] as num).toDouble() * scale + center.dy);
      }
      canvas.drawPath(path, pathPaint);

      // Draw Start/End Points
      canvas.drawCircle(Offset((pathNodes.first['x'] as num).toDouble() * scale + center.dx, (pathNodes.first['y'] as num).toDouble() * scale + center.dy), 8, Paint()..color = AppColors.success);
      canvas.drawCircle(Offset((pathNodes.last['x'] as num).toDouble() * scale + center.dx, (pathNodes.last['y'] as num).toDouble() * scale + center.dy), 8, Paint()..color = AppColors.error);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
