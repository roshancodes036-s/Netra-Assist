import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../services/ai_logic.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});
  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final FlutterTts _tts = FlutterTts();
  final AIBrain _brain = AIBrain();

  bool _isProcessing = false;
  String _desc = "नेत्रा विजन सक्रिय है...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _setupVoice();
    _initCamera();
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.6);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras.first, ResolutionPreset.medium,
          enableAudio: false);
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
        _startFastAnalysisLoop();
      }
    }
  }

  void _startFastAnalysisLoop() {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!_isProcessing && mounted) {
        _captureAndAnalyze();
      }
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      setState(() => _isProcessing = true);
      final image = await _controller!.takePicture();
      String prompt = """
      You are a visual assistant for a blind person.
      ANALYZE PRIORITY:
      1. **DANGER:** Car, Bike, Pit, Fire, Obstacle? Warn immediately.
      2. **CURRENCY:** Identify Note value (e.g. 500 Rupees).
      3. **OBJECT:** Name the main object.
      
      OUTPUT: SHUDH HINDI (Max 6 words).
      Examples: "सावधान, कार आ रही है", "यह 500 रुपये का नोट है".
      """;
      String? res = await _brain.askWithImage(prompt, File(image.path));
      if (mounted && res != null) {
        setState(() {
          _desc = res;
          _isProcessing = false;
        });
        await _tts.speak(res);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent));
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(children: [
            SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(_controller!)),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 30, left: 20, right: 20),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              spreadRadius: 5)
                        ]),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_desc,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                              color: _desc.contains("सावधान") ||
                                      _desc.contains("Car")
                                  ? Colors.redAccent
                                  : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                    color: _desc.contains("सावधान")
                                        ? Colors.red.withOpacity(0.8)
                                        : (_isProcessing
                                            ? Colors.purpleAccent
                                                .withOpacity(0.6)
                                            : AppColors.primaryAccent
                                                .withOpacity(0.4)),
                                    blurRadius: 30,
                                    spreadRadius: 5)
                              ]),
                          child: ClipOval(
                              child:
                                  Stack(alignment: Alignment.center, children: [
                            Image.asset("assets/orb.gif",
                                fit: BoxFit.cover, height: 80, width: 80),
                            if (_isProcessing)
                              const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                          ]))),
                      const SizedBox(height: 10),
                      const Text("AI Vision Active",
                          style: TextStyle(color: Colors.white38, fontSize: 10))
                    ]))),
            Positioned(
                top: 40,
                left: 10,
                child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context))))
          ]);
        } else {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent));
        }
      },
    );
  }
}
