import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;

class AIBrain {
  // ✅ Apni API Key yahan rakhein
  static const String _apiKey = "AIzaSyDU9ylgbkt2399Kg8aWIjwFmfrg20V_6SI";

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  void initBrain() {
    try {
      _model = GenerativeModel(
        // 🔥 Jaisa aapne kaha: 'gemini-2.5-flash' laga diya hai!
        // Ye model ab Text aur Images dono support karta hai.
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );
      _chat = _model.startChat();
      _isInitialized = true;
      developer.log("✅ CodeNetra Brain: ACTIVE (Model: gemini-2.5-flash)");
    } catch (e) {
      developer.log("❌ Brain Error: $e");
    }
  }

  // 🔹 System Instruction (Language + Tone)
  String get _systemInstruction =>
      " (Reply in the same language as the user (English, Hindi, or Hinglish). Keep the tone professional yet friendly. Use relevant emojis naturally in every sentence.)";

  // 🔥 1. TEXT ONLY CHAT
  Future<String?> askLaravel(String prompt) async {
    try {
      if (!_isInitialized) initBrain();

      // Message + Hidden Instruction
      final content = Content.text(prompt + _systemInstruction);

      final response = await _chat.sendMessage(content);
      return response.text;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // 🔥 2. IMAGE + TEXT CHAT (Camera/Gallery ke liye)
  Future<String?> askWithImage(String prompt, File imageFile) async {
    try {
      if (!_isInitialized) initBrain();

      // Image ko bytes me convert karna
      final imageBytes = await imageFile.readAsBytes();

      // Text + Image data
      final content = Content.multi([
        TextPart(prompt.isEmpty
            ? "Explain this image in detail.$_systemInstruction"
            : prompt + _systemInstruction),
        DataPart('image/jpeg',
            imageBytes), // Gemini 2.5 Images ko natively samajhta hai
      ]);

      // Note: Image bhejne ke liye 'generateContent' use hota hai
      final response = await _model.generateContent([content]);
      return response.text;
    } catch (e) {
      return "Image Error: ${e.toString()}";
    }
  }

  void stopSpeaking() {}
}
