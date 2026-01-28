import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();
  final AIBrain _brain = AIBrain();
  bool _isSessionActive = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _text = "Tap Orb to speak / बात करें";
  String _aiResponse = "";
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _brain.initBrain();
    _initTTS();
    _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
        lowerBound: 0.9,
        upperBound: 1.05);
    _tts.setCompletionHandler(() {
      if (_isSessionActive && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isSessionActive && mounted) _listen();
        });
      }
    });
  }

  Future<void> _initTTS() async {
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setLanguage("en-US");
  }

  void _toggleSession() {
    if (_isSessionActive) {
      _stopSession();
    } else {
      _startSession();
    }
  }

  void _startSession() async {
    bool available = await _speech.initialize(onError: (val) => _handleError());
    if (available) {
      setState(() {
        _isSessionActive = true;
        _aiResponse = "";
        _text = "Listening... / सुन रहा हूँ...";
      });
      _animController.repeat(reverse: true);
      _listen();
    }
  }

  void _stopSession() {
    setState(() {
      _isSessionActive = false;
      _isListening = false;
      _isProcessing = false;
      _text = "Tap Orb to speak / बात करें";
      _animController.stop();
      _animController.value = 1.0;
    });
    _speech.stop();
    _tts.stop();
  }

  void _listen() {
    if (!_isSessionActive) return;
    setState(() => _isListening = true);
    _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) {
              _processVoice(_text);
            }
          });
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2));
  }

  void _handleError() {
    if (_isSessionActive) {
      _speakSmart("Sorry, please say that again.");
    }
  }

  void _processVoice(String query) async {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });
    if (query.trim().isEmpty) {
      _handleError();
      return;
    }
    String lowerQuery = query.toLowerCase();
    bool isHindi = lowerQuery.contains("kisne") ||
        lowerQuery.contains("kya") ||
        lowerQuery.contains("banaya") ||
        lowerQuery.contains("kaise") ||
        lowerQuery.contains("sakte") ||
        lowerQuery.contains("tum") ||
        lowerQuery.contains("namaste");

    if (lowerQuery.contains("who made you") ||
        lowerQuery.contains("kisne banaya") ||
        lowerQuery.contains("creator") ||
        lowerQuery.contains("developer")) {
      String reply = isHindi
          ? "मैं CodeNetra AI हूँ। मुझे रोशन चौरसिया ने बनाया है, ताकि मैं नेत्रहीनों के लिए डिजिटल आँखें बन सकूँ।"
          : "I am CodeNetra AI, engineered by Roshan Chaurasiya to act as digital eyes for the visually impaired.";
      setState(() {
        _isProcessing = false;
        _aiResponse = reply;
      });
      await _speakSmart(reply);
      return;
    }

    if (lowerQuery.contains("what can you do") ||
        lowerQuery.contains("kya kar sakte ho") ||
        lowerQuery.contains("tum kya ho")) {
      String reply = isHindi
          ? "मैं एक सुपर असिस्टेंट हूँ। मैं देख सकता हूँ, पढ़ सकता हूँ, नोट पहचान सकता हूँ और कोडिंग में मदद कर सकता हूँ।"
          : "I am a Super Assistant. I can see objects, read documents, detect currency, and help with coding.";
      setState(() {
        _isProcessing = false;
        _aiResponse = reply;
      });
      await _speakSmart(reply);
      return;
    }

    String prompt =
        "You are a helpful AI assistant. USER SAID: \"$query\". INSTRUCTIONS: Detect Language ($query). Keep it short (2 sentences).";
    String? res = await _brain.askLaravel(prompt);
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _aiResponse = res ?? "Connection Error.";
    });
    await _speakSmart(_aiResponse);
  }

  Future<void> _speakSmart(String text) async {
    bool isHindi = text.contains(RegExp(r'[\u0900-\u097F]'));
    if (isHindi) {
      await _tts.setLanguage("hi-IN");
    } else {
      await _tts.setLanguage("en-US");
    }
    await _tts.speak(text);
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
        child: Stack(alignment: Alignment.center, children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        color: _isListening
                            ? AppColors.primaryAccent
                            : Colors.white,
                        fontSize: 22,
                        fontWeight: _isListening
                            ? FontWeight.bold
                            : FontWeight.normal))),
            const SizedBox(height: 40),
            GestureDetector(
                onTap: _toggleSession,
                child: ScaleTransition(
                    scale: _animController,
                    child: Container(
                        height: 350,
                        width: 350,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.transparent),
                        child: ClipOval(
                            child:
                                Stack(alignment: Alignment.center, children: [
                          Image.asset("assets/orb.gif",
                              fit: BoxFit.cover, height: 350, width: 350),
                          if (_isProcessing)
                            const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          if (!_isSessionActive)
                            const Icon(Icons.touch_app,
                                color: Colors.white54, size: 60),
                          if (_isSessionActive &&
                              !_isProcessing &&
                              !_isListening)
                            const Icon(Icons.mic_off,
                                color: Colors.white30, size: 50)
                        ]))))),
            const SizedBox(height: 40),
            if (_aiResponse.isNotEmpty)
              Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.borderSubtle.withOpacity(0.5))),
                  child: Text(_aiResponse,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 18))),
          ])
        ]),
      ),
    );
  }
}
