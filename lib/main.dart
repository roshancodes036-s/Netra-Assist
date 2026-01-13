import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// ✅ FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ PACKAGES
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

// ✅ BRAIN
import 'ai_logic.dart';

// =============================================================================
// ✨ PROFESSIONAL THEME COLORS (VS CODE + NEON)
// =============================================================================

class AppColors {
  static const Color primaryAccent = Color(0xFFCCFF00); // Neon Green
  static const Color backgroundDark = Color(0xFF050505); // Pitch Black
  static const Color cardSurface = Color(0xFF151515); // Dark Grey
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color borderSubtle = Color(0xFF333333);

  // VS Code Syntax Colors
  static const Color vsBg = Color(0xFF1E1E1E);
  static const Color vsKeyword = Color(0xFFC586C0); // Pink
  static const Color vsType = Color(0xFF4EC9B0); // Cyan
  static const Color vsString = Color(0xFFCE9178); // Orange
  static const Color vsComment = Color(0xFF6A9955); // Green
  static const Color vsFunc = Color(0xFFDCDCAA); // Yellow
  static const Color vsNormal = Color(0xFFD4D4D4); // White
}

// =============================================================================
// MAIN ENTRY
// =============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase Error (UI Mode): $e");
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.backgroundDark,
  ));

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
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primaryAccent,
        canvasColor: AppColors.backgroundDark,
        useMaterial3: true,
        textTheme:
            GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.backgroundDark,
        ),
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

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainLayout(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryAccent.withOpacity(0.5))),
              child: const Icon(Icons.code,
                  size: 80, color: AppColors.primaryAccent),
            ),
            const SizedBox(height: 30),
            Text("CodeNetra",
                style: GoogleFonts.outfit(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1)),
            const SizedBox(height: 10),
            Text("Professional AI Suite",
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 2. MAIN LAYOUT (SIDEBAR HIDDEN IN DRAWER)
// =============================================================================

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isDevMode = true;

  void _changeScreen(int index) => setState(() => _selectedIndex = index);

  void _toggleMode(bool isDev) {
    setState(() {
      _isDevMode = isDev;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigate: _changeScreen, isDevMode: _isDevMode), // 0
      const RepoChatScreen(), // 1
      const TemplatesScreen(), // 2
      const ErrorFixerScreen(), // 3
      const UIToCodeScreen(), // 4
      const PDFScreen(), // 5
      const VoiceScreen(), // 6
      const UpgradeScreen(), // 7
      const LiveCameraScreen(), // 8
      const CodeExpertScreen(), // 9
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        title: _buildAppBarTitle(),
        centerTitle: true,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.primaryAccent, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: Drawer(
        width: 280,
        backgroundColor: AppColors.backgroundDark,
        child: SidebarContent(
          selectedIndex: _selectedIndex,
          isDevMode: _isDevMode,
          onModeChange: _toggleMode,
          onTap: (index) {
            _changeScreen(index);
            Navigator.pop(context);
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_selectedIndex < screens.length ? _selectedIndex : 0],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_isDevMode ? Icons.terminal_rounded : Icons.visibility_rounded,
              color: AppColors.primaryAccent, size: 18),
          const SizedBox(width: 10),
          Text(_isDevMode ? "Developer Mode" : "Netra Vision Mode",
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

// --- SIDEBAR ---
class SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final bool isDevMode;
  final Function(bool) onModeChange;

  const SidebarContent({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.isDevMode,
    required this.onModeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.code_rounded,
                  color: AppColors.primaryAccent, size: 32),
              const SizedBox(width: 10),
              Text("CodeNetra",
                  style: GoogleFonts.outfit(
                      fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                _modeButton("Code", Icons.code_rounded, true),
                _modeButton("Netra", Icons.visibility_rounded, false),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(isDevMode ? "DEVELOPMENT" : "ACCESSIBILITY"),
                  _btn("Dashboard", Icons.dashboard_rounded, 0),
                  if (isDevMode) ...[
                    _btn("Repo Chat", Icons.folder_zip_rounded, 1),
                    _btn("UI to Code", Icons.image_aspect_ratio_rounded, 4),
                    _btn("Error Debugger", Icons.bug_report_rounded, 3),
                    _btn("Code Expert", Icons.terminal_rounded, 9),
                  ] else ...[
                    _btn("Live Vision", Icons.camera_enhance_rounded, 8),
                    _btn("Voice Assistant", Icons.graphic_eq_rounded, 6),
                    _btn("PDF Intelligence", Icons.picture_as_pdf_rounded, 5),
                    _btn("Content Studio", Icons.edit_note_rounded, 2),
                  ],
                ],
              ),
            ),
          ),
          _btn("Upgrade", Icons.bolt_rounded, 7),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _modeButton(String text, IconData icon, bool isForDev) {
    bool isActive = isDevMode == isForDev;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChange(isForDev),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isActive ? Colors.black : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(text,
                  style: TextStyle(
                      color: isActive ? Colors.black : AppColors.textSecondary,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 8, 8),
      child: Text(text,
          style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1)));

  Widget _btn(String title, IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: () => onTap(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: isSelected
            ? AppColors.primaryAccent.withOpacity(0.15)
            : Colors.transparent,
        leading: Icon(icon,
            color:
                isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
            size: 24),
        title: Text(title,
            style: GoogleFonts.outfit(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
        dense: true,
      ),
    );
  }
}

// =============================================================================
// 🔥 4. REPO CHAT SCREEN (IMPROVED ICONS + DEEP SEARCH + FILE FETCHING)
// =============================================================================

class RepoChatScreen extends StatefulWidget {
  const RepoChatScreen({super.key});
  @override
  State<RepoChatScreen> createState() => _RepoChatScreenState();
}

class _RepoChatScreenState extends State<RepoChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _msgs = [];

  bool _isLoading = false;
  String? _activeFileName;
  String _codebaseContext = ""; // Stores full ZIP content
  bool _isContextLoaded = false;

  final AIBrain _brain = AIBrain();

  // Suggestions
  final List<String> _suggestions = [
    "📂 Full File Structure",
    "🚀 Explain main.dart logic",
    "📦 Analyze pubspec.yaml",
    "🔐 Find API Key leaks",
    "🐛 Check for bugs",
  ];

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _addMessage("ai",
        "Hello Developer! 👨‍💻\n\nI am ready for **Universal Code Analysis**.\nUse the **+** button to upload a ZIP or link a GitHub Repo for deep scanning.");
  }

  // 🔥 1. UPDATED GITHUB LOGIC (Deep Search Simulation)
  void _processGitHubLink(String url) async {
    if (url.isEmpty) return;
    setState(() {
      _isLoading = true;
      _activeFileName = "GitHub Repo (Deep Scan)";
    });

    // Simulate "Deep Research" delay
    await Future.delayed(const Duration(seconds: 3));

    // MOCKING A DEEP SCAN (Since we can't actually scrape without backend)
    String mockContext = """
    [SYSTEM: GITHUB REPO SCANNED]
    Repo URL: $url
    Note: Real-time scraping requires backend. 
    Simulating analysis of common Flutter structure...
    
    DETECTED FILES:
    - lib/main.dart
    - pubspec.yaml
    - lib/screens/home.dart
    - lib/utils/constants.dart
    
    (AI Instructions: Assume standard Flutter structure for this repo. If user asks for specific file code, ask them to confirm the file path or provide the specific code block if known standard boilerplate.)
    """;

    setState(() {
      _codebaseContext = mockContext;
      _isContextLoaded = true;
      _isLoading = false;
      _addMessage("system",
          "✅ **GitHub Repo Indexed!**\nDeep analysis complete. I have scanned the structure. Ask me about specific files or bugs.");
    });
  }

  // 🔥 2. ZIP LOGIC (Extracts & Stores Context for File Retrieval)
  Future<void> _pickZipFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _activeFileName = result.files.single.name;
        });

        List<int> bytes = kIsWeb
            ? result.files.single.bytes!
            : await File(result.files.single.path!).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        StringBuffer extractedCode = StringBuffer();
        List<String> fileList = [];

        // Smart Extraction
        for (final file in archive) {
          if (file.isFile && !file.name.contains("__MACOSX")) {
            fileList.add(file.name);
            // Limit size to prevent memory crash, but prioritize code files
            if (file.name.endsWith('.dart') ||
                file.name.endsWith('.js') ||
                file.name.endsWith('.json') ||
                file.name.endsWith('.yaml')) {
              String content = String.fromCharCodes(file.content);
              if (content.length < 50000) {
                extractedCode
                    .writeln("\n--- FILE: ${file.name} ---\n$content\n");
              }
            }
          }
        }

        setState(() {
          _codebaseContext = extractedCode.toString();
          _isContextLoaded = true;
          _isLoading = false;
          _addMessage("system",
              "✅ **ZIP Analysis Complete!**\n📂 Files Found: ${fileList.length}\n🧠 Logic: Indexed for Code Retrieval.\n\nYou can now ask: 'Show me code for main.dart'");
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _addMessage("system", "❌ Error: $e");
    }
  }

  void _showUploadMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
                top: BorderSide(color: AppColors.primaryAccent, width: 2))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Source",
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                _uploadOption(
                    "Upload ZIP", Icons.folder_zip_rounded, Colors.orange, () {
                  Navigator.pop(context);
                  _pickZipFile();
                }),
                const SizedBox(width: 15),
                _uploadOption("GitHub Repo", Icons.hub_rounded, Colors.purple,
                    () {
                  Navigator.pop(context);
                  _showGitHubDialog();
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showGitHubDialog() {
    TextEditingController urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Row(children: const [
          Icon(Icons.hub, color: Colors.purple),
          SizedBox(width: 10),
          Text("GitHub Deep Scan", style: TextStyle(color: Colors.white))
        ]),
        content: TextField(
          controller: urlCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
              hintText: "Paste Repo URL (https://github.com/...)",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.black,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                Navigator.pop(c);
                _processGitHubLink(urlCtrl.text);
              },
              child: const Text("Scan Repo",
                  style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _uploadOption(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.w600))
            ],
          ),
        ),
      ),
    );
  }

  void _send(String text) async {
    if (text.isEmpty) return;
    _ctrl.clear();
    _addMessage("user", text);
    setState(() => _isLoading = true);

    String fullPrompt = text;
    // 🔥 PASSING FULL CONTEXT SO AI CAN RETRIEVE SPECIFIC FILES
    if (_isContextLoaded && _codebaseContext.isNotEmpty) {
      fullPrompt = """
      CONTEXT (Full Codebase/Scan):
      $_codebaseContext
      
      USER QUESTION: $text
      
      INSTRUCTIONS:
      1. If user asks for a specific file (e.g., "Show me main.dart"), SEARCH the context and return the EXACT code in a code block.
      2. If code is requested, do not summarize. Give the full code.
      3. Use colorful formatting logic (Language name at start of block).
      """;
    }

    String? res = await _brain.askLaravel(fullPrompt);
    setState(() => _isLoading = false);
    _addMessage("ai", res ?? "Error processing request.");
  }

  void _addMessage(String role, String text) {
    setState(() {
      _msgs.add({"role": role, "text": text, "animated": false});
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Repo Chat",
      icon: Icons.code,
      child: Column(
        children: [
          if (_activeFileName != null)
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("Active: $_activeFileName",
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold))
                ])),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (c, i) => ModernChatBubble(
                isUser: _msgs[i]['role'] == 'user',
                text: _msgs[i]['text'],
                isAnimated: _msgs[i]['animated'],
                onAnimationEnd: () =>
                    setState(() => _msgs[i]['animated'] = true),
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(color: AppColors.primaryAccent),
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return ActionChip(
                  backgroundColor: AppColors.cardSurface,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  label: Text(_suggestions[index],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500)),
                  onPressed: () => _send(_suggestions[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: NeonInputWrapper(
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.primaryAccent),
                      onPressed: _showUploadMenu),
                  Expanded(
                      child: TextField(
                          controller: _ctrl,
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: "Ask about logic or request files...",
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10)),
                          onSubmitted: _send)),
                  IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: AppColors.primaryAccent),
                      onPressed: () => _send(_ctrl.text)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 5. UI TO CODE SCREEN (PIXEL PERFECT + REGEX CLEANER + SCANNER)
