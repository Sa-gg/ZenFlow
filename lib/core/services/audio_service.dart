import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Future<void> playCompletionSound() async {
    if (kIsWeb) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  Future<void> playTickSound() async {
    if (kIsWeb) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  void dispose() {}
}
