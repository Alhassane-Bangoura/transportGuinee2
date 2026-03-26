import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  TTSService() {
    _init();
  }

  void _init() {
    _flutterTts.setLanguage("fr-FR");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  bool get isSpeaking => _isSpeaking;
}