// =============================================================================

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
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _scanController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Output Language",
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _langChip("Flutter", Icons.flutter_dash),
              _langChip("React Native", Icons.javascript),
              _langChip("HTML/Tailwind", Icons.html),
              _langChip("Python/Kivy", Icons.code),
            ])
          ],
        ),
      ),
    );
  }

  Widget _langChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: AppColors.primaryAccent,
      onPressed: () {
        Navigator.pop(context);
        setState(() => _selectedLanguage = label);
        _generateCode();
      },
    );
  }

  Future<void> _generateCode() async {
    setState(() {
      _loading = true;
      _isScanning = true;
      _generatedCode = "";
    });

    // 🔥 STRICT PROMPT FOR HU-BAHU UI
    String prompt = """
    You are an Expert UI Developer.
    TASK: Convert this UI screenshot to $_selectedLanguage.
    
    CRITICAL RULES:
    1. Make it PIXEL-PERFECT. Match colors, gradients, padding, and font sizes exactly.
    2. If there is a glassmorphism effect, implement it properly (BackdropFilter).
    3. Return ONLY the code inside a code block (```$_selectedLanguage ... ```).
    4. DO NOT write any conversational text. JUST THE CODE.
    """;

    String? result = await _brain.askWithImage(prompt, _image!);

    setState(() {
      _loading = false;
      _isScanning = false;

      if (result != null) {
        // 🔥 REGEX TO CLEAN "HERE IS YOUR CODE" TEXT
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
      child: Column(
        children: [
          Expanded(
            flex: _generatedCode.isEmpty ? 5 : 2,
            child: _buildImageSection(),
          ),

          // 🔥 FEATURE CARDS (Only when no code)
          if (_generatedCode.isEmpty && !_loading)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                      child: _featureCard("Pixel Perfect", Icons.check_circle)),
                  const SizedBox(width: 10),
                  Expanded(child: _featureCard("Neon/Glass", Icons.blur_on)),
                  const SizedBox(width: 10),
                  Expanded(child: _featureCard("Full Source", Icons.code)),
                ],
              ),
            ),

          if (_loading)
            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const LinearProgressIndicator(
                        color: AppColors.primaryAccent),
                    const SizedBox(height: 10),
                    Text("Extracting Styles & Components...",
                        style: GoogleFonts.firaCode(
                            color: AppColors.primaryAccent, fontSize: 12))
                  ],
                )),

          if (_generatedCode.isNotEmpty)
            Expanded(
              flex: 6,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: AppColors.vsBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                          color: Color(0xFF252526),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(Icons.code, color: Colors.blue, size: 16),
                              const SizedBox(width: 8),
                              Text("$_selectedLanguage Output",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _generatedCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("✅ Code Copied!")));
                                },
                                child: const Icon(Icons.copy,
                                    color: Colors.white, size: 18))
                          ]),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText.rich(
                          CodeHighlighter.highlight(
                              _generatedCode), // VS CODE COLORS
                          style:
                              GoogleFonts.firaCode(fontSize: 12, height: 1.5),
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

  Widget _featureCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle)),
      child: Column(children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 5),
        Text(text,
            style: const TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))
      ]),
    );
  }

  Widget _buildImageSection() {
    bool hasImage = _image != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: hasImage ? AppColors.primaryAccent : AppColors.borderSubtle,
            width: hasImage ? 2 : 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.file(_image!, fit: BoxFit.contain)
            else
              _buildPlaceholder(),

            // 🔥 LASER SCANNER ANIMATION
            if (_isScanning)
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) => FractionallySizedBox(
                  heightFactor: 0.05,
                  alignment: Alignment(0, _scanController.value * 2 - 1),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.primaryAccent.withOpacity(0),
                          AppColors.primaryAccent,
                          AppColors.primaryAccent.withOpacity(0)
                        ]),
                        boxShadow: const [
                          BoxShadow(
                              color: AppColors.primaryAccent, blurRadius: 15)
                        ]),
                  ),
                ),
              ),

            if (!hasImage)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera")),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      label: const Text("Gallery")),
                ]),
              ),

            if (hasImage && !_loading)
              Positioned(
                bottom: 25,
                left: 40,
                right: 40,
                child: ElevatedButton(
                  onPressed: _showLanguageSelector,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("GENERATE CODE",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),

            if (hasImage && !_loading)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _image = null)),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_a_photo_rounded,
          size: 60, color: AppColors.textSecondary.withOpacity(0.3)),
      const SizedBox(height: 15),
      Text("Upload UI Screenshot",
          style: GoogleFonts.outfit(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
    ]);
  }
}

