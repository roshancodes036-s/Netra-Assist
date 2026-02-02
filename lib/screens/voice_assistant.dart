import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Tumhare project ke imports
import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';
import '../services/ai_logic.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  // Services
  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();
  final AIBrain _brain = AIBrain();

  // Variables
  bool _isListening = false;
  bool _isThinking = false;
  String _text = "Tap Orb to speak";
  String _aiResponse = "";

  // Animation for Orb (Pulse Effect)
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _brain.initBrain();
    _initTTS();

    // Animation Setup
    _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
        lowerBound: 0.9,
        upperBound: 1.05);
  }

  // 1. SETUP ENGLISH VOICE
  Future<void> _initTTS() async {
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5); // Clear English speaking rate
    await _tts.setLanguage("en-US"); // Strictly US English
  }

  // 2. GOOGLE-LIKE LISTENING (High Sensitivity)
  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (val) => debugPrint('Error: $val'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
          _animController.stop();
          _animController.value = 1.0;

          // Agar kuch bola gaya hai, to process karo
          if (_text.isNotEmpty &&
              _text != "Listening..." &&
              _text != "Tap Orb to speak") {
            _processVoice(_text);
          }
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _aiResponse = "";
        _text = "Listening...";
      });
      _animController.repeat(reverse: true);

      _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords; // Live text update
          });
        },
        // 🔥 Settings for Long & Sensitive Listening
        listenFor: const Duration(seconds: 30), // 30 sec tak sunega
        pauseFor: const Duration(seconds: 5), // 5 sec pause allow hai
        partialResults: true,
        localeId: "en-US", // Sirf English sunega
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation, // Best mode for sentences
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _animController.stop();
      _animController.value = 1.0;
    });
  }

  // 3. AI PROCESSING (Detailed English Response)
  void _processVoice(String query) async {
    if (query.trim().isEmpty || query == "Listening...") return;

    _speech.stop();
    setState(() {
      _isListening = false;
      _isThinking = true;
      _animController.stop();
    });

    // Handle "Who made you" locally for speed
    String lowerQuery = query.toLowerCase();
    if (lowerQuery.contains("who made you") ||
        lowerQuery.contains("developer") ||
        lowerQuery.contains("creator")) {
      _finalizeResponse(
          "I am CodeNetra AI, engineered by Roshan Chaurasiya from Ghazipur. My mission is to be the digital eyes for the visually impaired.");
      return;
    }

    // 🔥 PROMPT FOR FULL DETAILED EXPLANATION
    String prompt = """
    You are CodeNetra, an advanced AI assistant for the blind.
    User said: "$query"
    
    INSTRUCTIONS:
    1. Reply strictly in English Only.
    2. Provide a DETAILED and INFORMATIVE explanation (No word limit).
    3. Explain concepts clearly like a teacher.
    4. If asked about code, explain the logic simply.
    """;

    String? res = await _brain.askTextOnly(prompt);

    _finalizeResponse(res ?? "I could not understand. Please try again.");
  }

  void _finalizeResponse(String response) async {
    setState(() {
      _isThinking = false;
      _aiResponse = response;
    });
    // Ensure TTS stays in English
    await _tts.setLanguage("en-US");
    await _tts.speak(response);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Voice Assistant",
      icon: Icons.mic,
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // 1. LIVE TEXT DISPLAY
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(_text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      color:
                          _isListening ? AppColors.primaryAccent : Colors.white,
                      fontSize: 22,
                      fontWeight:
                          _isListening ? FontWeight.bold : FontWeight.normal))),

          const SizedBox(height: 40),

          // 2. ORB (Your Original Design)
          GestureDetector(
              onTap: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
              },
              child: ScaleTransition(
                  scale: _animController,
                  child: Container(
                      height: 350,
                      width: 350,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent // No Neon, Pure Original
                          ),
                      child: ClipOval(
                          child: Stack(alignment: Alignment.center, children: [
                        // Orb Image
                        Image.asset("assets/orb.gif",
                            fit: BoxFit.cover, height: 350, width: 350),

                        // Icons Overlay
                        if (_isThinking)
                          const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),

                        if (!_isListening && !_isThinking)
                          const Icon(Icons.touch_app,
                              color: Colors.white54, size: 60),

                        if (_isListening)
                          const Icon(Icons.mic, color: Colors.white, size: 60)
                      ]))))),

          const SizedBox(height: 40),

          // 3. AI RESPONSE BOX (Scrollable for long answers)
          if (_aiResponse.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.borderSubtle.withOpacity(0.5))),
                    child: Text(_aiResponse,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 18))),
              ),
            ),

          // Spacer agar response nahi hai to layout maintain rahe
          if (_aiResponse.isEmpty) const Spacer(),
        ]),
      ),
    );
  }
}
