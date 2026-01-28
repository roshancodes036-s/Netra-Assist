import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';
import '../services/ai_logic.dart';

class UIToCodeScreen extends StatefulWidget {
  const UIToCodeScreen({super.key});
  @override
  State<UIToCodeScreen> createState() => _UIToCodeScreenState();
}

class _UIToCodeScreenState extends State<UIToCodeScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  bool _loading = false;
  bool _isScanning = false;
  String _selectedLanguage = "Flutter";
  String _generatedCode = "";
  late AnimationController _scanController;
  late Animation<double> _textAnim;
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _scanController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _textAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_scanController);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _generatedCode = "";
        _isScanning = false;
      });
    }
  }

  void _showLanguageSelector() {
    if (_image == null) return;
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cardSurface,
        builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Select Output Language",
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(spacing: 12, runSpacing: 12, children: [
                _langChip("Flutter", Icons.flutter_dash),
                _langChip("React Native", Icons.javascript),
                _langChip("HTML/Tailwind", Icons.html),
                _langChip("Python/Kivy", Icons.code)
              ])
            ])));
  }

  Widget _langChip(String label, IconData icon) {
    return ActionChip(
        avatar: Icon(icon, size: 18, color: Colors.black),
        label: Text(label,
            style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryAccent,
        onPressed: () {
          Navigator.pop(context);
          setState(() => _selectedLanguage = label);
          _generateCode();
        });
  }

  Future<void> _generateCode() async {
    setState(() {
      _loading = true;
      _isScanning = true;
      _generatedCode = "";
    });
    String prompt = """
    YOU ARE A LEGENDARY FRONT-END ENGINEER specialized in pixel-perfect UI replication.
    TASK: Deeply analyze the attached UI screenshot and reverse-engineer it into a COMPLETE, RUNNABLE $_selectedLanguage code file.
    STRICT REQUIREMENTS FOR "GOD-LEVEL" ACCURACY:
    1. **VISUAL IDENTITY:** EXTRACT EXACT HEX COLORS. Replicate gradients, shadows, and border radii precisely. Use glassmorphism filters if needed.
    2. **LAYOUT & STRUCTURE:** ESTIMATE PADDING, MARGINS, and font sizes PRECISELY to match the image hierarchy.
    3. **OUTPUT FORMAT:** PROVIDE THE FULL, COMPLETE CODE. No placeholders. Wrap code in triple backticks (```$_selectedLanguage ... ```).
    """;
    String? result = await _brain.askWithImage(prompt, _image!);
    setState(() {
      _loading = false;
      _isScanning = false;
      if (result != null) {
        final codeBlockRegex = RegExp(r'```(?:\w+)?\s*(.*?)```', dotAll: true);
        final match = codeBlockRegex.firstMatch(result);
        if (match != null) {
          _generatedCode = match.group(1)?.trim() ?? result;
        } else {
          _generatedCode = result.replaceAll("```", "").trim();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "UI to Code Pro",
      icon: Icons.view_quilt_rounded,
      child: Column(children: [
        Expanded(
            flex: _generatedCode.isEmpty ? 5 : 2, child: _buildImageSection()),
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(children: [
              Expanded(
                  child: _featureCard("Pixel Perfect", Icons.check_circle)),
              const SizedBox(width: 10),
              Expanded(child: _featureCard("Neon/Glass", Icons.blur_on)),
              const SizedBox(width: 10),
              Expanded(child: _featureCard("Full Source", Icons.code))
            ])),
        if (_loading)
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const LinearProgressIndicator(color: AppColors.primaryAccent),
                const SizedBox(height: 10),
                Text("Extracting Styles & Components...",
                    style: GoogleFonts.firaCode(
                        color: AppColors.primaryAccent, fontSize: 14))
              ])),
        if (_generatedCode.isNotEmpty)
          Expanded(
              flex: 6,
              child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      color: AppColors.vsBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle)),
                  child: Column(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                            color: Color(0xFF252526),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16))),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Icon(Icons.code,
                                    color: Colors.blue, size: 18),
                                const SizedBox(width: 8),
                                Text("$_selectedLanguage Output",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))
                              ]),
                              InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _generatedCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Code Copied!")));
                                  },
                                  child: const Icon(Icons.copy,
                                      color: Colors.white, size: 18))
                            ])),
                    Expanded(
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText.rich(
                                CodeHighlighter.highlight(_generatedCode),
                                style: GoogleFonts.firaCode(
                                    fontSize: 14, height: 1.5))))
                  ])))
      ]),
    );
  }

  Widget _featureCard(String text, IconData icon) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle)),
        child: Column(children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(height: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold))
        ]));
  }

  Widget _buildImageSection() {
    bool hasImage = _image != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  hasImage ? AppColors.primaryAccent : AppColors.borderSubtle,
              width: hasImage ? 2 : 1)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(fit: StackFit.expand, children: [
            if (hasImage)
              Image.file(_image!, fit: BoxFit.contain)
            else
              _buildPlaceholder(),
            if (_isScanning)
              AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) => FractionallySizedBox(
                      heightFactor: 0.005,
                      alignment: Alignment(0, _scanController.value * 2 - 1),
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryAccent.withOpacity(0),
                                    AppColors.primaryAccent,
                                    AppColors.primaryAccent.withOpacity(0)
                                  ]),
                              boxShadow: const [
                            BoxShadow(
                                color: AppColors.primaryAccent,
                                blurRadius: 8,
                                spreadRadius: 1)
                          ])))),
            if (_isScanning)
              Center(
                  child: FadeTransition(
                      opacity: _textAnim,
                      child: Text("CodeNetra Scanning...",
                          style: GoogleFonts.outfit(
                              color: AppColors.primaryAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                    color: AppColors.primaryAccent,
                                    blurRadius: 10)
                              ])))),
            if (!hasImage)
              Positioned(
                  bottom: 25,
                  left: 0,
                  right: 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.black),
                            label: const Text("Camera",
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAccent)),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo, color: Colors.black),
                            label: const Text("Gallery",
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAccent))
                      ])),
            if (hasImage && !_loading)
              Positioned(
                  bottom: 25,
                  left: 40,
                  right: 40,
                  child: ElevatedButton(
                      onPressed: _showLanguageSelector,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text("GENERATE CODE",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)))),
            if (hasImage && !_loading)
              Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _image = null)))
          ])),
    );
  }

  Widget _buildPlaceholder() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_a_photo_rounded,
          size: 60, color: AppColors.textSecondary.withOpacity(0.3)),
      const SizedBox(height: 15),
      Text("Upload UI Screenshot",
          style: GoogleFonts.outfit(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))
    ]);
  }
}