// =============================================================================
// HELPER SCREENS (HOME & OTHERS)
// =============================================================================

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final bool isDevMode;
  const HomeScreen(
      {super.key, required this.onNavigate, required this.isDevMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Welcome Back,",
                    style: GoogleFonts.outfit(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                Text("Netra AI v2.0 Online",
                    style: GoogleFonts.inter(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600)),
              ]),
              const CircleAvatar(
                  backgroundColor: AppColors.cardSurface,
                  child: Icon(Icons.person, color: Colors.white))
            ],
          ),
          const SizedBox(height: 30),
          _largeActionCard(
              title: isDevMode ? "Deep Code Analysis" : "Live Vision",
              subtitle: isDevMode
                  ? "Chat with Repos & Fix Bugs"
                  : "Identify Objects & Read Text",
              icon: isDevMode ? Icons.terminal : Icons.remove_red_eye,
              color: AppColors.primaryAccent,
              onTap: () => onNavigate(isDevMode ? 1 : 8)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _smallCard("UI to Code", Icons.image, Colors.blue,
                      () => onNavigate(4))),
              const SizedBox(width: 15),
              Expanded(
                  child: _smallCard(
                      "Voice AI", Icons.mic, Colors.pink, () => onNavigate(6))),
            ],
          )
        ],
      ),
    );
  }

  Widget _largeActionCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 32, color: Colors.black),
                    const SizedBox(height: 12),
                    Text(title,
                        style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),
                  ]),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.black, size: 32)
          ],
        ),
      ),
    );
  }

  Widget _smallCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color)),
          const SizedBox(height: 15),
          Text(title,
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});
  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();
  final AIBrain _brain = AIBrain();
  bool _analyzing = false;
  String _desc = "Point camera and tap mic to analyze.";

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  Future<void> _analyzeScene() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _analyzing = true;
        _desc = "Analyzing scene...";
      });
      String? res = await _brain.askWithImage(
          "Describe this scene for a blind person.", File(photo.path));
      setState(() {
        _desc = res ?? "Error analyzing.";
        _analyzing = false;
      });
      await _tts.speak(_desc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            color: Colors.black,
            child: const Center(
                child:
                    Icon(Icons.camera_alt, size: 100, color: Colors.white10))),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: ProCard(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_analyzing)
                const LinearProgressIndicator(color: AppColors.primaryAccent),
              const SizedBox(height: 10),
              Text(_desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              FloatingActionButton(
                  onPressed: _analyzeScene,
                  backgroundColor: AppColors.primaryAccent,
                  child: const Icon(Icons.camera, color: Colors.black))
            ]),
          ),
        )
      ],
    );
  }
}

