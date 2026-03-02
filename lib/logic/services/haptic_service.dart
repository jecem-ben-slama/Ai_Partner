import 'package:vibration/vibration.dart';

enum HapticIntensity { off, light, medium, strong }

class HapticService {
  HapticIntensity _currentLevel = HapticIntensity.medium;

  void updateSetting(HapticIntensity level) {
    _currentLevel = level;
  }

  int _getAmp() {
    switch (_currentLevel) {
      case HapticIntensity.off:
        return 0;
      case HapticIntensity.light:
        return 60;
      case HapticIntensity.medium:
        return 140;
      case HapticIntensity.strong:
        return 255;
    }
  }

  Future<void> trigger() async {
    if (_currentLevel == HapticIntensity.off) return;

    if (await Vibration.hasVibrator()) {
      switch (_currentLevel) {
        case HapticIntensity.light:
          Vibration.vibrate(duration: 10, amplitude: 100);
          break;
        case HapticIntensity.medium:
          Vibration.vibrate(duration: 25, amplitude: 150);
          break;
        case HapticIntensity.strong:
          Vibration.vibrate(duration: 45, amplitude: 200);
          break;
        default:
          break;
      }
    }
  }

  Future<void> triggerSuccess() async {
    if (_currentLevel == HapticIntensity.off) return;
    if (await Vibration.hasVibrator()) {
      // Wait 0ms, Vibrate 100ms, Wait 50ms, Vibrate 100ms
      Vibration.vibrate(
        pattern: [0, 100, 50, 100],
        intensities: [0, _getAmp(), 0, _getAmp()],
      );
    }
  }

  Future<void> triggerError() async {
    if (_currentLevel == HapticIntensity.off) return;
    if (await Vibration.hasVibrator()) {
      // One long, slightly decreasing buzz
      Vibration.vibrate(duration: 500, amplitude: _getAmp());
    }
  }

  Future<void> triggerLoading() async {
    if (_currentLevel == HapticIntensity.off) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(
        pattern: [0, 50, 1000, 50], // Very short blips far apart
        intensities: [
          0,
          (_getAmp() * 0.5).toInt(),
          0,
          (_getAmp() * 0.5).toInt(),
        ],
      );
    }
  }
}
