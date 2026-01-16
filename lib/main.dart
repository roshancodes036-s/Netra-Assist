import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

// ✅ BRAIN (External File)
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
                  fontSize: 16,
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
                      fontSize: 26, fontWeight: FontWeight.w800)),
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
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
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
              fontSize: 12,
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 16)),
        dense: true,
      ),
    );
  }
}

// =============================================================================
// 🔥 4. REPO CHAT SCREEN (SMART ZIP ANALYSIS)
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

  // 🔥 SMART CONTEXT VARIABLES
  Map<String, String> _fileContentMap = {}; // Saari files ka code yahan rahega
  List<String> _allFilePaths = []; // Sirf file ke naam structure ke liye
  String _criticalContext =
      ""; // Top 5-6 files ka data jo AI ko pehle bhejna hai
  bool _isContextLoaded = false;

  final AIBrain _brain = AIBrain();

  // Quick Action Chips
  final List<String> _suggestions = [
    "📂 Show Project Structure",
    "📝 List All Features",
    "🐞 Find Bugs in main.dart",
    "💻 Give full main.dart code",
  ];

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _addMessage("ai",
        "Hello Developer! Upload a ZIP. I will auto-analyze the core files instantly.");
  }

  // 🔥 1. SMART ZIP PROCESSOR (The Magic Logic)
  Future<void> _processZipFile(List<int> bytes, String filename) async {
    setState(() {
      _isLoading = true;
      _activeFileName = filename;
      _fileContentMap.clear();
      _allFilePaths.clear();
      _criticalContext = "";
    });

    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      // A. Priority Files List (Jo pehle read karni hain)
      final List<String> priorityFiles = [
        'pubspec.yaml',
        'main.dart',
        'AndroidManifest.xml',
        'Info.plist',
        'package.json',
        'index.js',
        'app.py',
        'requirements.txt',
        'firebase_options.dart',
        'routes.dart'
      ];

      StringBuffer criticalBuffer = StringBuffer();
      int totalFiles = 0;

      // B. Filter & Read Loop
      for (final file in archive) {
        if (file.isFile) {
          String path = file.name;

          // 🚫 JUNK FILTER: Inhe ignore kro speed ke liye
          if (path.contains('node_modules') ||
              path.contains('.git/') ||
              path.contains('build/') ||
              path.contains('.idea/') ||
              path.endsWith('.png') ||
              path.endsWith('.jpg') ||
              path.endsWith('.ttf')) {
            continue;
          }

          _allFilePaths.add(path); // Structure ke liye path save kro
          totalFiles++;

          // File content read kro
          try {
            String content = String.fromCharCodes(file.content as List<int>);
            _fileContentMap[path] = content; // Full map me save kro

            // ✅ CRITICAL FILE CHECK (Sirf 5-6 important files dhundo)
            // Agar file ka naam priority list me hai, ya wo 'lib/' folder me hai (top level)
            bool isPriority = priorityFiles.any((p) => path.endsWith(p));

            // Limit critical context to ~20kb to keep it fast initially
            if (isPriority && criticalBuffer.length < 20000) {
              criticalBuffer.writeln("\n--- FILE: $path ---\n$content\n");
            }
          } catch (e) {
            // Binary file skip
          }
        }
      }

      _criticalContext = criticalBuffer.toString();
      _isContextLoaded = true;

      // C. AI Auto-Summary Request
      String summaryPrompt = """
      ACT AS A SENIOR DEVELOPER.
      I have uploaded a project ZIP.
      
      STATS:
      - Total Files Scanned: $totalFiles
      - Key Files Content Provided Below:
      $_criticalContext
      
      TASK:
      1. Identify the Tech Stack (Flutter/React/Python).
      2. Analyze the 'pubspec.yaml' or dependency file to list Key Features.
      3. Tell me the folder structure briefly.
      
      Reply in short bullet points. Start with "🚀 Project Loaded Successfully!".
      """;

      String? res = await _brain.askLaravel(summaryPrompt);
      setState(() => _isLoading = false);
      _addMessage("ai", res ?? "Project Loaded. Ready to answer questions!");
    } catch (e) {
      setState(() => _isLoading = false);
      _addMessage("system", "Error reading ZIP: $e");
    }
  }

  // File Picker Wrapper
  Future<void> _pickZipFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );

    if (result != null) {
      List<int> bytes = kIsWeb
          ? result.files.single.bytes!
          : await File(result.files.single.path!).readAsBytes();

      _processZipFile(bytes, result.files.single.name);
    }
  }

  // 🔥 2. SMART QUERY HANDLER
  void _send(String text) async {
    if (text.isEmpty) return;
    _ctrl.clear();
    _addMessage("user", text);
    setState(() => _isLoading = true);

    String fullPrompt = "";

    // SCENARIO 1: User asks for STRUCTURE
    if (text.toLowerCase().contains("structure") ||
        text.toLowerCase().contains("folder")) {
      String structureList = _allFilePaths.take(50).join("\n"); // Top 50 files
      fullPrompt = """
      The user is asking about the file structure.
      Here is the list of files in the project:
      $structureList
      
      (If list is truncated, mention there are ${_allFilePaths.length} files total).
      Summarize the architecture.
      """;
    }

    // SCENARIO 2: User asks for FULL CODE of a file (e.g., "main.dart code")
    else if (text.toLowerCase().contains("code") ||
        text.toLowerCase().contains("file")) {
      // Find the requested file in our map
      String? foundFile;
      String? foundContent;

      for (var path in _fileContentMap.keys) {
        // Simple fuzzy match: agar user ne "main.dart" bola aur path me "lib/main.dart" hai
        if (text.toLowerCase().contains(path.split('/').last.toLowerCase())) {
          foundFile = path;
          foundContent = _fileContentMap[path];
          break;
        }
      }

      if (foundContent != null) {
        fullPrompt = """
        The user wants the code for file: $foundFile.
        Here is the FULL CONTENT of that file:
        
        $foundContent
        
        Task: Output the code cleanly in markdown format. Add brief comments explaining what it does.
        """;
      } else {
        // Agar file nahi mili, to critical context bhejo
        fullPrompt = """
        User asked: "$text"
        I could not find a specific file match in the ZIP map.
        Answer based on this Critical Context:
        $_criticalContext
        """;
      }
    }

    // SCENARIO 3: General Question (Features, Logic)
    else {
      fullPrompt = """
      CONTEXT (Key Project Files):
      $_criticalContext
      
      USER QUESTION:
      $text
      
      Answer based on the code provided above.
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
                  Text(
                      "Analyzing: $_activeFileName (${_allFilePaths.length} files)",
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))
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

          // 🔥 Suggestions Scroll
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
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
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
                      onPressed: _pickZipFile), // Direct Zip Pick
                  Expanded(
                      child: TextField(
                          controller: _ctrl,
                          style: GoogleFonts.outfit(
                              color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                              hintText:
                                  "Ask: 'Show structure' or 'Give main.dart'...",
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
// 🔥 5. UI TO CODE SCREEN
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
  late Animation<double> _textAnim;
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _scanController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Output Language",
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    color: Colors.black,
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
      avatar: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 16)),
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
                            color: AppColors.primaryAccent, fontSize: 14))
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
                              Icon(Icons.code, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Text("$_selectedLanguage Output",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
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
                          ]),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText.rich(
                          CodeHighlighter.highlight(
                              _generatedCode), // VS CODE COLORS
                          style:
                              GoogleFonts.firaCode(fontSize: 14, height: 1.5),
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
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(height: 5),
        Text(text,
            style: const TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))
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

            // 🔥 JARVIS LASER SCANNER ANIMATION
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

            if (_isScanning)
              Center(
                child: FadeTransition(
                  opacity: _textAnim,
                  child: Text("CodeNetra Scanning Ui...",
                      style: GoogleFonts.outfit(
                          color: AppColors.primaryAccent.withOpacity(0.8),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
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
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
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
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
    ]);
  }
}

// =============================================================================
// HELPER SCREENS
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
                // 🔥 1. HELLO UPDATE
                Text("Hello, ${isDevMode ? 'Developer' : 'Netra User'}",
                    style: GoogleFonts.outfit(
                        fontSize: 30, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                // 🔥 2. ANIMATED PRO STATUS BADGE (REPLACED v2.0)
                StatusBadge(isDevMode: isDevMode),
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
              if (isDevMode) ...[
                Expanded(
                    child: _smallCard("UI to Code", Icons.image, Colors.blue,
                        () => onNavigate(4))),
                const SizedBox(width: 15),
                Expanded(
                    child: _smallCard("Error Debugger", Icons.bug_report,
                        Colors.red, () => onNavigate(3))),
              ] else ...[
                Expanded(
                    child: _smallCard("Voice AI", Icons.mic, Colors.pink,
                        () => onNavigate(6))),
                const SizedBox(width: 15),
                Expanded(
                    child: _smallCard("PDF Intelligence", Icons.picture_as_pdf,
                        Colors.orange, () => onNavigate(5))),
              ],
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 16,
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
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}

// 🔥 3. NEW ANIMATED BADGE WIDGET FOR HOME PAGE
class StatusBadge extends StatefulWidget {
  final bool isDevMode;
  const StatusBadge({super.key, required this.isDevMode});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blinking Dot
          FadeTransition(
            opacity: _opacity,
            child: const Icon(Icons.circle,
                size: 10, color: AppColors.primaryAccent),
          ),
          const SizedBox(width: 8),

          // Animated Text Switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              widget.isDevMode
                  ? "Ready to Build & Debug 🛠️"
                  : "Vision Intelligence Active 👁️",
              // Key is important for AnimatedSwitcher to know text changed
              key: ValueKey<bool>(widget.isDevMode),
              style: GoogleFonts.firaCode(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 6. LIVE CAMERA & VOICE (CONNECTED TO AI BRAIN)
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
      // Connected to AIBrain
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_analyzing)
                const LinearProgressIndicator(color: AppColors.primaryAccent),
              const SizedBox(height: 10),
              Text(_desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
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
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
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

// =============================================================================
// 🔥 7. ERROR FIXER (UPDATED LOGIC)
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

  void _fixError() async {
    if (_ctrl.text.isEmpty) return;
    FocusScope.of(context).unfocus(); // Close keyboard

    setState(() {
      _loading = true;
      _solution = "🔍 Analyzing Error Stack Trace...";
    });

    // 🔥 UPDATED PROMPT FOR ERRORS
    String prompt = """
    I have a bug in my code. Here is the ERROR LOG:
    ${_ctrl.text}
    
    TASK:
    1. Identify the root cause.
    2. Provide the corrected code snippet.
    3. Explain briefly why this happened.
    """;

    String? res = await _brain.askLaravel(prompt);

    setState(() {
      _loading = false;
      _solution = res ?? "Could not solve this error.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Error Debugger",
      icon: Icons.bug_report_rounded,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // VS Code Dark
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                expands: true,
                style:
                    GoogleFonts.firaCode(color: Colors.redAccent, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Paste your Stack Trace / Error Log here...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _fixError,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_fix_high, color: Colors.black),
              label: Text(_loading ? " DEBUGGING..." : "FIX ERROR",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: _solution.isEmpty
                    ? Center(
                        child: Text("Solution will appear here",
                            style: TextStyle(color: Colors.grey[700])))
                    : SelectableText(
                        _solution,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 15),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 8. CODE EXPERT (UPDATED TO TERMINAL STYLE)
// =============================================================================

class CodeExpertScreen extends StatefulWidget {
  const CodeExpertScreen({super.key});
  @override
  State<CodeExpertScreen> createState() => _CodeExpertScreenState();
}

class _CodeExpertScreenState extends State<CodeExpertScreen> {
  final TextEditingController _ctrl = TextEditingController();
  // Logs for terminal
  final List<String> _logs = [
    "> CodeNetra Expert System Initialized...",
    "> Connected to Gemini 2.5 Flash...",
    "> Waiting for developer query...",
  ];
  final ScrollController _scroll = ScrollController();
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  void _runCommand() async {
    String cmd = _ctrl.text.trim();
    if (cmd.isEmpty) return;

    setState(() {
      _logs.add("\n> developer@codenetra:~\$ $cmd");
      _logs.add("> Processing...");
      _ctrl.clear();
    });

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });

    String prompt =
        "You are a Linux Terminal style coding expert. Answer briefly and technically. Question: $cmd";
    String? res = await _brain.askLaravel(prompt);

    setState(() {
      _logs.removeLast(); // Remove "Processing..."
      _logs.add(res ?? "> Error: Connection failed.");
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Code Expert",
      icon: Icons.terminal,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D), // Pure Terminal Black
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  blurRadius: 20)
            ]),
        child: Column(
          children: [
            // Terminal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1F1F1F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.red, size: 12),
                  const SizedBox(width: 6),
                  const Icon(Icons.circle, color: Colors.amber, size: 12),
                  const SizedBox(width: 6),
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const Spacer(),
                  Text("bash --login",
                      style: GoogleFonts.firaCode(
                          color: Colors.grey, fontSize: 12)),
                  const Spacer(),
                ],
              ),
            ),

            // Logs Area
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SelectableText(
                      _logs[index],
                      style: GoogleFonts.firaCode(
                          color: _logs[index].startsWith(">") ||
                                  _logs[index].startsWith("bash")
                              ? AppColors.primaryAccent
                              : Colors.white,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  );
                },
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white24))),
              child: Row(
                children: [
                  Text("\$",
                      style: GoogleFonts.firaCode(
                          color: AppColors.primaryAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: GoogleFonts.firaCode(
                          color: Colors.white, fontSize: 16),
                      cursorColor: AppColors.primaryAccent,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type command...",
                          hintStyle: TextStyle(color: Colors.white24)),
                      onSubmitted: (_) => _runCommand(),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.send, color: AppColors.primaryAccent),
                    onPressed: _runCommand,
                  )
                ],
              ),
            )
          ],
        ),
      ),
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
                    fontSize: 28, fontWeight: FontWeight.bold))
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
  final VoidCallback? onAnimationEnd;
  const ModernChatBubble(
      {super.key,
      required this.isUser,
      required this.text,
      this.isAnimated = false,
      this.onAnimationEnd});

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
                style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          else
            ...parts.map((part) {
              if (parts.indexOf(part) % 2 == 0)
                return Text(part,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 16));
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
                        style: GoogleFonts.firaCode(fontSize: 14)));
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