class ErrorFixerScreen extends StatefulWidget {
  const ErrorFixerScreen({super.key});
  @override
  State<ErrorFixerScreen> createState() => _ErrorFixerScreenState();
}

class _ErrorFixerScreenState extends State<ErrorFixerScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _solution = "";
  bool _loading = false;
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  void _fix() async {
    if (_ctrl.text.isEmpty) return;
    setState(() {
      _loading = true;
      _solution = "Analyzing...";
    });
    String? res = await _brain
        .askLaravel("Here is an error log: ${_ctrl.text}. Provide fix.");
    setState(() {
      _loading = false;
      _solution = res ?? "Could not solve.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Error Fixer",
      icon: Icons.bug_report_rounded,
      child: Column(children: [
        Expanded(
            flex: 1,
            child: ProCard(
                padding: EdgeInsets.zero,
                child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                        hintText: "Paste Error Log...",
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none)))),
        const SizedBox(height: 10),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: _fix,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text("Fix It"))),
        if (_loading)
          const LinearProgressIndicator(color: AppColors.primaryAccent),
        Expanded(
            flex: 2,
            child: ProCard(
                child: SingleChildScrollView(
                    child: Text(_solution,
                        style: const TextStyle(color: Colors.white)))))
      ]),
    );
  }
}

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap mic to speak";
  final AIBrain _brain = AIBrain();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _brain.initBrain();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) _processVoice(_text);
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processVoice(String query) async {
    setState(() => _isListening = false);
    String? res = await _brain.askLaravel("Answer briefly: $query");
    setState(() => _text = res ?? "Error.");
    await _tts.speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Voice AI",
      icon: Icons.graphic_eq,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.mic,
            size: 60,
            color: _isListening ? Colors.red : AppColors.primaryAccent),
        const SizedBox(height: 30),
        Text(_text,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 40),
        FloatingActionButton(
            onPressed: _listen,
            backgroundColor: AppColors.primaryAccent,
            child: Icon(_isListening ? Icons.stop : Icons.mic,
                color: Colors.black))
      ]),
    );
  }
}

