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
// ✨ PROFESSIONAL THEME COLORS
// =============================================================================

class AppColors {
  static const Color primaryAccent = Color(0xFFCCFF00); // Neon Green
  static const Color backgroundDark = Color(0xFF0A0A0A); // Deepest Black
  static const Color cardSurface = Color(0xFF1C1C1C); // Premium Grey Card
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color borderSubtle = Color(0xFF333333);
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
    debugPrint("Firebase Error (Ignored for UI): $e");
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
            GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.code,
                  size: 80, color: AppColors.primaryAccent),
            ),
            const SizedBox(height: 30),
            Text("CodeNetra",
                style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1)),
            const SizedBox(height: 10),
            Text("Professional AI Suite",
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    letterSpacing: 1.5)),
          ],
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
      const RepoChatScreen(), // 1 (ULTIMATE VERSION)
      const TemplatesScreen(), // 2
      const ErrorFixerScreen(), // 3
      const UIToCodeScreen(), // 4 (UPGRADED VERSION)
      const PDFScreen(), // 5
      const VoiceScreen(), // 6
      const UpgradeScreen(), // 7
      const LiveCameraScreen(), // 8
      const CodeExpertScreen(), // 9
    ];

    bool isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        centerTitle: true,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: Drawer(
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
      body: Row(
        children: [
          if (isWide)
            SizedBox(
                width: 280,
                child: SidebarContent(
                    selectedIndex: _selectedIndex,
                    isDevMode: _isDevMode,
                    onModeChange: _toggleMode,
                    onTap: _changeScreen)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  screens[_selectedIndex < screens.length ? _selectedIndex : 0],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_isDevMode ? Icons.terminal_rounded : Icons.visibility_rounded,
              color: AppColors.primaryAccent, size: 18),
          const SizedBox(width: 10),
          Text(_isDevMode ? "Developer Mode" : "Netra Vision Mode",
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.code_rounded,
                  color: AppColors.primaryAccent, size: 28),
              const SizedBox(width: 10),
              Text("CodeNetra",
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive ? Colors.black : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(text,
                  style: TextStyle(
                      color: isActive ? Colors.black : AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(text,
          style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700)));

  Widget _btn(String title, IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () => onTap(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? AppColors.primaryAccent.withOpacity(0.1)
            : Colors.transparent,
        leading: Icon(icon,
            color:
                isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
            size: 22),
        title: Text(title,
            style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
        dense: true,
      ),
    );
  }
}

// =============================================================================
// 3. HOME SCREEN
// =============================================================================

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final bool isDevMode;

  const HomeScreen(
      {super.key, required this.onNavigate, required this.isDevMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isDevMode ? "Hello, Developer." : "Hello, User.",
                      style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w800)),
                  Text(
                      isDevMode
                          ? "Let's build something."
                          : "How can I assist you?",
                      style: GoogleFonts.inter(
                          color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
              const CircleAvatar(
                  backgroundColor: AppColors.cardSurface,
                  child: Icon(Icons.person_rounded,
                      color: AppColors.textSecondary))
            ],
          ),
          const SizedBox(height: 30),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onNavigate(isDevMode ? 1 : 8),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primaryAccent,
                      AppColors.primaryAccent.withOpacity(0.8)
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            isDevMode
                                ? Icons.terminal_rounded
                                : Icons.camera_enhance_rounded,
                            color: Colors.black,
                            size: 28),
                        const SizedBox(height: 20),
                        Text(isDevMode ? "Start Coding" : "Open Live Vision",
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text(
                            isDevMode
                                ? "Repo Chat & Fixes"
                                : "Describe surroundings",
                            style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.black, size: 32)
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Secondary Action Card
          ProCard(
            onTap: () => onNavigate(isDevMode ? 4 : 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(
                      isDevMode
                          ? Icons.image_aspect_ratio_rounded
                          : Icons.graphic_eq_rounded,
                      color: AppColors.primaryAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isDevMode ? "UI to Code" : "Voice Assistant",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(
                          isDevMode
                              ? "Convert designs to Flutter"
                              : "Speak naturally with AI",
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 4. REPO CHAT SCREEN (ULTIMATE: MULTI-LANGUAGE + ACCURATE INDEXING)
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
  String _codebaseContext = "";
  bool _isContextLoaded = false;

  final AIBrain _brain = AIBrain();

  // Sliding Suggestions
  late ScrollController _suggestionsController;
  late Timer _suggestionTimer;
  final List<String> _suggestions = [
    "📦 Analyze pubspec.yaml/package.json",
    "🚀 Explain the main entry point",
    "📂 Show me the full file structure",
    "🔐 Check for API Key leaks",
    "🐛 Find potential bugs",
    "🎨 Identify the Theme/Styles",
  ];

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _suggestionsController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });

    _addMessage("ai",
        "Hello Developer! 👨‍💻\n\nI am ready for **Universal Code Analysis**.\nUpload your ZIP (Flutter, React, Python, or Web), and I will auto-detect the language and scan critical files.");
  }

  void _startAutoScroll() {
    _suggestionTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_suggestionsController.hasClients) {
        double max = _suggestionsController.position.maxScrollExtent;
        double current = _suggestionsController.offset;
        if (current >= max) {
          _suggestionsController.jumpTo(0);
        } else {
          _suggestionsController.jumpTo(current + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _suggestionTimer.cancel();
    _suggestionsController.dispose();
    _scrollController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  // --- 1. SMART ZIP LOGIC (MULTI-LANGUAGE + PRIORITY) ---
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

        List<int> bytes;
        if (kIsWeb) {
          bytes = result.files.single.bytes!;
        } else {
          File file = File(result.files.single.path!);
          bytes = await file.readAsBytes();
        }

        final archive = ZipDecoder().decodeBytes(bytes);
        StringBuffer extractedCode = StringBuffer();
        List<String> allFileNames = [];

        // 1️⃣ STEP 1: INDEXING & LANGUAGE DETECTION
        bool isFlutter = false;
        bool isNodeOrReact = false;
        bool isPython = false;
        bool isWeb = false;

        for (final file in archive) {
          if (file.isFile) {
            if (!file.name.contains("__MACOSX") && !file.name.startsWith(".")) {
              allFileNames.add(file.name);

              // 🕵️ DETECT TECHNOLOGY
              if (file.name.endsWith('pubspec.yaml')) isFlutter = true;
              if (file.name.endsWith('package.json')) isNodeOrReact = true;
              if (file.name.endsWith('requirements.txt') ||
                  file.name.endsWith('pyproject.toml')) isPython = true;
              if (file.name.endsWith('index.html')) isWeb = true;
            }
          }
        }

        // 2️⃣ STEP 2: DEFINE VIP FILES
        String projectType = "Unknown";
        List<String> priorityPatterns = [];

        if (isFlutter) {
          projectType = "Flutter/Dart";
          priorityPatterns = [
            "pubspec.yaml",
            "lib/main.dart",
            "lib/firebase_options.dart",
            "android/app/build.gradle"
          ];
        } else if (isNodeOrReact) {
          projectType = "React Native / Node.js";
          priorityPatterns = [
            "package.json",
            "App.js",
            "App.tsx",
            "src/App.js",
            "index.js",
            "server.js"
          ];
        } else if (isPython) {
          projectType = "Python";
          priorityPatterns = [
            "requirements.txt",
            "app.py",
            "main.py",
            "manage.py",
            "settings.py"
          ];
        } else if (isWeb) {
          projectType = "HTML/Web";
          priorityPatterns = [
            "index.html",
            "style.css",
            "script.js",
            "main.js"
          ];
        } else {
          projectType = "General Code";
          priorityPatterns = ["README.md", "main", "index"];
        }

        // 3️⃣ STEP 3: BUILD PROMPT
        extractedCode.writeln("""
SYSTEM INSTRUCTION: You are an Expert Code Auditor specialized in $projectType.
📊 **PROJECT METADATA:**
- Detected Language: $projectType
- Total Files: ${allFileNames.length}
- File List: ${allFileNames.join(", ")}
🎯 **YOUR GOAL:**
1. Use the 'File List' to answer existence questions.
2. Analyze content below for bugs and logic.
--- BEGIN CRITICAL FILE CONTENT ---
""");

        // 4️⃣ STEP 4: EXTRACT CONTENT (Smart Priority)
        int criticalFilesRead = 0;
        int maxFilesToRead = 30;

        // A. Read VIP Files First
        for (String pattern in priorityPatterns) {
          for (final file in archive) {
            if (file.isFile &&
                (file.name.endsWith(pattern) || file.name == pattern)) {
              _addFileToContext(file, extractedCode);
              criticalFilesRead++;
            }
          }
        }

        // B. Read Other Source Files
        List<String> validExtensions = isFlutter
            ? [".dart", ".yaml"]
            : isNodeOrReact
                ? [".js", ".ts", ".tsx", ".json"]
                : isPython
                    ? [".py", ".txt"]
                    : isWeb
                        ? [".html", ".css", ".js"]
                        : [".txt", ".md"];

        for (final file in archive) {
          if (criticalFilesRead >= maxFilesToRead) break;

          bool isValidExt =
              validExtensions.any((ext) => file.name.endsWith(ext));
          bool isNotAlreadyRead =
              !priorityPatterns.any((p) => file.name.endsWith(p));

          if (file.isFile && isValidExt && isNotAlreadyRead) {
            _addFileToContext(file, extractedCode);
            criticalFilesRead++;
          }
        }

        extractedCode.writeln("\n--- END OF CODEBASE ---");

        setState(() {
          _codebaseContext = extractedCode.toString();
          _isContextLoaded = true;
          _isLoading = false;

          _addMessage("system", """
✅ **Analysis Complete!**
🛠️ **Project Type:** $projectType
📂 **Total Files:** ${allFileNames.length}
🧠 **Analyzed:** $criticalFilesRead critical files.
""");
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _addMessage("system", "❌ Error: $e");
    }
  }

  void _addFileToContext(ArchiveFile file, StringBuffer buffer) {
    try {
      final content = String.fromCharCodes(file.content);
      if (content.length < 30000) {
        buffer.writeln("\n--- FILE: ${file.name} ---\n$content\n");
      }
    } catch (e) {}
  }

  // --- 2. GITHUB LINK LOGIC ---
  void _addGitHubLink() {
    TextEditingController urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text("GitHub Link", style: TextStyle(color: Colors.white)),
        content: const Text(
            "For accurate file counts, please use **Upload ZIP**.\nGitHub links are simulated.",
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))
        ],
      ),
    );
  }

  void _showUploadMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.folder_zip, color: Colors.orange),
                title: const Text("Upload ZIP (Deep Audit)",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Best for file counts & deep checks",
                    style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _pickZipFile();
                }),
            ListTile(
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text("GitHub Link",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Quick remote check",
                    style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _addGitHubLink();
                }),
          ],
        ),
      ),
    );
  }

  // 🔥 UPDATED DEEP ANALYSIS LOGIC
  void _send(String text) async {
    if (text.isEmpty) return;
    _ctrl.clear();
    _addMessage("user", text);
    setState(() => _isLoading = true);

    String fullPrompt = text;

    if (_isContextLoaded && _codebaseContext.isNotEmpty) {
      fullPrompt = """
      CONTEXT START (Full Codebase):
      $_codebaseContext
      CONTEXT END.

      USER QUESTION: $text

      ⚠️ CRITICAL INSTRUCTIONS FOR AI:
      1. You are a Senior Software Architect.
      2. Deeply analyze the code structure above.
      3. If the user asks for code, do NOT summarize. Provide the FULL, CORRECTED FILE content.
      4. Detect logic errors, memory leaks, or bad practices.
      5. Use a professional, authoritative technical tone.
      """;
    }

    String? res = await _brain.askLaravel(fullPrompt);
    setState(() => _isLoading = false);

    if (res != null) {
      _addMessage("ai", res);
    } else {
      _addMessage("ai", "Brain Error.");
    }
  }

  void _addMessage(String role, String text) {
    setState(() {
      _msgs.add({"role": role, "text": text, "animated": false});
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
                padding: const EdgeInsets.all(8),
                color: Colors.green.withOpacity(0.1),
                child: Row(children: [
                  const Icon(Icons.analytics, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("Auditing: $_activeFileName",
                      style: const TextStyle(color: Colors.green))
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
            height: 40,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.builder(
              controller: _suggestionsController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ActionChip(
                    backgroundColor: AppColors.cardSurface,
                    label: Text(_suggestions[index % _suggestions.length],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    onPressed: () =>
                        _send(_suggestions[index % _suggestions.length]),
                  ),
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
                              hintText: "Ask about code structure...",
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
// 🔥 5. UI TO CODE SCREEN (UPGRADED: SCANNER + MULTI-LANGUAGE + FULL CODE)
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
  bool _isScanning = false; // For Scanner Animation
  String _selectedLanguage = "Flutter"; // Default Language
  String _generatedCode = "";

  // Animation Controller for Scanner
  late AnimationController _scanController;
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    // Laser Scanner Animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _generatedCode = "";
          _isScanning = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 🔥 Multi-Language Popup
  void _showLanguageSelector() {
    if (_image == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Output Language",
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Choose the technology for your generated code.",
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 25),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _langOption("Flutter", Icons.flutter_dash),
                  _langOption("React Native", Icons.javascript),
                  _langOption("HTML + Tailwind", Icons.html),
                  _langOption("Python Tkinter", Icons.code),
                  _langOption("Swift UI", Icons.apple),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _langOption(String lang, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.black),
      label: Text(lang,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
      backgroundColor: AppColors.primaryAccent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      onPressed: () {
        Navigator.pop(context);
        setState(() => _selectedLanguage = lang);
        _generateCode(); // Start Generation
      },
    );
  }

  Future<void> _generateCode() async {
    setState(() {
      _loading = true;
      _isScanning = true; // Start Laser
      _generatedCode = "";
    });

    // 🔥 STRONG PROMPT FOR FULL CODE
    String prompt = """
    You are an Expert Senior Developer. 
    Analyze the uploaded UI screenshot pixel-by-pixel.
    
    TARGET LANGUAGE: $_selectedLanguage
    
    TASK: Write the FULL, PRODUCTION-READY code to replicate this UI exactly.
    
    RULES:
    1. Do NOT use placeholders like "Add logic here". Write the full layout logic.
    2. If it's Flutter, use modern Material 3, Google Fonts, and clean architecture.
    3. If it's HTML, use Tailwind CSS classes via CDN for direct preview.
    4. Provide at least 300-500 lines if necessary to make it perfect.
    5. Ensure all buttons, inputs, shadows, and gradients are coded exactly as seen.
    6. Return ONLY the code inside a code block. No explanations.
    """;

    String? result = await _brain.askWithImage(prompt, _image!);

    setState(() {
      _loading = false;
      _isScanning = false; // Stop Laser
      if (result != null) {
        _generatedCode = result
            .replaceAll("```dart", "")
            .replaceAll("```html", "")
            .replaceAll("```", "")
            .trim();
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
          // 1. IMAGE AREA (SCANNER)
          Expanded(
            flex: _generatedCode.isEmpty ? 4 : 2, // Shrink if code is there
            child: _buildImageSection(),
          ),

          // 2. LOADING STATUS
          if (_loading) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primaryAccent, strokeWidth: 2)),
                const SizedBox(width: 15),
                Text("Analyzing Pixels & Writing $_selectedLanguage Code...",
                    style: GoogleFonts.firaCode(
                        color: AppColors.primaryAccent, fontSize: 12)),
              ],
            ),
          ],

          // 3. CODE RESULT AREA (Black Box)
          if (_generatedCode.isNotEmpty)
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F), // Deep Black
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.5), blurRadius: 10)
                    ]),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          border: const Border(
                              bottom:
                                  BorderSide(color: AppColors.borderSubtle))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.code,
                                  color: _getLangColor(), size: 18),
                              const SizedBox(width: 10),
                              Text("$_selectedLanguage Output",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _generatedCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "✅ Full Code Copied! Paste & Run.")));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                children: [
                                  Icon(Icons.copy_all,
                                      size: 16, color: Colors.black),
                                  SizedBox(width: 5),
                                  Text("COPY",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Code Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _generatedCode,
                          style: GoogleFonts.firaCode(
                              color: const Color(0xFFA6E22E), // Monokai Green
                              fontSize: 13,
                              height: 1.4),
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

  Color _getLangColor() {
    if (_selectedLanguage.contains("Flutter")) return Colors.blue;
    if (_selectedLanguage.contains("React")) return Colors.cyan;
    if (_selectedLanguage.contains("HTML")) return Colors.orange;
    return AppColors.primaryAccent;
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
              _buildUploadPlaceholder(),

            // ✨ LASER SCANNER ANIMATION
            if (_isScanning)
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    heightFactor: 0.05, // Laser Height
                    alignment: Alignment(
                        0, _scanController.value * 2 - 1), // Move Top to Bottom
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primaryAccent.withOpacity(0),
                              AppColors.primaryAccent, // Bright Green Center
                              AppColors.primaryAccent.withOpacity(0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primaryAccent,
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                    ),
                  );
                },
              ),

            // BUTTONS
            if (!hasImage)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _uploadBtn("Camera", Icons.camera_alt,
                        () => _pickImage(ImageSource.camera)),
                    const SizedBox(width: 20),
                    _uploadBtn("Gallery", Icons.photo_library,
                        () => _pickImage(ImageSource.gallery)),
                  ],
                ),
              ),

            // MAIN GENERATE BUTTON
            if (hasImage && !_loading)
              Positioned(
                bottom: 25,
                left: 40,
                right: 40,
                child: ElevatedButton(
                  onPressed: _showLanguageSelector,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                    shadowColor: AppColors.primaryAccent.withOpacity(0.6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.black),
                      const SizedBox(width: 10),
                      Text("GENERATE FULL CODE",
                          style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),

            // CANCEL BUTTON
            if (hasImage && !_loading)
              Positioned(
                top: 15,
                right: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.black87,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _image = null),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_rounded,
            size: 70, color: AppColors.textSecondary.withOpacity(0.3)),
        const SizedBox(height: 20),
        Text("Upload UI Design",
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 8),
        Text("Supports: Flutter, React, HTML, Python",
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _uploadBtn(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5)
            ]),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryAccent),
            const SizedBox(width: 10),
            Text(text,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 🔥 6. LIVE VISION (WORKING CAMERA SNAP)
// =============================================================================

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
          "Describe this scene for a blind person in detail.",
          File(photo.path));
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  child: const Icon(Icons.camera, color: Colors.black),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

