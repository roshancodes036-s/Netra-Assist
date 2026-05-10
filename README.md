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
| AI Model | Google Gemini 1.5 Flash (Ultra-low latency) |
| Vision | Camera + Image Picker |
| Voice | Speech-to-Text + Flutter TTS |
| Document Processing | Syncfusion PDF + Markdown |
| Backend | Firebase |

---
### 🏆 Nexa Hack Alignment

Netra Assist is a functional, scalable product built for the **Artificial Intelligence** & **Social Impact** arenas. 

* **Thinking like a Founder:** Designed as a complete, market-ready accessibility ecosystem, not just a flashy demo.
* **Problem Solving:** Challenges outdated systems by combining multiple accessibility tools into one seamless super-app.
* **✅ Solo Developer Verification:** Please note that all commits from user **`roshancodes036-sudo`** belong to the **Sole Creator, Roshan Chaurasiya**.

---

# 🔐 API Key & Security Setup (Important)

For security reasons, the API key logic is **not included** in this public repository.

### 🛠️ How to Fix & Run the App:

1. **Get API Key:** Get your free key from [Google AI Studio](https://aistudio.google.com/).
2. **Create File:** Go to `lib/services/` folder and create a new file named **`ai_logic.dart`**.
3. **Paste Code:** Copy and paste the following code into that file (Replace `YOUR_KEY` with your actual key):

```dart
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;

class AIBrain {
  // ✅ User API Key Integration
  static const String _apiKey = "YOUR API KEY HERE";

  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  void initBrain() {
    try {
      _model = GenerativeModel(
        // 🔥 Fast model for real-time Live Vision
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
      _chat = _model.startChat();
      _isInitialized = true;
      developer.log("✅ Netra AI Brain: ACTIVE");
    } catch (e) {
      developer.log("❌ Brain Error: $e");
    }
  }

  // 🔹 System Instruction (Language + Tone + Safety)
  String get _systemInstruction =>
      " (Reply in the same language as the user (English, Hindi, or Hinglish). Keep the tone professional yet friendly. Use relevant emojis naturally. For blind users, provide concise, safety-first descriptions regarding obstacles, currency, or text.)";

  // 🔥 1. TEXT ONLY CHAT
  Future<String?> askNetra(String prompt) async {
    try {
      if (!_isInitialized) initBrain();

      // Message + Hidden Instruction
      final content = Content.text(prompt.isNotEmpty
          ? prompt + _systemInstruction
          : "Hello$_systemInstruction");

      final response = await _chat.sendMessage(content);
      return response.text;
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // 🔥 2. IMAGE + TEXT CHAT (Camera/Gallery)
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

      // Send to AI
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

⚡ Run Locally
Clone Repository:
git clone [https://github.com/roshancodes036-sudo/Netra-Assist-AI.git](https://github.com/roshancodes036-sudo/Netra-Assist-AI.git)
cd Netra-Assist-AI

Install & Run:
flutter pub get
flutter run

👨‍💻 Built by Roshan Chaurasiya 📍 Ghazipur, India Challenging ordinary thinking and building technology with purpose.
