import 'dart:async';
import 'dart:math';

class SimulationService {
  Timer? _timer;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  double _time = 0;
  
  void start() {
    // 60Hz update rate (approx 16ms)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _time += 0.05;
      
      // ECG Logic (PQRST approximation)
      final ecg = _simulateECG(_time);
      
      // SpO2 Logic (Plethysmograph - Sine wave with dicrotic notch)
      final spo2Wave = _simulateSpO2(_time);
      
      // Random Heart Rate (60-80 BOM)
      final hr = 70 + 5 * sin(_time * 0.5);
      
      // BP (Systolic 110-130, Diastolic 70-80)
      final sys = 120 + 5 * sin(_time * 0.2);
      final dia = 75 + 2 * cos(_time * 0.2);

      _controller.add({
        'ecg': ecg,
        'spo2_wave': spo2Wave,
        'hr': hr.round(),
        'spo2': 98 + (Random().nextDouble() * 2 - 1), // 97-99%
        'bp': {'sys': sys.round(), 'dia': dia.round()},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  void stop() {
    _timer?.cancel();
  }

  double _simulateECG(double t) {
    double y = 0;
    double period = 1.0; // 1 second per beat (60 BPM base)
    double tMod = t % period;
    
    // P-wave (0.1 - 0.2)
    if (tMod > 0.1 && tMod < 0.2) {
      y += 0.15 * sin((tMod - 0.1) * 10 * pi);
    }
    
    // QRS Complex (0.35 - 0.45) - Made sharper and higher amplitude
    if (tMod > 0.38 && tMod < 0.40) y -= 0.5 * (tMod - 0.38) / 0.02; // Q (Linear dip)
    if (tMod >= 0.40 && tMod < 0.44) {
       // R (Sharp Spike up and down)
       if (tMod < 0.42) {
         y += 3.0 * (tMod - 0.40) / 0.02; // Up
       } else {
         y += 3.0 * (1 - (tMod - 0.42) / 0.02); // Down
       }
    } 
    if (tMod >= 0.44 && tMod < 0.46) y -= 0.5 * (1 - (tMod - 0.44) / 0.02); // S (Linear rise from dip)

    // T-wave (0.6 - 0.8)
    if (tMod > 0.6 && tMod < 0.8) {
      y += 0.3 * sin((tMod - 0.6) * 10 * pi);
    }
    
    // Noise
    y += (Random().nextDouble() - 0.5) * 0.05;
    return y;
  }

  double _simulateSpO2(double t) {
    // Pulse wave with dicrotic notch
    double period = 1.0;
    double tMod = t % period;
    
    double y = sin(tMod * 2 * pi); // Main wave
    if (tMod > 0.3 && tMod < 0.6) {
      y += 0.3 * sin((tMod - 0.3) * 4 * pi); // Notch
    }
    
    return (y + 1) / 2; // Normalize 0-1
  }
}
