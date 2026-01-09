import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math'; // Neon Animation ke liye
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ FIREBASE IMPORTS
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ YOUR BRAIN IMPORT
import 'ai_logic.dart';

// ✅ ALL NECESSARY PACKAGES
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// =============================================================================
// APP ENTRY POINT
// =============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CodeNetraApp());
}

class CodeNetraApp extends StatelessWidget {
  const CodeNetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeNetra AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        primaryColor: const Color(0xFFCCFF00),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}

// =============================================================================
// 1. SPLASH SCREEN
// =============================================================================
class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim, _blurAnim, _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _blurAnim = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );
    _controller.forward();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainLayout(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnim.value,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                    sigmaX: _blurAnim.value, sigmaY: _blurAnim.value),
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.code,
                          size: 90, color: Color(0xFFCCFF00)),
                      const SizedBox(height: 20),
                      Text(
                        "CodeNetra",
                        style: GoogleFonts.inter(
                            fontSize: 50,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Own Your Code.",
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            letterSpacing: 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 2. MAIN LAYOUT (🔥 UPDATED: No Bottom Nav Bar)
// =============================================================================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  void _changeScreen(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigate: _changeScreen), // 0
      const ChatScreen(), // 1
      const TemplatesScreen(), // 2
      const CodeExpertScreen(), // 3
      const ImageGenScreen(), // 4
      const PDFScreen(), // 5
      const VoiceScreen(), // 6
      const UpgradeScreen(), // 7
    ];

    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("CodeNetra",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),

      drawer: Drawer(
        backgroundColor: Colors.black,
        child: SidebarContent(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              _changeScreen(index);
              Navigator.pop(context);
            }),
      ),

      body: Row(
        children: [
          if (isWideScreen)
            Container(
                width: 280,
                color: Colors.black,
                child: SidebarContent(
                    selectedIndex: _selectedIndex, onTap: _changeScreen)),
          Expanded(
            // 🔥 NeonWrapper removed from here. It's inside the screens now.
            child: screens[_selectedIndex],
          ),
        ],
      ),
      // ❌ BottomNavigationBar REMOVED as requested
    );
  }
}

// --- SIDEBAR ---
class SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const SidebarContent(
      {super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Row(
            children: [
              const Icon(Icons.code, color: Color(0xFFCCFF00), size: 30),
              const SizedBox(width: 10),
              Text("CodeNetra",
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("CORE"),
                  _btn("Home", Icons.home_filled, 0),
                  _btn("Chat & Actions", Icons.chat_bubble, 1),
                  const SizedBox(height: 20),
                  _header("TOOLS"),
                  _btn("Templates", Icons.dashboard_outlined, 2),
                  _btn("PDF Analysis", Icons.picture_as_pdf_outlined, 3),
                  _btn("Text to Image", Icons.image_outlined, 4),
                  const SizedBox(height: 20),
                  _header("ADVANCED"),
                  _btn("Code Expert", Icons.terminal, 5),
                  _btn("Text to Voice", Icons.graphic_eq, 6),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _btn("Upgrade Plan", Icons.bolt, 7, isHighlight: true),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(text,
          style: GoogleFonts.inter(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0)));
  Widget _btn(String title, IconData icon, int index,
      {bool isHighlight = false}) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1F1F1F) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: isSelected
                ? Border.all(color: const Color(0xFFCCFF00), width: 1)
                : null),
        child: Row(children: [
          Icon(icon,
              color: isSelected || isHighlight
                  ? const Color(0xFFCCFF00)
                  : Colors.grey,
              size: 20),
          const SizedBox(width: 15),
          Text(title,
              style: GoogleFonts.inter(
                  color: isSelected || isHighlight ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15))
        ]),
      ),
    );
  }
}

