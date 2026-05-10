# 👁️ Netra Assist — Inclusive Vision & Accessibility Suite  
> **NEXA HACK 2026 Submission** | *For Students, By Students* > *Empowering Vision with AI. Built for real-world utility and UN SDG 3.*

![Powered By](https://img.shields.io/badge/Powered%20by-Gemini%20Flash-8E75B2?style=for-the-badge&logo=google&logoColor=white)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Hackathon](https://img.shields.io/badge/Hackathon-Nexa%20Hack%202026-FFCA28?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

# 🚀 What is Netra Assist?

**Netra Assist is an advanced multimodal AI accessibility super-app.**

Built completely around the Nexa Hack philosophy: *Execution over theory. Build something people would actually use.* It is designed to serve as AI-powered “Digital Eyes” for visually impaired individuals. By leveraging state-of-the-art multimodal vision and voice models, it helps users navigate the world safely, read documents, and understand social cues independently.

> **Netra Assist demonstrates the true power of AI for Social Good: Vision + Voice + Instant Reasoning.**

---

# 🔥 Innovation in 3 Lines (Judge Summary)

✅ **Real-world Utility:** Real-time Vision assistant for blind safety & independent navigation.  
✅ **Disruptive Concept:** Multimodal hazard detection, PDF intelligence, and Emotion scanning in a single suite.  
✅ **Design & Aesthetics:** 100% Voice-First, high-contrast accessible UI designed specifically for visually impaired users.  

---

# ⚡ Quick Judge Test (30 Seconds)

Try these instantly to experience the impact:

### 👁️ Netra Vision Mode
- Open **Live Vision**
- Point camera forward at objects or text 
- Hear real-time narration + hazard alerts instantly 

---

# 🎥 Demo Video

Watch Netra Assist in action (Click below):

[![Netra Assist Demo](https://img.youtube.com/vi/vOPWrFlzU5U/maxresdefault.jpg)](https://youtu.be/vOPWrFlzU5U?si=RmHYsLr8ZkgIvyt_)

> *Click the image above to watch the full demo breakdown.*

---

# 🌍 The Problem 

Technology is evolving faster than ever, but it is leaving behind a massive vulnerable group:

## 👁️ The Accessibility Gap
Millions of visually impaired people struggle daily with:
- Navigating safely in public spaces without human reliance
- Reading physical documents, currency notes, or digital PDFs
- Understanding their surroundings and social cues
- Maintaining true independence in daily life

---

# 💡 The Solution: Netra Assist

Netra Assist bridges the gap between disruptive ideas and execution using multimodal AI intelligence:
- **Vision Understanding** (Object detection, text reading, currency recognition)
- **Voice-First Interface** (No complex typing needed, entirely voice-operated)
- **Ultra-Fast Responses** (Crucial for real-time safety and usability)

---

# ⭐ Key Features

### 🎥 Live Vision (Real-Time World Narration)
Uses AI Vision + Camera Stream to:
- Detect objects in real-time
- Identify hazards in the user's path
- Narrate surroundings instantly via TTS
> *Example: “A car is ahead. Please move left.”*

### 🚗 Live Hazard Detection (Safety Autopilot)
Detects physical dangers like moving vehicles, obstacles, and pits.
> *Triggers Voice warning: **“सावधान! (Caution!)”***

### 💵 Currency Recognition
Identifies Indian Rupee notes instantly to prevent fraud and help in daily transactions.

### 📄 PDF Intelligence
Upload any PDF and the AI will summarize long text, explain complex documents, and provide spoken narration in native languages.

### ❓ Visual Question Answering (VQA)
Capture an image and ask:
- “What is written on this medicine bottle?”  
- “Is this path safe to walk?”  
The AI responds with precise visual reasoning.

### 🎙️ Voice Assistant (Hands-Free Control)
Complete voice-first interaction for ultimate accessibility. Ask without typing and receive spoken answers for all queries.

### 🙂 Face & Emotion Awareness
Helps blind users understand social interactions by scanning faces and detecting emotions (Happy, Sad, Angry, or Neutral).

---

# 🛠️ Tech Stack

| Layer | Technology |
|------|------------|
| Frontend | Flutter (Dart) |
| AI Model | Google Gemini 3 Flash Preview (Ultra-low latency) |
| Vision | Camera + Image Picker |
| Voice | Speech-to-Text + Flutter TTS |
| Document Processing | Syncfusion PDF + Markdown |
| Backend | Firebase |

---
### 🏆 Nexa Hack Alignment

Netra Assist is a functional, scalable product built for the **Artificial Intelligence** & **Social Impact** arenas. 

* **Thinking like a Founder:** Designed as a complete, market-ready accessibility ecosystem featuring Auto-Failover & API Load Balancing.
* **Problem Solving:** Challenges outdated systems by combining multiple accessibility tools into one seamless super-app.
* **✅ Solo Developer Verification:** Please note that all commits from user **`roshancodes036-sudo`** belong to the **Sole Creator, Roshan Chaurasiya**.

---

# 🔐 API Key & Security Setup (Important)

For security reasons, the API keys and `.env` file are **not included** in this public repository. The app uses an advanced Auto-Failover & Load Balancing system with 5 API keys for uninterrupted real-time vision.

### 🛠️ How to Fix & Run the App:

1. **Get API Keys:** Get free keys from [Google AI Studio](https://aistudio.google.com/).
2. **Create `.env` File:** Create a file named `.env` in the root folder of the project and add your keys like this:
   ```env
   GEMINI_KEY_1=your_api_key_1_here
   GEMINI_KEY_2=your_api_key_2_here
   GEMINI_KEY_3=your_api_key_3_here
   GEMINI_KEY_4=your_api_key_4_here
   GEMINI_KEY_5=your_api_key_5_here

3. Create AI Logic File: Go to the lib/services/ folder and create a new file named ai_logic.dart.

4. Paste Code: Copy and paste the following code into that file:
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

⚡ Run Locally
1.Clone Repository:
git clone [https://github.com/roshancodes036-sudo/Netra-Assist-AI.git](https://github.com/roshancodes036-sudo/Netra-Assist-AI.git)
cd Netra-Assist-AI

2.Install & Run:
flutter pub get
flutter run

👨‍💻 Built by Roshan Chaurasiya 📍 Ghazipur, India Challenging ordinary thinking and building technology with purpose.

   
