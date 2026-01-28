import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';
import '../services/ai_logic.dart';

class FaceEmotionScreen extends StatefulWidget {
  const FaceEmotionScreen({super.key});
  @override
  State<FaceEmotionScreen> createState() => _FaceEmotionScreenState();
}

class _FaceEmotionScreenState extends State<FaceEmotionScreen> {
  File? _image;
  final AIBrain _brain = AIBrain();
  final FlutterTts _tts = FlutterTts();
  bool _isLoading = false;
  String _result = "Tap Camera to Scan Faces";

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _tts.setLanguage("hi-IN");
  }

  Future<void> _scanFace() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera); // Direct Camera
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _result = "Analyzing...";
      });

      String prompt = """
      Analyze this image for people.
      OUTPUT FORMAT (Hindi/English Mix):
      1. Count: How many people?
      2. Details: Appx Age, Gender for each.
      3. Emotion: Happy, Sad, Angry?
      4. Activity: What are they doing?
      Keep it conversational like a friend describing the scene to a blind person.
      """;

      String? res = await _brain.askWithImage(prompt, _image!);
      setState(() {
        _isLoading = false;
        _result = res ?? "Could not analyze.";
      });
      _tts.speak(_result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Face & Emotion",
      icon: Icons.face_retouching_natural,
      child: Column(children: [
        Expanded(
            flex: 3,
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primaryAccent.withOpacity(0.5))),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(Icons.person_search,
                                size: 80,
                                color:
                                    AppColors.primaryAccent.withOpacity(0.5)),
                            const SizedBox(height: 10),
                            Text("Tap to Scan",
                                style: GoogleFonts.outfit(
                                    color: Colors.white38, fontSize: 18))
                          ]))),
        const SizedBox(height: 20),
        if (_isLoading)
          const CircularProgressIndicator(color: AppColors.primaryAccent),
        if (!_isLoading)
          Expanded(
              flex: 1,
              child: SingleChildScrollView(
                  child: Text(_result,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center))),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _scanFace,
                icon:
                    const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                label: const Text("SCAN NOW",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)))))
      ]),
    );
  }
}
