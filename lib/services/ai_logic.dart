import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;
// ✅ FIX: dotenv पैकेज इम्पोर्ट किया गया है
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIBrain {
  // ⚠️ सावधानी: प्रोडक्शन में API Key को '.env' फाइल में रखना चाहिए।
  // ✅ 5 API Keys for Auto-Failover & Load Balancing (Hackathon Model)
  // FIX: const हटाकर final किया गया है और dotenv से Keys ली जा रही हैं
  static final List<String> _apiKeys = [
    dotenv.env['GEMINI_KEY_1'] ?? '', // पुरानी Key यहाँ डालें
    dotenv.env['GEMINI_KEY_2'] ?? '', // नई Key 1
    dotenv.env['GEMINI_KEY_3'] ?? '', // नई Key 2
    dotenv.env['GEMINI_KEY_4'] ?? '', // नई Key 3
    dotenv.env['GEMINI_KEY_5'] ?? '', // नई Key 4
  ];

  int _currentKeyIndex = 0;

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  // 🌐 NEW: Bhasha Setu (Language Toggle) - Default English
  static bool isHindi = false;

  void initBrain() {
    try {
      String activeKey = _apiKeys[_currentKeyIndex];
      
      // ✅ Safety Check: अगर .env फाइल में Key नहीं मिली
      if (activeKey.isEmpty) {
        developer.log("❌ Error: API Key is missing in .env file!");
        return;
      }

      _model = GenerativeModel(
        // 🔥 Gemini 3 Flash Preview (Hackathon Special)
        model: 'gemini-3-flash-preview',
        apiKey: activeKey,
      );
      _chat = _model.startChat();
      _isInitialized = true;
      developer.log(
          "✅ Netra AI Brain: ACTIVE (Model: gemini-3-flash-preview, Key Index: $_currentKeyIndex)");
    } catch (e) {
      developer.log("❌ Brain Error: $e");
    }
  }

  // 🔹 Dynamic System Instruction (भाषा के आधार पर)
  String get _systemInstruction {
    if (isHindi) {
      return " (कृपया हिंदी में बहुत ही सरल और स्पष्ट जवाब दें। दृष्टिबाधित व्यक्ति के लिए सुरक्षा और आस-पास की चीजों का सटीक वर्णन करें।)";
    } else {
      return " (Please reply in simple English. For blind users, provide concise, safety-first descriptions regarding obstacles, currency, or text.)";
    }
  }

  // 🔥 1. TEXT ONLY CHAT
  Future<String?> askLaravel(String prompt) async {
    // 🔥 MAGIC TRICK: Load Balancing (रिक्वेस्ट आते ही अगली Key पर स्विच करें)
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    _isInitialized = false;

    int maxRetries = _apiKeys.length;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        if (!_isInitialized) initBrain();

        final content = Content.text(prompt.isNotEmpty
            ? prompt + _systemInstruction
            : "Hello$_systemInstruction");

        final response = await _chat.sendMessage(content);
        return response.text;
      } catch (e) {
        developer
            .log("❌ Text Key $_currentKeyIndex Failed! Switching... Error: $e");
        attempts++;
        _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
        _isInitialized = false; // Force re-initialization with next key

        if (attempts >= maxRetries) {
          return "Error: ${e.toString()}";
        }
      }
    }
    return null;
  }

  // 🔥 2. REGULAR IMAGE CHAT (Gallery/Detailed Analysis)
  Future<String?> askWithImage(String prompt, File imageFile) async {
    // 🔥 MAGIC TRICK: Load Balancing
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    _isInitialized = false;

    int maxRetries = _apiKeys.length;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        if (!_isInitialized) initBrain();

        final imageBytes = await imageFile.readAsBytes();
        final content = Content.multi([
          TextPart(prompt.isEmpty
              ? (isHindi
                  ? "एक दृष्टिबाधित व्यक्ति के लिए इस तस्वीर को विस्तार से समझाएं।$_systemInstruction"
                  : "Explain this image in detail for a visually impaired person.$_systemInstruction")
              : prompt + _systemInstruction),
          DataPart('image/jpeg', imageBytes),
        ]);

        final response = await _model.generateContent([content]);
        return response.text;
      } catch (e) {
        developer.log(
            "❌ Image Key $_currentKeyIndex Failed! Switching... Error: $e");
        attempts++;
        _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
        _isInitialized = false;

        if (attempts >= maxRetries) {
          return "Image Error: ${e.toString()}";
        }
      }
    }
    return null;
  }

  // 🚀 3. SUPER-FAST LIVE VISION (कैमरा फीड के लिए)
  Future<String?> fastVisionScan(File imageFile) async {
    // 🔥 MAGIC TRICK: Load Balancing (1.5 सेकंड लूप को बिना एरर चलाने के लिए)
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    _isInitialized = false;

    int maxRetries = _apiKeys.length;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        if (!_isInitialized) initBrain();

        // ⚡ Fast Prompt: AI को सोचने का समय कम करने के लिए
        String fastPrompt = isHindi
            ? "सामने मौजूद मुख्य खतरे या वस्तु को अधिकतम 3-4 शब्दों में बताएं।"
            : "Describe the primary hazard or object ahead in max 3-4 words.";

        final imageBytes = await imageFile.readAsBytes();
        final content = Content.multi([
          TextPart(fastPrompt),
          DataPart('image/jpeg', imageBytes),
        ]);

        final response = await _model.generateContent([content]);
        return response.text;
      } catch (e) {
        developer.log(
            "❌ FastScan Key $_currentKeyIndex Failed! Switching... Error: $e");
        attempts++;
        _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
        _isInitialized = false;

        if (attempts >= maxRetries) {
          return isHindi ? "स्कैनिंग में एरर" : "Scan Error";
        }
      }
    }
    return null;
  }

  // 🛡️ NEW: 4. SUPER-FAST DOCUMENT SCANNER (With 'NO_DOC' Rule)
  Future<String?> analyzeDocumentLive(File imageFile) async {
    // 🔥 MAGIC TRICK: Load Balancing
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    _isInitialized = false;

    int maxRetries = _apiKeys.length;
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        if (!_isInitialized) initBrain();

        String langInstruction =
            isHindi ? "HINDI language" : "ENGLISH language";
        // 🔥 The Ultra-Fast Prompt (Ye Gemini ko control karega)
        String secretPrompt = isHindi
            ? """
कैमरे की इस फोटो को देखो। 
नियम 1: अगर इस फोटो में कोई स्पष्ट कागज़, बिल, या डॉक्यूमेंट नहीं है, तो सिर्फ और सिर्फ 'NO_DOC' लिखो। और कुछ मत लिखना।
नियम 2: अगर कागज़ है, तो बहुत ही संक्षेप में $langInstruction में बताओ:
**1. 📄 क्या है?:** (जैसे: ट्रेन टिकट)
**2. 📝 मुख्य बात:** (1-2 लाइन में जानकारी)
**3. ⚠️ अलर्ट:** (कोई धोखा या साइन की जगह?)
"""
            : """
Look at this photo.
RULE 1: If there is NO clear paper, bill, or document in the image, reply EXACTLY and ONLY with 'NO_DOC'.
RULE 2: If there is a document, reply very briefly in $langInstruction:
**1. 📄 What is it?:** (e.g. Train Ticket)
**2. 📝 Summary:** (1-2 lines)
**3. ⚠️ Alert:** (Any risk or signature needed?)
""";

        final imageBytes = await imageFile.readAsBytes();
        final content = Content.multi([
          TextPart(secretPrompt),
          DataPart('image/jpeg', imageBytes),
        ]);

        final response = await _model.generateContent([content]);
        return response.text;
      } catch (e) {
        developer.log("❌ DocScan Key $_currentKeyIndex Failed! Error: $e");
        attempts++;
        _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
        _isInitialized = false;

        if (attempts >= maxRetries) {
          return "NO_DOC"; // एरर आने पर चुप रहेगा, फालतू आवाज़ नहीं करेगा
        }
      }
    }
    return null;
  }

  void stopSpeaking() {
    // Future scope for stopping TTS
  }
}