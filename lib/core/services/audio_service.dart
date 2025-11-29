import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Future<void> playCompletionSound() async {
    try {
      // Play system notification sound
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  Future<void> playTickSound() async {
    try {
      // Play system click sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  void dispose() {
    // Nothing to dispose
  }
}
