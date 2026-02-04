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
  String _status = "INITIALIZING...";
  String _aiResponse = "";

  // Safety Timer
  Timer? _silenceTimer;

  // Animation
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _brain.initBrain();

    // Orb Pulse Animation
    _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
        lowerBound: 0.95,
        upperBound: 1.05);

    _initSystem();
  }

  // 1. SETUP SYSTEM (Voice & Auto-Loop Logic)
  void _initSystem() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(0.9); // Deep & Professional
    await _tts.setSpeechRate(0.6); // Clear & Commanding Speed

    // ✅ MAGIC LOOP: Jawab khatam hote hi screen saaf aur sunna shuru
    _tts.setCompletionHandler(() async {
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted && !_isListening && !_isThinking) {
        setState(() {
          _aiResponse = ""; // Screen Clear
          _status = "LISTENING...";
        });
        _startListening(); // Auto Listen Start
      }
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _tts.speak("CodeNetra online. I'm listening, Sir.");
  }

  // 2. SMART LISTENING (1.5 Sec Pause - Perfect Balance)
  void _startListening() async {
    if (_isListening || _isThinking) return;

    bool available = await _speech.initialize(
      onError: (val) {
        if (val.errorMsg != "error_busy") _resetSilenceTimer();
      },
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (mounted && !_isThinking) {
            setState(() {
              _isListening = false;
              if (_aiResponse.isEmpty) _status = "PROCESSING...";
            });
            _animController.stop();
            _animController.value = 1.0;
          }
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _status = "LISTENING...";
      });
      _animController.repeat(reverse: true);
      _resetSilenceTimer();

      _speech.listen(
        onResult: (val) {
          _silenceTimer?.cancel();
          if (val.finalResult) {
            _processVoice(val.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 20),
        // ✅ 1.5 SECONDS PAUSE (Natural Conversation Flow)
        pauseFor: const Duration(milliseconds: 1500),
        localeId: "en-US",
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    _silenceTimer?.cancel();
    if (mounted) {
      setState(() {
        _isListening = false;
        _animController.stop();
        _status = "TAP TO ACTIVATE";
      });
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 60), () {
      _stopListening();
      _tts.speak("Going to sleep mode, Sir.");
    });
  }

  // 3. INTELLIGENT PROCESSING (With KILLER AURA Identity)
  void _processVoice(String query) async {
    if (query.trim().isEmpty) {
      _startListening();
      return;
    }

    _speech.stop();
    _silenceTimer?.cancel();

    setState(() {
      _isListening = false;
      _isThinking = true;
      _animController.stop();
      _status = "ANALYZING...";
    });

    String lowerQuery = query.toLowerCase();

    // 🔥🔥🔥 THE AURA RESPONSE (WHATSAPP STATUS MATERIAL) 🔥🔥🔥
    if (lowerQuery.contains("who made you") ||
        lowerQuery.contains("created by")) {
      _finalizeResponse(
          "I am the digital heartbeat of Roshan Chaurasiya's vision. I exist to bridge the gap between darkness and light. I am CodeNetra, Sir.");
      return;
    }

    // Standard Identity
    if (lowerQuery.contains("who are you")) {
      _finalizeResponse("I am CodeNetra AI, your intelligent assistant, Sir.");
      return;
    }

    // Prompt for Gemini
    String prompt = """
    You are CodeNetra-AI. 
    User said: "$query"
    INSTRUCTIONS:
    1. Reply in English. Tone: Smart, Professional, Concise.
    2. Length: 2 to 3 sentences (Approx 60 words).
    3. Be direct and helpful.
    """;

    String? res = await _brain.askLaravel(prompt);

    _finalizeResponse(res ?? "I didn't catch that, Sir.");
  }

  void _finalizeResponse(String response) async {
    if (mounted) {
      setState(() {
        _isThinking = false;
        _aiResponse = response;
        _status = "ONLINE";
      });
    }
    await _tts.speak(response);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _silenceTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // 4. HOLOGRAPHIC UI (Size 550, Clean Black BG)
  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "CODE NETRA",
      icon: Icons.graphic_eq,
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // STATUS TEXT (HUD)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                border: Border.all(
                    color: _isListening ? Colors.red : Colors.cyan, width: 1),
                borderRadius: BorderRadius.circular(4)),
            child: Text(
              _status,
              style: GoogleFonts.shareTechMono(
                color: _isListening ? Colors.redAccent : Colors.cyanAccent,
                fontSize: 16,
                letterSpacing: 2.0,
              ),
            ),
          ),

          const SizedBox(height: 50),

          // THE ORB (550 Size - NO BACKGROUND GLOW)
          GestureDetector(
              onTap: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _tts.speak("I'm here, Sir.");
                  _startListening();
                }
              },
              child: ScaleTransition(
                  scale: _animController,
                  child: Container(
                      height: 550,
                      width: 550,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent // Pure Transparent
                          ),
                      child: ClipOval(
                          child: Stack(alignment: Alignment.center, children: [
                        Image.asset("assets/orb.gif",
                            fit: BoxFit.cover, height: 550, width: 550),

                        // Thinking Indicator
                        if (_isThinking)
                          const SizedBox(
                            height: 550,
                            width: 550,
                            child: CircularProgressIndicator(
                                color: Colors.cyanAccent, strokeWidth: 2),
                          ),
                      ]))))),

          const SizedBox(height: 50),

          // HOLOGRAPHIC ANSWER DISPLAY
          if (_aiResponse.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                _aiResponse.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    height: 1.4,
                    shadows: [
                      const Shadow(
                        blurRadius: 8.0,
                        color: Colors.cyan,
                        offset: Offset(0, 0),
                      ),
                    ]),
              ),
            ),

          if (_aiResponse.isEmpty) const Spacer(),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