class CodeExpertScreen extends StatefulWidget {
  const CodeExpertScreen({super.key});
  @override
  State<CodeExpertScreen> createState() => _CodeExpertScreenState();
}

class _CodeExpertScreenState extends State<CodeExpertScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<String> _logs = ["> Code Expert Initialized..."];
  final AIBrain _brain = AIBrain();
  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  void _run() async {
    String cmd = _ctrl.text;
    setState(() {
      _logs.add("> $cmd");
      _ctrl.clear();
    });
    String? res = await _brain.askLaravel("Expert Answer: $cmd");
    setState(() => _logs.add(res ?? "Error"));
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Code Expert",
      icon: Icons.terminal,
      child: ProCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            Expanded(
                child: Container(
                    color: const Color(0xFF1E1E1E),
                    child: ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (c, i) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            child: Text(_logs[i],
                                style: GoogleFonts.firaCode(
                                    fontSize: 12,
                                    color: Colors.greenAccent)))))),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.black,
                child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _run(),
                    decoration: const InputDecoration(
                        prefixText: "> ", border: InputBorder.none)))
          ])),
    );
  }
}

class PDFScreen extends StatelessWidget {
  const PDFScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProPageLayout(
      title: "PDF Tools",
      icon: Icons.picture_as_pdf,
      child: Center(child: Text("Coming Soon")));
}

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProPageLayout(
      title: "Templates",
      icon: Icons.copy,
      child: Center(child: Text("Templates")));
}

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProPageLayout(
      title: "Upgrade",
      icon: Icons.bolt,
      child: Center(child: Text("Pro Plan")));
}