// =============================================================================
// 🔥 7. ERROR FIXER (WORKING)
// =============================================================================

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
      _solution = "Analyzing stack trace...";
    });
    String? res = await _brain.askLaravel(
        "Here is an error log: ${_ctrl.text}. Explain why it happened and provide the fix code.");
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
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: ProCard(
                padding: EdgeInsets.zero,
                child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                        hintText: "Paste Error Log Here...",
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none))),
          ),
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: _fix,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text("Fix It"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.black))),
          const SizedBox(height: 10),
          if (_loading)
            const LinearProgressIndicator(color: AppColors.primaryAccent),
          Expanded(
            flex: 2,
            child: ProCard(
                child: SingleChildScrollView(
                    child: Text(
                        _solution.isEmpty
                            ? "Solution will appear here."
                            : _solution,
                        style:
                            const TextStyle(color: AppColors.textSecondary)))),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 8. VOICE ASSISTANT (WORKING TTS/STT)
// =============================================================================

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap microphone to speak";
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
            if (val.finalResult) {
              _processVoice(_text);
            }
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
    String? res = await _brain.askLaravel(
        "You are a helpful voice assistant. Answer briefly: $query");
    setState(() => _text = res ?? "Sorry, I didn't get that.");
    await _tts.speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Voice AI",
      icon: Icons.graphic_eq,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: _isListening
                    ? Colors.red.withOpacity(0.2)
                    : AppColors.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(Icons.mic,
                size: 60,
                color: _isListening ? Colors.red : AppColors.primaryAccent),
          ),
          const SizedBox(height: 30),
          Text(_text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 40),
          FloatingActionButton(
              onPressed: _listen,
              backgroundColor: AppColors.primaryAccent,
              child: Icon(_isListening ? Icons.stop : Icons.mic,
                  color: Colors.black))
        ],
      ),
    );
  }
}

