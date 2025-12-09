import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../services/socket_service.dart';
import '../../../../core/theme/app_colors.dart';

class EcgGraphWidget extends StatefulWidget {
  final int patientId;
  const EcgGraphWidget({super.key, required this.patientId});

  @override
  State<EcgGraphWidget> createState() => _EcgGraphWidgetState();
}

class _EcgGraphWidgetState extends State<EcgGraphWidget> {
  final List<double> _dataPoints = [];
  // Store max points to keep graph scrolling. 
  // At 60Hz, 300 points = 5 seconds of data history.
  static const int _maxPoints = 300; 
  StreamSubscription? _subscription;
  
  // Fake data for visual testing if socket fails
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // Subscribe to socket
    SocketService().subscribePatient(widget.patientId);
    
    _subscription = SocketService().vitalsStream.listen((data) {
      if (mounted) {
        if (data['patientId'] == widget.patientId && data['ecg'] != null) {
          _addPoint((data['ecg'] as num).toDouble());
        }
      }
    });

    // Fallback simulation if no backend connection (for review purposes)
    // Uncomment to test UI without backend
    // _startFallbackSimulation();
  }

  void _addPoint(double value) {
    setState(() {
      _dataPoints.add(value);
      if (_dataPoints.length > _maxPoints) {
        _dataPoints.removeAt(0);
      }
    });
  }

  void _startFallbackSimulation() {
     _fallbackTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        double time = DateTime.now().millisecondsSinceEpoch / 1000;
        double y = _simulateECG(time);
        _addPoint(y);
     });
  }

  double _simulateECG(double t) {
     const double cycleDuration = 1.0; 
     double pos = (t % cycleDuration) / cycleDuration;
     if (pos > 0.1 && pos < 0.2) return 1.5; // R-wave spike
     if (pos > 0.2 && pos < 0.25) return -0.5; // S-wave
     return (math.Random().nextDouble() - 0.5) * 0.1; // Noise
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fallbackTimer?.cancel();
    SocketService().unsubscribePatient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: EcgPainter(_dataPoints),
        ),
      ),
    );
  }
}

class EcgPainter extends CustomPainter {
  final List<double> points;
  
  EcgPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw Grid
    double step = 20.0;
    for (double x=0; x<size.width; x+=step) {
      canvas.drawLine(Offset(x,0), Offset(x, size.height), gridPaint);
    }
    for (double y=0; y<size.height; y+=step) {
      canvas.drawLine(Offset(0,y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) return;

    final path = Path();
    // Normalize data: Y range approx -2 to +6 based on simulation
    // We map -2..6 to height..0
    const double minVal = -2.0;
    const double maxVal = 6.0;
    const double range = maxVal - minVal;

    final double xStep = size.width / 300; // Map maxPoints to width

    for (int i = 0; i < points.length; i++) {
      double val = points[i];
      // Normalize height
      double y = size.height - ((val - minVal) / range * size.height);
      double x = i * xStep;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Shadow effect
    final shadowPaint = Paint()
      ..color = AppColors.success.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    
    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Draw main line
    canvas.drawPath(path, paint);

    // Draw glowing head
    if (points.isNotEmpty) {
      double lastY = size.height - ((points.last - minVal) / range * size.height);
      double lastX = (points.length - 1) * xStep;
      canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(lastX, lastY), 8, Paint()..color = AppColors.success.withOpacity(0.4));
    }
  }

  @override
  bool shouldRepaint(covariant EcgPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
