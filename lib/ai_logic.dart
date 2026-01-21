import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;

class AIBrain {
  // ✅ User API Key Integration
  static const String _apiKey = "AIzaSyB_tuAVDkNGGkGzRflSnmDzl_SFm79ljRc";

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  void initBrain() {
    try {
      _model = GenerativeModel(
        // 🔥 Gemini 3 Flash Preview (Hackathon Special)
        // High speed and low latency for Live Vision
        model: 'gemini-3-flash-preview', 
        apiKey: _apiKey,
      );
      _chat = _model.startChat();
      _isInitialized = true;
      developer.log("✅ Netra AI Brain: ACTIVE (Model: gemini-3-flash-preview)");
    } catch (e) {
      developer.log("❌ Brain Error: $e");
    }
  }

  // 🔹 System Instruction (Language + Tone + Safety)
  String get _systemInstruction =>
      " (Reply in the same language as the user (English, Hindi, or Hinglish). Keep the tone professional yet friendly. Use relevant emojis naturally. For blind users, provide concise, safety-first descriptions regarding obstacles, currency, or text.)";

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

  // 🔥 2. IMAGE + TEXT CHAT (Camera/Gallery)
  // Gemini 3 Flash processes images extremely fast for real-time feedback
  Future<String?> askWithImage(String prompt, File imageFile) async {
    try {
      if (!_isInitialized) initBrain();

      // Convert image to bytes
      final imageBytes = await imageFile.readAsBytes();

      // Prepare Content (Text + Image)
      final content = Content.multi([
        TextPart(prompt.isEmpty
            ? "Explain this image in detail for a visually impaired person.$_systemInstruction"
            : prompt + _systemInstruction),
        DataPart('image/jpeg', imageBytes), 
      ]);

      // Send to Gemini 3
      final response = await _model.generateContent([content]);
      return response.text;
    } catch (e) {
      return "Image Error: ${e.toString()}";
    }
  }

  void stopSpeaking() {
    // Future scope for stopping TTS
  }
}