// =============================================================================
// 3. HOME SCREEN (No Neon Effect here)
// =============================================================================
class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text("Hello, Developer 👋",
                  style: GoogleFonts.inter(
                      fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text("How can CodeNetra help today?",
                  style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => onNavigate(1),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFCCFF00).withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 10))
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.mic, color: Colors.black, size: 32),
                              Icon(Icons.arrow_outward,
                                  color: Colors.black, size: 32)
                            ]),
                        const SizedBox(height: 40),
                        Text("Talk with CodeNetra",
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 5),
                        Text("Powered by Google Gemini",
                            style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600))
                      ]),
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () => onNavigate(4),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0CFFC),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.image,
                              color: Colors.black, size: 28),
                          const SizedBox(width: 15),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Text to Image",
                                    style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text("Generate Assets",
                                    style: GoogleFonts.inter(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600))
                              ])
                        ]),
                        const Icon(Icons.arrow_forward, color: Colors.black)
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. CHAT SCREEN (🔥 UPDATED: Neon Card for Messages, Input Bar Outside)
// =============================================================================
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIBrain _aiBrain = AIBrain();

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _liveVoiceText = "Speak now...";

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _hasText = false;

  File? _selectedImage;
  String? _selectedFileName;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _aiBrain.initBrain();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTTS();

    _controller.addListener(() {
      if (mounted)
        setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  void _initTTS() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedFileName = null;
        _isLoadingImage = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isLoadingImage = false);
      });
    }
  }

  Future<void> _pickFile() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedImage = null;
        _isLoadingImage = false;
      });
    }
  }

  void _speak(String text) async {
    await _flutterTts.stop();
    bool isHindi = text.codeUnits.any((c) => c >= 0x0900 && c <= 0x097F);
    if (isHindi) {
      await _flutterTts.setLanguage("hi-IN");
    } else {
      await _flutterTts.setLanguage("en-US");
    }
    await _flutterTts.speak(text);
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Copied! ✅"), duration: Duration(seconds: 1)));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') _stopListening();
        },
        onError: (e) => _stopListening(),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _liveVoiceText = "Speak now...";
        });
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black,
          builder: (context) => ListeningOverlay(liveText: _liveVoiceText),
        ).then((_) => _stopListening());

        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
              _liveVoiceText = val.recognizedWords;
              _hasText = true;
              _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length));
            });
          },
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      if (mounted) setState(() => _isListening = false);
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  void _sendMessage() async {
    if ((_controller.text.trim().isEmpty && _selectedImage == null) ||
        _isTyping) return;

    String userText = _controller.text.trim();
    File? imageToSend = _selectedImage;

    await _flutterTts.stop();

    setState(() {
      _messages.add({
        "role": "user",
        "text": userText,
        "image": imageToSend,
        "isAnimated": true
      });
      _controller.clear();
      _selectedImage = null;
      _selectedFileName = null;
      _isTyping = true;
      _hasText = false;
    });

    _scrollToBottom();

    String? aiResponse;
    if (imageToSend != null) {
      aiResponse = await _aiBrain.askWithImage(userText, imageToSend);
    } else {
      aiResponse = await _aiBrain.askLaravel(userText);
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          "role": "ai",
          "text": aiResponse ?? "Error.",
          "isAnimated": false
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _onAnimationComplete(int index) {
    if (mounted) setState(() => _messages[index]['isAnimated'] = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 🔥 Chat Messages are INSIDE NeonWrapper
          Expanded(
            child: NeonWrapper(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 40, color: Color(0xFF222222)),
                          const SizedBox(height: 15),
                          Text("CodeNetra AI",
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 10, bottom: 20),
                            child: Row(
                              children: [
                                SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: Image.asset("assets/orb.gif")),
                                const SizedBox(width: 10),
                                Text("Thinking...",
                                    style: GoogleFonts.inter(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }
                        final msg = _messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: msg['role'] == "user"
                              ? _buildUserMessage(msg['text'], msg['image'])
                              : _buildAIMessage(
                                  msg['text'], !msg['isAnimated'], index),
                        );
                      },
                    ),
            ),
          ),
          // 🔥 Input Bar is OUTSIDE and BELOW NeonWrapper
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 15, 20),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedImage != null || _selectedFileName != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, left: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(_selectedImage!,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover),
                                  ),
                                  if (_isLoadingImage)
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFCCFF00))),
                                    ),
                                ],
                              )
                            : const Icon(Icons.insert_drive_file,
                                color: Colors.blue, size: 40),
                        const SizedBox(width: 10),
                        if (_selectedFileName != null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(_selectedFileName!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedImage = null;
                            _selectedFileName = null;
                          }),
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 20),
                        ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _showAttachmentMenu,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8, right: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            color: Color(0xFF1E1E1E), shape: BoxShape.circle),
                        child:
                            const Icon(Icons.add, color: Colors.grey, size: 24),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white10)),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                              hintText: "Message CodeNetra",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: (_hasText || _selectedImage != null)
                          ? (_isTyping ? null : _sendMessage)
                          : _listen,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: (_hasText || _selectedImage != null)
                                ? const Color(0xFFCCFF00)
                                : const Color(0xFF1E1E1E),
                            shape: BoxShape.circle),
                        child: _isTyping
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2))
                            : Icon(
                                (_hasText || _selectedImage != null)
                                    ? Icons.arrow_upward
                                    : Icons.mic,
                                color: (_hasText || _selectedImage != null)
                                    ? Colors.black
                                    : Colors.white,
                                size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Add to chat",
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _menuBtn(Icons.camera_alt, "Camera", Colors.pink,
                  () => _pickImage(ImageSource.camera)),
              _menuBtn(Icons.image, "Gallery", Colors.purple,
                  () => _pickImage(ImageSource.gallery)),
              _menuBtn(Icons.insert_drive_file, "File", Colors.blue, _pickFile),
              _menuBtn(Icons.add_to_drive, "Drive", Colors.green, () {}),
            ]),
          ]),
        );
      },
    );
  }

  Widget _menuBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10)),
            child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12))
      ]),
    );
  }

  Widget _buildUserMessage(String text, File? image) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
                color: Color(0xFF1F1F1F),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (image != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.file(image, height: 150, fit: BoxFit.cover)),
                  ),
                if (text.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(text,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 16))),
              ],
            ),
          ))
    ]);
  }

  Widget _buildAIMessage(String text, bool shouldAnimate, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.only(top: 0),
            child: Image.asset("assets/orb.gif", height: 30, width: 30)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shouldAnimate
                  ? TypingTextEffect(
                      text: text, onFinished: () => _onAnimationComplete(index))
                  : SelectableText(text,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 16, height: 1.5)),
              if (!shouldAnimate)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    children: [
                      _actionBtn(Icons.volume_up, () => _speak(text)),
                      const SizedBox(width: 25),
                      _actionBtn(Icons.content_copy, () => _copyText(text)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(5),
            color: Colors.transparent,
            child: Icon(icon, color: Colors.grey, size: 26)));
  }
}

