import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';
import '../services/ai_logic.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});
  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;
  final AIBrain _brain = AIBrain();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _chat = [];
  bool _isListening = false;
  bool _isProcessing = false;
  String _statusText = "Tap Mic to Start";
  String _currentTopic = "Flutter";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _brain.initBrain();
    _setupVoice();
    _addMessage("ai",
        "Namaste! I am your AI Interviewer. Choose a topic and tap the mic to start.");
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage("en-IN");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _statusText = "Listening...";
      });
      _speech.listen(onResult: (val) {
        if (val.finalResult) {
          _processUserResponse(val.recognizedWords);
        }
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _statusText = "Processing...";
    });
  }

  void _processUserResponse(String text) async {
    _stopListening();
    if (text.trim().isEmpty) return;
    _addMessage("user", text);
    setState(() => _isProcessing = true);

    String prompt = """
    ACT AS A STRICT GOOGLE INTERVIEWER. Topic: $_currentTopic. User Said: "$text".
    INSTRUCTIONS: 1. If user says 'Start', ask first question. 2. Rate answers (0-10) & correct them. 3. Ask NEXT question. 4. Keep it conversational.
    """;
    String? res = await _brain.askLaravel(prompt);
    if (mounted) {
      setState(() => _isProcessing = false);
      _addMessage("ai", res ?? "Error");
      _speak(res ?? "Error");
    }
  }

  void _addMessage(String role, String text) {
    setState(() {
      _chat.add({"role": role, "msg": text});
      _statusText = role == "ai" ? "AI Speaking..." : "Your Turn";
    });
    Timer(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "AI Interviewer",
      icon: Icons.record_voice_over,
      child: Column(children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: ["Flutter", "React Native", "Python", "System Design"]
                    .map((topic) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                            label: Text(topic),
                            backgroundColor: _currentTopic == topic
                                ? AppColors.primaryAccent
                                : AppColors.cardSurface,
                            labelStyle: TextStyle(
                                color: _currentTopic == topic
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold),
                            onPressed: () =>
                                setState(() => _currentTopic = topic))))
                    .toList())),
        const SizedBox(height: 10),
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10)),
                child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _chat.length,
                    itemBuilder: (context, index) {
                      bool isAi = _chat[index]['role'] == "ai";
                      return Align(
                          alignment: isAi
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8),
                              decoration: BoxDecoration(
                                  color: isAi
                                      ? AppColors.cardSurface
                                      : AppColors.primaryAccent
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isAi
                                          ? Colors.white10
                                          : AppColors.primaryAccent
                                              .withOpacity(0.5))),
                              child: Text(_chat[index]['msg']!,
                                  style: GoogleFonts.outfit(
                                      color: Colors.white, fontSize: 15))));
                    }))),
        const SizedBox(height: 20),
        Text(_statusText,
            style: TextStyle(
                color: _isListening ? AppColors.primaryAccent : Colors.grey)),
        const SizedBox(height: 10),
        GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.primaryAccent
                        : AppColors.cardSurface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (_isListening)
                        BoxShadow(
                            color: AppColors.primaryAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5)
                    ],
                    border: Border.all(color: AppColors.primaryAccent)),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.black : Colors.white,
                    size: 30))),
        const SizedBox(height: 10),
      ]),
    );
  }
}