// =============================================================================
// OTHER SCREENS
// =============================================================================

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
    String? res = await _brain
        .askLaravel("You are a senior coding expert. Answer this: $cmd");
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
            Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black,
                child: Row(children: const [
                  Icon(Icons.circle, size: 10, color: Colors.red),
                  SizedBox(width: 5),
                  Icon(Icons.circle, size: 10, color: Colors.yellow),
                  SizedBox(width: 5),
                  Icon(Icons.circle, size: 10, color: Colors.green)
                ])),
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
      child: Center(
          child: Text("PDF Logic Coming Soon (Requires complex parsing lib)")));
}

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProPageLayout(
      title: "Templates",
      icon: Icons.edit_note,
      child: Center(child: Text("Templates Gallery Active")));
}

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProPageLayout(
      title: "Upgrade",
      icon: Icons.bolt,
      child: Center(child: Text("Pro Plan: Active")));
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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(children: [
          Row(children: [
            Icon(icon, color: AppColors.primaryAccent),
            const SizedBox(width: 12),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w800))
          ]),
          const SizedBox(height: 24),
          Expanded(child: child)
        ]));
  }
}

// =============================================================================
// ✨ MODERN UI COMPONENTS (BOLD, WHITE, NEON)
// =============================================================================

class NeonInputWrapper extends StatefulWidget {
  final Widget child;
  const NeonInputWrapper({super.key, required this.child});
  @override
  State<NeonInputWrapper> createState() => _NeonInputWrapperState();
}

