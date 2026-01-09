import 'package:google_generative_ai/google_generative_ai.dart';

class AIBrain {
  // ✅ API Key
  static const String _apiKey = "AIzaSyDcaDZSl-Fc0G762D-4Y-vjvIA5vqNUkFQ";

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  void initBrain() {
    try {
      _model = GenerativeModel(
        // ✅ Jaisa aapne kaha: Wapas 'gemini-2.5-flash' laga diya hai
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );
      _chat = _model.startChat();
      _isInitialized = true;
      print("✅ CodeNetra Brain: ACTIVE (Model: gemini-2.5-flash)");
    } catch (e) {
      print("❌ Brain Error: $e");
    }
  }

  // 🔥 UPDATED FUNCTION: Language + Emojis
  Future<String?> askLaravel(String prompt) async {
    try {
      if (!_isInitialized) {
        initBrain();
      }

      // ✅ Instruction: User ki language + Professional Tone + Emojis
      String hiddenInstruction = " (Reply in the same language as the user (English, Hindi, or Hinglish). Keep the tone professional yet friendly. Use relevant emojis naturally in every sentence.)";

      // User ka message + Instruction
      final content = Content.text(prompt + hiddenInstruction);

      final response = await _chat.sendMessage(content);
      return response.text;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  void stopSpeaking() {}
}