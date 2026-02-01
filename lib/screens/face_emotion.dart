import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

// Tumhare purane imports
import '../theme/app_colors.dart';
import '../services/ai_logic.dart';

class FaceEmotionScreen extends StatefulWidget {
  const FaceEmotionScreen({super.key});
  @override
  State<FaceEmotionScreen> createState() => _FaceEmotionScreenState();
}

class _FaceEmotionScreenState extends State<FaceEmotionScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0; // 0 = Back, 1 = Front (Default Back)
  
  final AIBrain _brain = AIBrain();
  final FlutterTts _tts = FlutterTts();
  
  bool _isProcessing = false;
  String _result = "Initializing Social Coach...";
  Timer? _timer;

  // Animation Variables
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

  void _setupAnimation() {
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    // Default to Front Camera for Face/Emotion if available, else Back
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Find front camera index
      int frontIndex = _cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _selectedCameraIdx = (frontIndex != -1) ? frontIndex : 0;
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
        _startAutoPilot();
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      // Toggle Index: 0 -> 1, 1 -> 0
      _selectedCameraIdx = (_selectedCameraIdx == 0) ? 1 : 0;
      _result = "Switching Camera...";
    });
    _setCamera(_cameras![_selectedCameraIdx]);
  }

  void _startAutoPilot() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isProcessing && mounted && _controller!.value.isInitialized) {
        _scanFaceAndEmotion();
      }
    });
  }

  Future<void> _scanFaceAndEmotion() async {
    try {
      setState(() => _isProcessing = true);
      final image = await _controller!.takePicture();

      String prompt = """
      You are 'Netra', a Social Intelligence Coach for a blind person.
      Analyze the face in the image INSTANTLY.
      
      OUTPUT FORMAT:
      [Emotion]: [Social Advice]
      
      RULES:
      1. If ANGRY/UPSET: Say "He looks upset. Speak softly."
      2. If HAPPY/SMILING: Say "She looks happy. You can match her energy."
      3. If SERIOUS/FOCUSED: Say "He looks serious. Be professional."
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

          // 2. LASER SCAN ANIMATION
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _animation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
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

          // 3. UI OVERLAY (Bottom Text Panel)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 30),
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
                      fontSize: 18,
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

          // 4. FLOATING CAMERA SWITCH BUTTON (Bottom Right - iPhone Style)
          Positioned(
            bottom: 160, // Text box ke thoda upar
            right: 20,
            child: FloatingActionButton(
              heroTag: "switch_cam",
              backgroundColor: Colors.black.withOpacity(0.6), // Translucent Black
              onPressed: _switchCamera,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: const BorderSide(color: Colors.white38, width: 1)
              ),
              child: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 28),
            ),
          ),

          // 5. BACK BUTTON (Top Left - Safe Area Fixed)
          Positioned(
            top: 50, // Thoda aur niche kiya taki status bar se bache
            left: 20,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                radius: 22,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}