class _NeonInputWrapperState extends State<NeonInputWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), // ROUNDED
              gradient: SweepGradient(
                colors: const [
                  AppColors.primaryAccent,
                  Colors.transparent,
                  AppColors.primaryAccent
                ],
                transform: GradientRotation(_controller.value * 6.28),
              )),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(28)),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class ModernChatBubble extends StatefulWidget {
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
  State<ModernChatBubble> createState() => _ModernChatBubbleState();
}

class _ModernChatBubbleState extends State<ModernChatBubble> {
  String _displayedText = "";
  late Timer _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isUser || widget.isAnimated) {
      _displayedText = widget.text;
    } else {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted)
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
      } else {
        _timer.cancel();
        widget.onAnimationEnd();
      }
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse for Code Blocks (``` ... ```)
    List<String> parts = _displayedText.split('```');

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        decoration: BoxDecoration(
          color:
              widget.isUser ? AppColors.primaryAccent : AppColors.cardSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: widget.isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight:
                widget.isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isUser)
              Text(_displayedText,
                  style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))
            else
              ...parts.map((part) {
                int index = parts.indexOf(part);
                if (index % 2 == 0) {
                  // Normal Text (BOLD WHITE)
                  return Text(part,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5));
                } else {
                  // Code Block (Colored)
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade800)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("CODE",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10)),
                              InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: part));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Copied!")));
                                  },
                                  child: const Icon(Icons.copy,
                                      color: Colors.white, size: 14))
                            ]),
                        const Divider(color: Colors.grey),
                        Text(part.trim(),
                            style: GoogleFonts.firaCode(
                                color: AppColors.primaryAccent, fontSize: 13)),
                      ],
                    ),
                  );
                }
              }),
          ],
        ),
      ),
    );
  }
}
