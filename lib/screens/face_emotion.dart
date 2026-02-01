import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Camera Package
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../services/ai_logic.dart';

class FaceEmotionScreen extends StatefulWidget {
  const FaceEmotionScreen({super.key});
  @override
  State<FaceEmotionScreen> createState() => _FaceEmotionScreenState();
}

class _FaceEmotionScreenState extends State<FaceEmotionScreen>
    with SingleTickerProviderStateMixin {
  // Camera & AI Variables
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0; // 0 = Back, 1 = Front
  
  final AIBrain _brain = AIBrain();
  final FlutterTts _tts = FlutterTts();
  
  // Logic Variables
  bool _isProcessing = false;
  String _result = "Initializing Social Coach...";
  Timer? _timer;

  // Animation Variables (Laser Scan)
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _setupVoice();
    _initCamera();
    _setupAnimation();
  }

  // 1. SETUP LASER ANIMATION
  void _setupAnimation() {
    _animController = AnimationController(
      duration: const Duration(seconds: 2), // 2 Second scan speed
      vsync: this,
    )..repeat(reverse: true); // Upar-Niche hota rahega

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
  }

  // 2. ENGLISH VOICE SETUP
  Future<void> _setupVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  // 3. CAMERA SETUP (Dual Support)
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _setCamera(_cameras![_selectedCameraIdx]);
    }
  }

  Future<void> _setCamera(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(
      cameraDescription, 
      ResolutionPreset.medium, 
      enableAudio: false
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
        _startAutoPilot(); // Camera chalu hote hi scanning shuru
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  // 4. TOGGLE FRONT/BACK CAMERA
  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _selectedCameraIdx = (_selectedCameraIdx == 0) ? 1 : 0;
      _result = "Switching Camera...";
    });
    _setCamera(_cameras![_selectedCameraIdx]);
  }

  // 5. AUTO PILOT LOOP
  void _startAutoPilot() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isProcessing && mounted && _controller!.value.isInitialized) {
        _scanFaceAndEmotion();
      }
    });
  }

  // 6. THE SOCIAL COACH LOGIC (AI)
  Future<void> _scanFaceAndEmotion() async {
    try {
      setState(() => _isProcessing = true);
      final image = await _controller!.takePicture();

      // --- EMOTION COACH PROMPT ---
      String prompt = """
      You are 'Netra', a Social Intelligence Coach for a blind person.
      Analyze the face in the image INSTANTLY.
      
      OUTPUT FORMAT:
      [Emotion]: [Social Advice]
      
      RULES:
      1. If ANGRY/UPSET: Say "He looks upset. Speak softly and ask what's wrong."
      2. If HAPPY/SMILING: Say "She looks happy. You can match her energy."
      3. If SERIOUS/FOCUSED: Say "He looks serious. Keep the conversation professional."
      4. If NO FACE: Say "No face detected."
      
      Keep it under 15 words. Speak in English.
      """;

      String? res = await _brain.askWithImage(prompt, File(image.path));

      if (mounted && res != null) {
        setState(() {
          _result = res;
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
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. FULL SCREEN CAMERA
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: CameraPreview(_controller!),
          ),

          // 2. LASER SCAN ANIMATION (The Cool Part)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _animation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2, // Laser ki motai
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent, // Neon Green Laser
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 2
                      )
                    ]
                  ),
                ),
              );
            },
          ),

          // 3. UI OVERLAY (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20, // Bada Text
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isProcessing)
                    const LinearProgressIndicator(color: AppColors.primaryAccent),
                  if (!_isProcessing)
                    Text(
                      "Social Coach Active • Scanning...",
                      style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 12),
                    )
                ],
              ),
            ),
          ),

          // 4. TOP BUTTONS (Back & Switch Camera)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Switch Camera Button
                FloatingActionButton.small(
                  backgroundColor: AppColors.primaryAccent,
                  onPressed: _switchCamera,
                  child: const Icon(Icons.flip_camera_ios, color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}