class ListeningOverlay extends StatelessWidget {
  final String liveText;
  const ListeningOverlay({super.key, required this.liveText});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              height: 350,
              width: 350,
              child: Image.asset("assets/orb.gif", fit: BoxFit.contain)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(liveText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: const Color(0xFFCCFF00),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }
}

class TypingTextEffect extends StatefulWidget {
  final String text;
  final VoidCallback onFinished;
  const TypingTextEffect(
      {super.key, required this.text, required this.onFinished});
  @override
  State<TypingTextEffect> createState() => _TypingTextEffectState();
}

class _TypingTextEffectState extends State<TypingTextEffect> {
  String displayedText = "";
  int _charIndex = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) setState(() => displayedText += widget.text[_charIndex++]);
      } else {
        timer.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(displayedText,
        style:
            GoogleFonts.inter(color: Colors.white, fontSize: 16, height: 1.5));
  }
}

// =============================================================================
// 5. TEMPLATES SCREEN (🔥 Wrapped in NeonWrapper)
// =============================================================================
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return NeonWrapper(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _templateCard("Blog Writer", Icons.edit_note, Colors.blue),
                  _templateCard("Social Post", Icons.camera_alt, Colors.pink),
                  _templateCard("Cold Email", Icons.email, Colors.orange),
                  _templateCard("Code Docs", Icons.description, Colors.green),
                  _templateCard("Youtube Idea", Icons.play_circle, Colors.red),
                  _templateCard(
                      "Product Desc", Icons.shopping_bag, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _templateCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 25,
            child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 15),
        Text(title,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16))
      ]),
    );
  }
}

