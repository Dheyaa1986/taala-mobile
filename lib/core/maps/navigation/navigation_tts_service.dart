import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NavigationTtsService {
  NavigationTtsService() : _tts = FlutterTts();

  final FlutterTts _tts;
  var _ready = false;
  String? _lastSpoken;

  Future<void> initialize() async {
    if (_ready) return;
    try {
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1);
      await _tts.setPitch(1);
      final languages = await _tts.getLanguages;
      if (languages is List &&
          languages.any((lang) => lang.toString().startsWith('ar'))) {
        await _tts.setLanguage('ar');
      }
      _ready = true;
    } catch (error, stackTrace) {
      debugPrint('NavigationTtsService init failed: $error\n$stackTrace');
    }
  }

  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!_ready) await initialize();
    if (trimmed == _lastSpoken) return;

    _lastSpoken = trimmed;
    try {
      await _tts.stop();
      await _tts.speak(trimmed);
    } catch (error, stackTrace) {
      debugPrint('NavigationTtsService speak failed: $error\n$stackTrace');
    }
  }

  Future<void> stop() async {
    _lastSpoken = null;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  void resetLastSpoken() {
    _lastSpoken = null;
  }
}
