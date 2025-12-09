import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  Future<bool> requestPermissions() async {
    if (!Platform.isIOS) return false;

    // Define the types to get
    var types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_OXYGEN,
    ];

    // Request access
    bool requested = await _health.requestAuthorization(types);
    return requested;
  }

  // Stream Heart Rate (Simulated for real-time smoothness if HK is slow)
  // HealthKit queries are usually poll-based, not real-time streams in the "socket" sense.
  // We will poll periodically or rely on HealthKit background delivery (advanced).
  // For this demo, we will POLL every 5 seconds.
  Stream<double> get heartRateStream async* {
    if (!Platform.isIOS) yield* Stream.empty();

    while (true) {
      try {
        // Fetch last 1 minute of data
        final now = DateTime.now();
        final start = now.subtract(const Duration(minutes: 1));
        
        List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
          startTime: start,
          endTime: now,
          types: [HealthDataType.HEART_RATE],
        );

        if (points.isNotEmpty) {
           // Get the most recent
           points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
           // Value is usually HealthValue, need to extract double
           // Health package v10 handling:
           var val = points.first.value;
           if (val is NumericHealthValue) {
             yield val.numericValue.toDouble();
           }
        }
      } catch (e) {
        print("HealthKit Error: $e");
      }
      await Future.delayed(const Duration(seconds: 2)); // Poll every 2s
    }
  }
}