// =============================================================================
// 6. CODE EXPERT SCREEN (🔥 Wrapped in NeonWrapper)
// =============================================================================
class CodeExpertScreen extends StatelessWidget {
  const CodeExpertScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return NeonWrapper(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.circle, color: Colors.red, size: 10),
                      SizedBox(width: 5),
                      Icon(Icons.circle, color: Colors.yellow, size: 10),
                      SizedBox(width: 5),
                      Icon(Icons.circle, color: Colors.green, size: 10),
                      Spacer(),
                      Text("main.py", style: TextStyle(color: Colors.grey))
                    ]),
                    const Divider(color: Colors.white12),
                    const Expanded(
                        child: SingleChildScrollView(
                            child: Text(
                                "def win_hackathon(team):\n if team == 'CodeNetra':\n rank = 1\n print('Judges are impressed!')\n return rank\n else:\n return 'Try again'\n\n# Paste your buggy code here...",
                                style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: Color(0xFFCCFF00),
                                    height: 1.5,
                                    fontSize: 14)))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10)),
              child: Row(children: const [
                Icon(Icons.attachment, color: Colors.grey),
                SizedBox(width: 15),
                Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: "Ask about this code...",
                            border: InputBorder.none))),
                CircleAvatar(
                    backgroundColor: Color(0xFFCCFF00),
                    radius: 18,
                    child:
                        Icon(Icons.arrow_upward, color: Colors.black, size: 20))
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 7. OTHER SCREENS (🔥 Wrapped in NeonWrapper)
// =============================================================================
class PDFScreen extends StatefulWidget {
  const PDFScreen({super.key});
  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  bool isFileUploaded = false;
  String? uploadedFileName;
  void _openFileGallery() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 400,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select File",
                            style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.grey),
                        Expanded(
                            child: ListView(children: [
                          _fileItem("Project.zip", "12 MB", Icons.folder_zip,
                              Colors.orange),
                          _fileItem("Notes.pdf", "2.5 MB", Icons.picture_as_pdf,
                              Colors.red)
                        ])),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.grey)))
                      ])));
        });
  }

  Widget _fileItem(String name, String size, IconData icon, Color color) {
    return ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(size, style: const TextStyle(color: Colors.grey)),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            isFileUploaded = true;
            uploadedFileName = name;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return NeonWrapper(
      child: Container(
        color: Colors.black,
        child: isFileUploaded
            ? Column(children: [
                Container(
                    padding: const EdgeInsets.all(15),
                    color: const Color(0xFF1F1F1F),
                    child: Row(children: [
                      const Icon(Icons.insert_drive_file,
                          color: Color(0xFFCCFF00)),
                      const SizedBox(width: 10),
                      Text(uploadedFileName!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () =>
                              setState(() => isFileUploaded = false))
                    ])),
                Expanded(
                    child: Center(
                        child: Text("Analyzing $uploadedFileName...",
                            style: const TextStyle(color: Colors.grey)))),
                Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: "Ask about file...",
                            filled: true,
                            fillColor: const Color(0xFF1F1F1F),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none))))
              ])
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 80, color: const Color(0xFFCCFF00)),
                    const SizedBox(height: 20),
                    Text("Upload PDF or ZIP",
                        style: GoogleFonts.inter(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        onPressed: _openFileGallery,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCCFF00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15)),
                        icon: const Icon(Icons.folder_open),
                        label: const Text("Select File"))
                  ])),
      ),
    );
  }
}