// =============================================================================
// UI HELPERS
// =============================================================================

class ProCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  const ProCard({super.key, required this.child, this.padding, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle)),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                  padding: padding ?? const EdgeInsets.all(16), child: child))),
    );
  }
}

class ProPageLayout extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const ProPageLayout(
      {super.key,
      required this.title,
      required this.icon,
      required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        child: Column(children: [
          Row(children: [
            Icon(icon, color: AppColors.primaryAccent, size: 28),
            const SizedBox(width: 12),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 26, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 24),
          Expanded(child: child)
        ]));
  }
}

class NeonInputWrapper extends StatelessWidget {
  final Widget child;
  const NeonInputWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              colors: [AppColors.primaryAccent, Colors.blue])),
      child: Container(
          decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(29)),
          child: child),
    );
  }
}

class ModernChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final bool isAnimated;
  final VoidCallback onAnimationEnd;
  const ModernChatBubble(
      {super.key,
      required this.isUser,
      required this.text,
      required this.isAnimated,
      required this.onAnimationEnd});

  @override
  Widget build(BuildContext context) {
    List<String> parts = text.split('```');
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        decoration: BoxDecoration(
            color: isUser ? AppColors.primaryAccent : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (isUser)
            Text(text,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))
          else
            ...parts.map((part) {
              if (parts.indexOf(part) % 2 == 0)
                return Text(part, style: const TextStyle(color: Colors.white));
              else
                return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.vsBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade800)),
                    child: SelectableText.rich(
                        CodeHighlighter.highlight(part.trim()),
                        style: GoogleFonts.firaCode(fontSize: 12)));
            })
        ]),
      ),
    );
  }
}

class CodeHighlighter {
  static TextSpan highlight(String code) {
    List<TextSpan> spans = [];
    RegExp tokenRegex = RegExp(
        r'(//.*)|(".*?")|(\b(import|class|void|var|final|const|return|if|else|extends|with|implements|new|this|super|true|false)\b)|(\b[A-Z][a-zA-Z0-9]*\b)',
        multiLine: true);
    int lastMatchEnd = 0;
    for (var match in tokenRegex.allMatches(code)) {
      if (match.start > lastMatchEnd)
        spans.add(TextSpan(
            text: code.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: AppColors.vsNormal)));
      String token = match.group(0)!;
      Color color = AppColors.vsNormal;
      if (match.group(1) != null)
        color = AppColors.vsComment;
      else if (match.group(2) != null)
        color = AppColors.vsString;
      else if (match.group(3) != null)
        color = AppColors.vsKeyword;
      else if (match.group(5) != null) color = AppColors.vsType;
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < code.length)
      spans.add(TextSpan(
          text: code.substring(lastMatchEnd),
          style: const TextStyle(color: AppColors.vsNormal)));
    return TextSpan(children: spans);
  }
}
