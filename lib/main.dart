import 'dart:async';
import 'dart:ui'; // Blur Effect
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ FIREBASE IMPORTS
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ YOUR BRAIN IMPORT
import 'ai_logic.dart';

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
        scaffoldBackgroundColor: Colors.black, // ✅ Global Black Background
        canvasColor: Colors.black, // ✅ Drawer Black
        primaryColor: const Color(0xFFCCFF00),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: GoogleFonts.outfitTextTheme(
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
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _blurAnim = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
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
                      sigmaX: _blurAnim.value,
                      sigmaY: _blurAnim.value,
                    ),
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.code,
                            size: 90,
                            color: Color(0xFFCCFF00),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "CodeNetra",
                            style: GoogleFonts.outfit(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Own Your Code.",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              color: Colors.grey,
                              letterSpacing: 2.0,
                            ),
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
                        horizontal: 50,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFF00),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCCFF00).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 2. MAIN LAYOUT (The Core Navigator)
// =============================================================================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _changeScreen(int index) {
    setState(() => _selectedIndex = index);
    if (MediaQuery.of(context).size.width <= 800) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Yaha saare pages hain
    final List<Widget> screens = [
      HomeScreen(onNavigate: _changeScreen), // Index 0
      const ChatScreen(), // Index 1 (Chat)
      const TemplatesScreen(), // Index 2
      const PDFScreen(), // Index 3
      const ImageGenScreen(), // Index 4 (Image)
      const CodeExpertScreen(), // Index 5
      const VoiceScreen(), // Index 6
      const UpgradeScreen(), // Index 7
    ];

    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black, // ✅ FORCE BLACK BACKGROUND
      extendBodyBehindAppBar: true,
      appBar: !isWideScreen
          ? AppBar(
              backgroundColor: Colors.black, // ✅ AppBar bhi Black
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "CodeNetra",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            )
          : null,
      drawer: !isWideScreen
          ? Drawer(
              backgroundColor: Colors.black,
              child: SidebarContent(
                selectedIndex: _selectedIndex,
                onTap: _changeScreen,
              ),
            )
          : null,
      body: Container(
        color: Colors.black, // ✅ Body bhi Black (Double Safety)
        child: Row(
          children: [
            if (isWideScreen)
              Container(
                width: 280,
                color: Colors.black,
                child: SidebarContent(
                  selectedIndex: _selectedIndex,
                  onTap: _changeScreen,
                ),
              ),
            Expanded(child: screens[_selectedIndex]), // ✅ Content Yaha Badlega
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
  const SidebarContent({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

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
              Text(
                "CodeNetra",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
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
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    ),
  );
  Widget _btn(
    String title,
    IconData icon,
    int index, {
    bool isHighlight = false,
  }) {
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
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected || isHighlight
                  ? const Color(0xFFCCFF00)
                  : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: isSelected || isHighlight ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
      color: Colors.black, // ✅ FIX: Force Black Background
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Hello, Developer 👋",
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "How can CodeNetra help today?",
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 40),

              // ✅ CARD 1: Talk (Navigates to Index 1)
              GestureDetector(
                onTap: () {
                  print("Navigating to Chat..."); // Debug Log
                  onNavigate(1);
                },
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
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.mic, color: Colors.black, size: 32),
                          Icon(
                            Icons.arrow_outward,
                            color: Colors.black,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Talk with CodeNetra",
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Powered by Google Gemini",
                        style: GoogleFonts.outfit(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ✅ CARD 2: Image (Navigates to Index 4)
              GestureDetector(
                onTap: () {
                  print("Navigating to Image..."); // Debug Log
                  onNavigate(4);
                },
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0CFFC),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.image,
                            color: Colors.black,
                            size: 28,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Text to Image",
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Generate Assets",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
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
// 4. CHAT SCREEN
// =============================================================================
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final AIBrain _aiBrain = AIBrain();

  @override
  void initState() {
    super.initState();
    _aiBrain.initBrain();
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    String userText = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _controller.clear();
      _isTyping = true;
    });
    Future.delayed(
      const Duration(milliseconds: 100),
      () =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
    );
    String? aiResponse = await _aiBrain.askLaravel(userText);
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          "role": "ai",
          "text": aiResponse ?? "Could not connect to Brain.",
        });
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // ✅ FIX: Force Black Background
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 40,
                            color: Color(0xFFCCFF00),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Ask CodeNetra anything...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length)
                        return Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Text(
                            "CodeNetra thinking...",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFCCFF00),
                              fontSize: 12,
                            ),
                          ),
                        );
                      final isUser = _messages[index]['role'] == "user";
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFFCCFF00)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(25),
                              topRight: const Radius.circular(25),
                              bottomLeft: isUser
                                  ? const Radius.circular(25)
                                  : Radius.zero,
                              bottomRight: isUser
                                  ? Radius.zero
                                  : const Radius.circular(25),
                            ),
                          ),
                          child: Text(
                            _messages[index]['text']!,
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.volume_off, color: Colors.grey),
                    onPressed: () => _aiBrain.stopSpeaking(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFCCFF00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      color: Colors.black, // ✅ Force Black
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
                  "Product Desc",
                  Icons.shopping_bag,
                  Colors.purple,
                ),
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
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 25,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
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
      color: Colors.black, // ✅ Force Black
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
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: Colors.red, size: 10),
                      SizedBox(width: 5),
                      Icon(Icons.circle, color: Colors.yellow, size: 10),
                      SizedBox(width: 5),
                      Icon(Icons.circle, color: Colors.green, size: 10),
                      Spacer(),
                      Text("main.py", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        "def win_hackathon(team):\n if team == 'CodeNetra':\n rank = 1\n print('Judges are impressed!')\n return rank\n else:\n return 'Try again'\n\n# Paste your buggy code here...",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFFCCFF00),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
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
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: const [
                Icon(Icons.attachment, color: Colors.grey),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Ask about this code...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Color(0xFFCCFF00),
                  radius: 18,
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 7. OTHER SCREENS
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select File",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.grey),
                Expanded(
                  child: ListView(
                    children: [
                      _fileItem(
                        "Project.zip",
                        "12 MB",
                        Icons.folder_zip,
                        Colors.orange,
                      ),
                      _fileItem(
                        "Notes.pdf",
                        "2.5 MB",
                        Icons.picture_as_pdf,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      },
    );
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
              Icon(
                Icons.cloud_upload_outlined,
                size: 80,
                color: const Color(0xFFCCFF00),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upload PDF or ZIP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openFileGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                icon: const Icon(Icons.folder_open),
                label: const Text("Select File"),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              color: const Color(0xFF1F1F1F),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Color(0xFFCCFF00)),
                  const SizedBox(width: 10),
                  Text(
                    uploadedFileName!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => setState(() => isFileUploaded = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Analyzing $uploadedFileName...",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Ask about file...",
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
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
      color: Colors.black, // ✅ Force Black
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
                border: Border.all(color: Colors.white10),
              ),
              child: isGenerating
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFCCFF00),
                      ),
                    )
                  : imageGenerated
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "https://picsum.photos/600/600",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.download,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.image, size: 60, color: Colors.white12),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cyberpunk city...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _generateImage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCFF00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // ✅ Force Black
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFF00).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFCCFF00).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCCFF00).withOpacity(0.2),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic,
                          size: 40,
                          color: Color(0xFFCCFF00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type text...",
                    filled: true,
                    fillColor: const Color(0xFF1F1F1F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCFF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 80,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Generate Voice"),
                ),
              ],
            ),
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
      color: Colors.black, // ✅ Force Black
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
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Free",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "\$0",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text("• Gemini 1.5 Flash"),
                  Text("• 10 Chats/day"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pro",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          "RANK 1",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "\$19",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "• Gemini 1.5 Pro (Best)",
                    style: TextStyle(color: Colors.black),
                  ),
                  const Text(
                    "• Unlimited Image Gen",
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Upgrade Now",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