class ImageGenScreen extends StatefulWidget {
  const ImageGenScreen({super.key});
  @override
  State<ImageGenScreen> createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends State<ImageGenScreen> {
  bool isGenerating = false;
  bool imageGenerated = false;
  void _generateImage() {
    setState(() {
      isGenerating = true;
      imageGenerated = false;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted)
        setState(() {
          isGenerating = false;
          imageGenerated = true;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NeonWrapper(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10)),
                child: isGenerating
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFCCFF00)))
                    : imageGenerated
                        ? Stack(fit: StackFit.expand, children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                    "https://picsum.photos/600/600",
                                    fit: BoxFit.cover)),
                            Positioned(
                                bottom: 20,
                                right: 20,
                                child: FloatingActionButton(
                                    backgroundColor: Colors.white,
                                    child: const Icon(Icons.download,
                                        color: Colors.black),
                                    onPressed: () {}))
                          ])
                        : const Icon(Icons.image,
                            size: 60, color: Colors.white12),
              ),
            ),
            const SizedBox(height: 20),
            Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(children: [
                  const SizedBox(width: 20),
                  const Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: "Cyberpunk city...",
                              border: InputBorder.none))),
                  GestureDetector(
                      onTap: _generateImage,
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              color: Color(0xFFCCFF00), shape: BoxShape.circle),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.black)))
                ]))
          ],
        ),
      ),
    );
  }
}

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  @override
  Widget build(BuildContext context) {
    return NeonWrapper(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
                child: Container(
                    color: Colors.black,
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          SizedBox(
                              height: 350,
                              width: 350,
                              child: Image.asset("assets/orb.gif",
                                  fit: BoxFit.contain)),
                          const SizedBox(height: 20),
                          Text("Listening...",
                              style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 18,
                                  letterSpacing: 1.5))
                        ])))),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 15),
                TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Type text to speak...",
                        filled: true,
                        fillColor: const Color(0xFF1F1F1F),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                    maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 80)),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Generate Voice")),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return NeonWrapper(
      child: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 40),
              Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Free",
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("\$0",
                            style: GoogleFonts.inter(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text("• Gemini 1.5 Flash", style: GoogleFonts.inter()),
                        Text("• 10 Chats/day", style: GoogleFonts.inter())
                      ])),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Pro",
                                  style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Text("RANK 1",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)))
                            ]),
                        const SizedBox(height: 10),
                        Text("\$19",
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text("• Gemini 1.5 Pro (Best)",
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                        Text("• Unlimited Image Gen",
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        Center(
                            child: Text("Upgrade Now",
                                style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)))
                      ]))
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 🔥 NEON WRAPPER CLASS (Paste at bottom)
// =============================================================================
class NeonWrapper extends StatefulWidget {
  final Widget child;
  const NeonWrapper({super.key, required this.child});

  @override
  State<NeonWrapper> createState() => _NeonWrapperState();
}

class _NeonWrapperState extends State<NeonWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // ⚡ SPEED: 'seconds: 4' ko kam karoge to tez ghumega
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 🟢 Margin: Taki card screen ke kinare se thoda door rahe
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _NeonPainter(_controller.value),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(3), // Border ki motai ke liye jagah
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: Colors.black, // Card ka asli background color
                  child: widget.child, // Yahan apka content aayega
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _NeonPainter extends CustomPainter {
  final double animationValue;
  _NeonPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    // 🔥 NEON COLORS (Aapke App ka Green Color)
    final List<Color> colors = [
      Colors.transparent,
      const Color(0xFFCCFF00).withOpacity(0.1),
      const Color(0xFFCCFF00), // Main Bright Green
      const Color(0xFFCCFF00).withOpacity(0.1),
      Colors.transparent,
    ];

    final stops = [0.0, 0.2, 0.5, 0.8, 1.0];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 // Border kitna mota ho
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        stops: stops,
        startAngle: 0.0,
        endAngle: 2 * 3.14159, // 2 * PI
        transform:
            GradientRotation(animationValue * 2 * 3.14159), // Ghumne ka logic
      ).createShader(rect)
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.solid, 4); // Thoda sa Glow effect

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _NeonPainter oldDelegate) => true;
}
