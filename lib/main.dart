import 'dart:async';
import 'dart:ui'; // Blur Effect
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ FIREBASE IMPORTS
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ YOUR BRAIN IMPORT
import 'ai_logic.dart';

// ✅ ALL NECESSARY IMPORTS (Voice, Sound, Copy)
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

// --- APP ENTRY POINT ---

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
  bool _showButton = false;

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
      if (mounted) setState(() => _showButton = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: _opacityAnim.value,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                          sigmaX: _blurAnim.value, sigmaY: _blurAnim.value),
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: Column(
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
                  ),
                  const SizedBox(height: 100),
                  AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: GestureDetector(
                      onTap: _navigateToHome,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFCCFF00).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 1)
                          ],
                        ),
                        child: Text("Get Started",
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 2. MAIN LAYOUT
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
      HomeScreen(onNavigate: _changeScreen),
      const ChatScreen(),
      const TemplatesScreen(),
      const PDFScreen(),
      const ImageGenScreen(),
      const CodeExpertScreen(),
      const VoiceScreen(),
      const UpgradeScreen(),
    ];

    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: !isWideScreen
          ? AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text("CodeNetra",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
            )
          : null,
      drawer: !isWideScreen
          ? Drawer(
              backgroundColor: Colors.black,
              child: SidebarContent(
                  selectedIndex: _selectedIndex,
                  onTap: (index) {
                    _changeScreen(index);
                    Navigator.pop(context);
                  }),
            )
          : null,
      body: Container(
        color: Colors.black,
        child: Row(
          children: [
            if (isWideScreen)
              Container(
                  width: 280,
                  color: Colors.black,
                  child: SidebarContent(
                      selectedIndex: _selectedIndex, onTap: _changeScreen)),
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
      ),
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
// 3. HOME SCREEN
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
// 4. CHAT SCREEN (🔥 FINAL FIXED: TTS Completion & Fast Mic Typing)
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

  // 🎤 Voice & TTS
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _liveVoiceText = "Start Speaking..."; // Overlay Text

  // 🔒 Logic
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _aiBrain.initBrain();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    // ✅ FIX: Configure TTS to wait for completion
    _initTTS();

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _hasText = _controller.text.trim().isNotEmpty;
        });
      }
    });
  }

  void _initTTS() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
    await _flutterTts.awaitSpeakCompletion(true); // ✅ Important Fix
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  // 🔊 SMART TEXT TO SPEECH
  void _speak(String text) async {
    await _flutterTts.stop(); // Stop previous
    // Language detection logic
    bool isHindi = text.codeUnits.any((c) => c >= 0x0900 && c <= 0x097F);
    if (isHindi) {
      await _flutterTts.setLanguage("hi-IN");
    } else {
      await _flutterTts.setLanguage("en-US");
    }
    await _flutterTts.speak(text);
  }

  // 📋 COPY TEXT
  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Copied! ✅"), duration: Duration(seconds: 1)),
    );
  }

  // 🎤 SMART MIC FUNCTION
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            _stopListening();
          }
        },
        onError: (e) => _stopListening(),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _liveVoiceText = "Speak now...";
        });

        // 🟢 SHOW OVERLAY
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black,
          builder: (context) => ListeningOverlay(liveText: _liveVoiceText),
        ).then((_) => _stopListening());

        // ✅ FIX: Fast Typing
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
              _liveVoiceText = val.recognizedWords; // Show text on Overlay
              _hasText = true;
              _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length));
            });
          },
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 3),
          partialResults: true, // ✅ Immediate typing
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
    if (_controller.text.trim().isEmpty || _isTyping) return;
    String userText = _controller.text.trim();

    await _flutterTts.stop(); // Stop speaking

    setState(() {
      _messages.add({"role": "user", "text": userText, "isAnimated": true});
      _controller.clear();
      _isTyping = true;
      _hasText = false;
    });

    _scrollToBottom();

    String? aiResponse = await _aiBrain.askLaravel(userText);

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
          const SizedBox(height: 20),

          Expanded(
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
                          padding: const EdgeInsets.only(left: 10, bottom: 20),
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
                            ? _buildUserMessage(msg['text'])
                            : _buildAIMessage(
                                msg['text'], !msg['isAnimated'], index),
                      );
                    },
                  ),
          ),

          // INPUT BAR
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 15, 20),
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _showAttachmentMenu,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8, right: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.grey, size: 24),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white10)),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                          hintText: "Message CodeNetra",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _hasText ? (_isTyping ? null : _sendMessage) : _listen,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _hasText
                            ? const Color(0xFFCCFF00)
                            : const Color(0xFF1E1E1E),
                        shape: BoxShape.circle),
                    child: _isTyping
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2))
                        : Icon(_hasText ? Icons.arrow_upward : Icons.mic,
                            color: _hasText ? Colors.black : Colors.white,
                            size: 24),
                  ),
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
              _attachBtn(Icons.camera_alt, "Camera", Colors.pink),
              _attachBtn(Icons.image, "Gallery", Colors.purple),
              _attachBtn(Icons.insert_drive_file, "File", Colors.blue),
              _attachBtn(Icons.add_to_drive, "Drive", Colors.green),
            ]),
          ]),
        );
      },
    );
  }

  Widget _attachBtn(IconData icon, String label, Color color) {
    return Column(children: [
      Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: const Color(0xFF333333),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10)),
          child: Icon(icon, color: color, size: 28)),
      const SizedBox(height: 8),
      Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12))
    ]);
  }

  Widget _buildUserMessage(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                  color: Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(5))),
              child: Text(text,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16))))
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
                      // BIG BUTTONS
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

// 🔥 LISTENING OVERLAY (SHOWS TEXT)
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

// ... TypingTextEffect class (Same as before) ...
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
// 5. TEMPLATES SCREEN
// =============================================================================
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
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
// 6. CODE EXPERT SCREEN
// =============================================================================
class CodeExpertScreen extends StatelessWidget {
  const CodeExpertScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// =============================================================================
// 7. OTHER SCREENS (PDF, ImageGen, Voice, Upgrade)
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
    if (!isFileUploaded) {
      return Container(
          color: Colors.black,
          child: Center(
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
              ])));
    } else {
      return Container(
          color: Colors.black,
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(15),
                color: const Color(0xFF1F1F1F),
                child: Row(children: [
                  const Icon(Icons.insert_drive_file, color: Color(0xFFCCFF00)),
                  const SizedBox(width: 10),
                  Text(uploadedFileName!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => setState(() => isFileUploaded = false))
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
          ]));
    }
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
    return Container(
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
    return Container(
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
    );
  }
}

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
