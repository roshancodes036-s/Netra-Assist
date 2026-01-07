import 'package:google_generative_ai/google_generative_ai.dart';

class AIBrain {
  // ✅ आपकी API Key
  static const String _apiKey = "AIzaSyCxct3Gu814nqGcQIhj5q3u-D0VJAuiA8Q";

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  void initBrain() {
    try {
      _model = GenerativeModel(
        // ✅ CHANGE: 'latest' लगाने से यह एरर फिक्स हो जाएगा
        model: 'gemini-1.5-flash-latest',
        apiKey: _apiKey,
      );
      _chat = _model.startChat();
      _isInitialized = true;
      print("✅ CodeNetra Brain: ACTIVE (Gemini 1.5 Flash)");
    } catch (e) {
      print("❌ Brain Error: $e");
    }
  }

  Future<String?> askLaravel(String prompt) async {
    try {
      if (!_isInitialized) {
        initBrain();
      }
      final content = Content.text(prompt);
      final response = await _chat.sendMessage(content);
      return response.text;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  void stopSpeaking() {
    print("Stopping voice...");
  }
}
