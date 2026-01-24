// =============================================================================
// 🔥 CODENETRA AI - FULLY INTEGRATED MAIN.DART
// =============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:ui';

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
import 'package:camera/camera.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ BRAIN (External File)
import 'ai_logic.dart';

// =============================================================================
// ✨ PROFESSIONAL THEME COLORS (VS CODE + NEON)
// =============================================================================

class AppColors {
  static const Color primaryAccent = Color(0xFFCCFF00); // Neon Green
  static const Color backgroundDark = Color(0xFF050505); // Pitch Black
  // 👇 FIXED: Added 'background' alias for compatibility
  static const Color background = Color(0xFF050505);
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
      const TemplatesScreen(), // 2 (Content Studio)
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
  final Map<String, String> _fileContentMap = {};
  final List<String> _allFilePaths = [];
  String _criticalContext = "";
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

      for (final file in archive) {
        if (file.isFile) {
          String path = file.name;

          if (path.contains('node_modules') ||
              path.contains('.git/') ||
              path.contains('build/') ||
              path.contains('.idea/') ||
              path.endsWith('.png') ||
              path.endsWith('.jpg') ||
              path.endsWith('.ttf')) {
            continue;
          }

          _allFilePaths.add(path);
          totalFiles++;

          try {
            String content = String.fromCharCodes(file.content as List<int>);
            _fileContentMap[path] = content;

            bool isPriority = priorityFiles.any((p) => path.endsWith(p));

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

  void _send(String text) async {
    if (text.isEmpty) return;
    _ctrl.clear();
    _addMessage("user", text);
    setState(() => _isLoading = true);

    String fullPrompt = "";

    if (text.toLowerCase().contains("structure") ||
        text.toLowerCase().contains("folder")) {
      String structureList = _allFilePaths.take(50).join("\n");
      fullPrompt = """
      The user is asking about the file structure.
      Here is the list of files in the project:
      $structureList
      
      (If list is truncated, mention there are ${_allFilePaths.length} files total).
      Summarize the architecture.
      """;
    } else if (text.toLowerCase().contains("code") ||
        text.toLowerCase().contains("file")) {
      String? foundFile;
      String? foundContent;

      for (var path in _fileContentMap.keys) {
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
        fullPrompt = """
        User asked: "$text"
        I could not find a specific file match in the ZIP map.
        Answer based on this Critical Context:
        $_criticalContext
        """;
      }
    } else {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              _langChip("Python/Kivy", Icons.code),
            ])
          ],
        ),
      ),
    );
  }

  Widget _langChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.black),
      label: Text(label,
          style: GoogleFonts.outfit(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                              const Icon(Icons.code,
                                  color: Colors.blue, size: 18),
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
                        ]),
                  ),
                ),
              ),
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
                                color: AppColors.primaryAccent, blurRadius: 10)
                          ])),
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
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
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
                          backgroundColor: AppColors.primaryAccent)),
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
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text("GENERATE CODE",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
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
// HELPER SCREENS (HOME, BADGE, CARDS)
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
                Text("Hello, ${isDevMode ? 'Developer' : 'Netra User'}",
                    style: GoogleFonts.outfit(
                        fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
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
          FadeTransition(
            opacity: _opacity,
            child: const Icon(Icons.circle,
                size: 10, color: AppColors.primaryAccent),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              widget.isDevMode
                  ? "Ready to Build & Debug 🛠️"
                  : "Vision Intelligence Active 👁️",
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
// 🔥 6. LIVE VISION PRO (FINAL: MINI LENS + ROAD SAFETY)
// =============================================================================

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});
  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final FlutterTts _tts = FlutterTts();
  final AIBrain _brain = AIBrain();

  bool _isProcessing = false;
  String _desc = "नेत्रा विजन सक्रिय है...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _setupVoice();
    _initCamera();
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage("hi-IN");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.6);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
        _startFastAnalysisLoop();
      }
    }
  }

  void _startFastAnalysisLoop() {
    // Speed: 2.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!_isProcessing && mounted) {
        _captureAndAnalyze();
      }
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isProcessing = true);
      final image = await _controller!.takePicture();

      // ✅ Prompt me Safety + Currency dono add kiya
      String prompt = """
      You are a visual assistant for a blind person.
      ANALYZE PRIORITY:
      1. **DANGER:** Car, Bike, Pit, Fire, Obstacle? Warn immediately.
      2. **CURRENCY:** Identify Note value (e.g. 500 Rupees).
      3. **OBJECT:** Name the main object.
      
      OUTPUT: SHUDH HINDI (Max 6 words).
      Examples: "सावधान, कार आ रही है", "यह 500 रुपये का नोट है".
      """;

      String? res = await _brain.askWithImage(prompt, File(image.path));

      if (mounted && res != null) {
        setState(() {
          _desc = res;
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
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent));
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              // 1. FULL SCREEN CAMERA
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(_controller!),
              ),

              // 2. BOTTOM BLACK PANEL (Solid Black)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 30, left: 20, right: 20),
                  decoration: const BoxDecoration(
                      color: Colors.black, // ✅ PURE BLACK BACKGROUND
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 20,
                            spreadRadius: 5)
                      ]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // RESULT TEXT (With Red Alert Logic)
                      Text(
                        _desc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            // ✅ DANGER COLOR LOGIC ADDED
                            color: _desc.contains("सावधान") ||
                                    _desc.contains("Car")
                                ? Colors.redAccent
                                : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      // ✅ MINI LENS ORB (With Red Glow Logic)
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                  // ✅ DANGER GLOW LOGIC ADDED
                                  color: _desc.contains("सावधान")
                                      ? Colors.red.withOpacity(0.8)
                                      : (_isProcessing
                                          ? Colors.purpleAccent.withOpacity(0.6)
                                          : AppColors.primaryAccent
                                              .withOpacity(0.4)),
                                  blurRadius: 30,
                                  spreadRadius: 5)
                            ]),
                        child: ClipOval(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset("assets/orb.gif",
                                  fit: BoxFit.cover, height: 80, width: 80),
                              if (_isProcessing)
                                const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text("AI Vision Active",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ),

              // 3. BACK BUTTON
              Positioned(
                top: 40,
                left: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              )
            ],
          );
        } else {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent));
        }
      },
    );
  }
}

// =============================================================================
// 🔥 7. ERROR FIXER PRO
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
  File? _errorImage;
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  Future<void> _scanErrorImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _errorImage = File(pickedFile.path);
        _loading = true;
        _solution = "🔍 Scanning Error Log from Image...";
      });

      String prompt =
          "Extract the error message from this screenshot and FIX IT. Explain the root cause briefly.";
      String? res = await _brain.askWithImage(prompt, _errorImage!);

      setState(() {
        _loading = false;
        _solution = res ?? "Could not read error from image.";
      });
    }
  }

  // 🌐 FEATURE 2: GOOGLE SEARCH BUTTON (Corrected Code)
  Future<void> _searchOnGoogle() async {
    if (_ctrl.text.isEmpty) return;
    // Sirf pehli line search query banegi
    String query = _ctrl.text.split('\n').first;

    // 👇 Ye line dhyan se copy karein (No Markdown brackets)
    final url = Uri.parse(
        "https://www.google.com/search?q=${Uri.encodeComponent(query)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _fixError() async {
    if (_ctrl.text.isEmpty && _errorImage == null) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _solution = "🔍 Analyzing Stack Trace & Logic...";
    });

    String prompt = """
    I have a bug. Here is the ERROR LOG:
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
      title: "Error Debugger Pro",
      icon: Icons.bug_report_rounded,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      expands: true,
                      style: GoogleFonts.firaCode(
                          color: Colors.redAccent, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: "Paste Stack Trace OR Scan Screenshot...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Scan Error:",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: AppColors.primaryAccent),
                        onPressed: () => _scanErrorImage(ImageSource.camera),
                        tooltip: "Scan from Camera",
                      ),
                      IconButton(
                        icon: const Icon(Icons.image,
                            color: AppColors.primaryAccent),
                        onPressed: () => _scanErrorImage(ImageSource.gallery),
                        tooltip: "Upload Screenshot",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 10),
              InkWell(
                onTap: _searchOnGoogle,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.borderSubtle)),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              )
            ],
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
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.health_and_safety,
                              size: 50, color: Colors.grey[800]),
                          const SizedBox(height: 10),
                          Text("Paste error or scan screenshot to debug",
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                      ))
                    : SelectableText.rich(
                        CodeHighlighter.highlight(_solution),
                        style: GoogleFonts.firaCode(fontSize: 14, height: 1.5),
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
// 🔥 8. CODE EXPERT PRO
// =============================================================================

class CodeExpertScreen extends StatefulWidget {
  const CodeExpertScreen({super.key});
  @override
  State<CodeExpertScreen> createState() => _CodeExpertScreenState();
}

class _CodeExpertScreenState extends State<CodeExpertScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<String> _logs = [
    "> CodeNetra Expert System Initialized...",
    "> Connected to Gemini 3 Flash...",
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

    if (cmd == "clear") {
      setState(() {
        _logs.clear();
        _logs.add("> Console cleared.");
        _ctrl.clear();
      });
      return;
    }

    setState(() {
      _logs.add("\n> developer@codenetra:~\$ $cmd");
      _logs.add("> Processing...");
      _ctrl.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });

    String prompt =
        "You are a Linux Terminal style coding expert. Answer briefly and technically. Question: $cmd";
    String? res = await _brain.askLaravel(prompt);

    setState(() {
      _logs.removeLast();
      _logs.add(res ?? "> Error: Connection failed.");
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Widget _buildQuickChips() {
    final commands = [
      "/explain",
      "/fix_bug",
      "/refactor",
      "/optimize",
      "clear"
    ];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8, left: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: commands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isClear = commands[index] == "clear";
          return ActionChip(
            backgroundColor: const Color(0xFF1F1F1F),
            side: BorderSide(
                color: isClear
                    ? Colors.redAccent.withOpacity(0.5)
                    : AppColors.primaryAccent.withOpacity(0.3)),
            label: Text(commands[index],
                style: GoogleFonts.firaCode(
                    color: isClear ? Colors.redAccent : AppColors.primaryAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              if (isClear) {
                setState(() {
                  _logs.clear();
                  _logs.add("> Console cleared.");
                });
              } else {
                _ctrl.text = "${commands[index]} ";
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Code Expert",
      icon: Icons.terminal,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  blurRadius: 20)
            ]),
        child: Column(
          children: [
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
            _buildQuickChips(),
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

// =============================================================================
// 🔥 9. VOICE ASSISTANT (PURE BLACK - NO GLOW - ONLY ZOOM)
// =============================================================================

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();
  final AIBrain _brain = AIBrain();

  bool _isSessionActive = false;
  bool _isListening = false;
  bool _isProcessing = false;

  String _text = "Tap Orb to speak / बात करें";
  String _aiResponse = "";
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _brain.initBrain();
    _initTTS();

    // ✅ ANIMATION: Thoda Slow aur Smooth Zoom Effect
    _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
        lowerBound: 0.9, // Thoda sa chhota hoga
        upperBound: 1.05 // Thoda sa bada hoga (Pulse effect)
        );

    _tts.setCompletionHandler(() {
      if (_isSessionActive && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isSessionActive && mounted) _listen();
        });
      }
    });
  }

  Future<void> _initTTS() async {
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setLanguage("en-US");
  }

  void _toggleSession() {
    if (_isSessionActive)
      _stopSession();
    else
      _startSession();
  }

  void _startSession() async {
    bool available = await _speech.initialize(
      onError: (val) => _handleError(),
    );

    if (available) {
      setState(() {
        _isSessionActive = true;
        _aiResponse = "";
        _text = "Listening... / सुन रहा हूँ...";
      });
      // ✅ Start Zoom Animation
      _animController.repeat(reverse: true);
      _listen();
    }
  }

  void _stopSession() {
    setState(() {
      _isSessionActive = false;
      _isListening = false;
      _isProcessing = false;
      _text = "Tap Orb to speak / बात करें";
      // ✅ Stop Animation
      _animController.stop();
      _animController.value = 1.0;
    });
    _speech.stop();
    _tts.stop();
  }

  void _listen() {
    if (!_isSessionActive) return;
    setState(() => _isListening = true);

    _speech.listen(
      onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
          if (val.finalResult) {
            _processVoice(_text);
          }
        });
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void _handleError() {
    if (_isSessionActive) {
      _speakSmart("Sorry, please say that again.");
    }
  }

  // 🔥 IDENTITY & FEATURES LOGIC
  void _processVoice(String query) async {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    if (query.trim().isEmpty) {
      _handleError();
      return;
    }

    String lowerQuery = query.toLowerCase();

    // 🌍 Language Detection
    bool isHindi = lowerQuery.contains("kisne") ||
        lowerQuery.contains("kya") ||
        lowerQuery.contains("banaya") ||
        lowerQuery.contains("kaise") ||
        lowerQuery.contains("sakte") ||
        lowerQuery.contains("tum") ||
        lowerQuery.contains("namaste");

    // =========================================================
    // 🚀 CUSTOM IDENTITY CHECK
    // =========================================================

    // 1️⃣ Who made you?
    if (lowerQuery.contains("who made you") ||
        lowerQuery.contains("kisne banaya") ||
        lowerQuery.contains("creator") ||
        lowerQuery.contains("developer")) {
      String reply = isHindi
          ? "मैं CodeNetra AI हूँ। मुझे रोशन चौरसिया ने बनाया है, ताकि मैं नेत्रहीनों के लिए डिजिटल आँखें बन सकूँ।"
          : "I am CodeNetra AI, engineered by Roshan Chaurasiya to act as digital eyes for the visually impaired.";

      setState(() {
        _isProcessing = false;
        _aiResponse = reply;
      });
      await _speakSmart(reply);
      return;
    }

    // 2️⃣ What can you do?
    if (lowerQuery.contains("what can you do") ||
        lowerQuery.contains("kya kar sakte ho") ||
        lowerQuery.contains("tum kya ho")) {
      String reply = isHindi
          ? "मैं एक सुपर असिस्टेंट हूँ। मैं देख सकता हूँ, पढ़ सकता हूँ, नोट पहचान सकता हूँ और कोडिंग में मदद कर सकता हूँ।"
          : "I am a Super Assistant. I can see objects, read documents, detect currency, and help with coding.";

      setState(() {
        _isProcessing = false;
        _aiResponse = reply;
      });
      await _speakSmart(reply);
      return;
    }
    // =========================================================

    // 3️⃣ Normal API Call
    String prompt = """
    You are a helpful AI assistant.
    USER SAID: "$query"
    INSTRUCTIONS: Detect Language ($query). Keep it short (2 sentences).
    """;

    String? res = await _brain.askLaravel(prompt);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _aiResponse = res ?? "Connection Error.";
    });

    await _speakSmart(_aiResponse);
  }

  Future<void> _speakSmart(String text) async {
    bool isHindi = text.contains(RegExp(r'[\u0900-\u097F]'));

    if (isHindi) {
      await _tts.setLanguage("hi-IN");
    } else {
      await _tts.setLanguage("en-US");
    }

    await _tts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Voice Assistant",
      icon: Icons.mic,
      child: Container(
        color: Colors.black, // ✅ Z-BLACK BACKGROUND
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        color: _isListening
                            ? AppColors.primaryAccent
                            : Colors.white,
                        fontSize: 22,
                        fontWeight:
                            _isListening ? FontWeight.bold : FontWeight.normal),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 ORB SECTION (NO SHADOW / NO NEON)
                GestureDetector(
                  onTap: _toggleSession,
                  child: ScaleTransition(
                    scale: _animController, // ✅ Sirf Zoom In/Out Animation
                    child: Container(
                      height: 350,
                      width: 350,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent, // ✅ Piche koi light nahi
                        // ❌ REMOVED: BoxShadow remove kar diya gaya hai
                      ),
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Orb Image (Black Background wala GIF hona chahiye)
                            Image.asset("assets/orb.gif",
                                fit: BoxFit.cover, height: 350, width: 350),

                            if (_isProcessing)
                              const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),

                            // Icons inside Orb
                            if (!_isSessionActive)
                              const Icon(Icons.touch_app,
                                  color: Colors.white54, size: 60),

                            if (_isSessionActive &&
                                !_isProcessing &&
                                !_isListening)
                              const Icon(Icons.mic_off,
                                  color: Colors.white30, size: 50)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                if (_aiResponse.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.borderSubtle.withOpacity(0.5))),
                    child: Text(
                      _aiResponse,
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 🔥 10. PDF INTELLIGENCE (WEB FIX + IDENTITY MODE + CHIPS)
// =============================================================================

class PDFScreen extends StatefulWidget {
  const PDFScreen({super.key});
  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final AIBrain _brain = AIBrain();

  String _pdfText = "";
  String _fileName = "";
  bool _isLoading = false;

  // ✅ Suggested Chips
  List<String> _suggestedChips = [];

  final List<Map<String, String>> _messages = [
    {
      "role": "ai",
      "msg":
          "Select a PDF document. I will analyze it and give you quick suggestions."
    }
  ];

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  // ✅ UNIVERSAL PDF PICKER (WEB + MOBILE NO ERROR)
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // ✅ IMPORTANT FOR WEB
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _fileName = result.files.single.name;
          _messages.add({"role": "user", "msg": "📂 Uploaded: $_fileName"});
          _suggestedChips = [];
        });

        // 🚀 SMART CHECK: WEB VS MOBILE
        List<int> bytes;

        if (kIsWeb) {
          // 🌐 Web Logic
          if (result.files.single.bytes != null) {
            bytes = result.files.single.bytes!;
          } else {
            throw Exception("Web File bytes are null");
          }
        } else {
          // 📱 Mobile Logic
          if (result.files.single.path != null) {
            File file = File(result.files.single.path!);
            bytes = file.readAsBytesSync();
          } else {
            throw Exception("Mobile File path is null");
          }
        }

        // 1. Extract Text
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        String text = PdfTextExtractor(document).extractText();
        document.dispose();

        // 🔍 Check Empty
        if (text.trim().isEmpty) {
          setState(() {
            _isLoading = false;
            _messages.add({
              "role": "ai",
              "msg":
                  "⚠️ This PDF seems to be an image (Scanned). Please upload a text-based PDF."
            });
          });
          return;
        }

        // ✅ SUCCESS
        setState(() {
          _pdfText = text;
          _isLoading = false;
          _suggestedChips = [
            "📝 Summarize this",
            "🔑 List Key Points",
            "❓ What is the conclusion?",
            "📅 Find all dates",
            "📧 Extract Emails"
          ];
        });

        _askAI("Summarize this document in 3 bullet points.");
      }
    } catch (e) {
      print("🔴 PDF ERROR: $e");
      setState(() {
        _isLoading = false;
        _messages.add({
          "role": "ai",
          "msg": "Error reading PDF. Please ensure it's a valid file."
        });
      });
    }
  }

  // 🔥 IDENTITY MODE + PDF CHAT
  void _askAI(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "msg": query});
      _isLoading = true;
      _ctrl.clear();
    });
    _scrollToBottom();

    String lowerQuery = query.toLowerCase();

    // 🌍 Language Detection
    bool isHindi = lowerQuery.contains("kisne") ||
        lowerQuery.contains("kya") ||
        lowerQuery.contains("banaya") ||
        lowerQuery.contains("kaise") ||
        lowerQuery.contains("sakte") ||
        lowerQuery.contains("tum") ||
        lowerQuery.contains("namaste");

    // =========================================================
    // 🚀 CUSTOM IDENTITY CHECK
    // =========================================================

    // 1️⃣ Who made you?
    if (lowerQuery.contains("who made you") ||
        lowerQuery.contains("kisne banaya") ||
        lowerQuery.contains("creator") ||
        lowerQuery.contains("developer")) {
      await Future.delayed(const Duration(seconds: 1));

      String reply = isHindi
          ? """
मैं **CodeNetra AI** हूँ, एक एडवांस इंटेलिजेंस सिस्टम जिसे **रोशन चौरसिया** ने बनाया है।
मेरा निर्माण **Flutter** और **Generative AI** की अत्याधुनिक तकनीक से हुआ है।
"""
          : """
I am **CodeNetra AI**, an advanced intelligence system engineered by **Roshan Chaurasiya**.
Built with **Flutter** and **Generative AI**, my mission is to empower visually impaired users.
""";

      setState(() {
        _isLoading = false;
        _messages.add({"role": "ai", "msg": reply});
      });
      _scrollToBottom();
      return;
    }

    // 2️⃣ What can you do?
    if (lowerQuery.contains("what can you do") ||
        lowerQuery.contains("kya kar sakte ho") ||
        lowerQuery.contains("tum kya ho")) {
      await Future.delayed(const Duration(seconds: 1));

      String reply = isHindi
          ? """
मैं **CodeNetra AI** हूँ। मेरी मुख्य शक्तियां ये हैं:

1. **📄 DocuMind (PDF मास्टर):** मैं किसी भी PDF को पढ़कर उसका निचोड़ (Summary) निकाल सकता हूँ।
2. **👁️ नेत्रा विजन:** मैं नेत्रहीनों के लिए 'डिजिटल आँखें' बनकर खतरों को पहचानता हूँ।
3. **🗣️ वॉइस असिस्टेंट:** आप मुझसे हिंदी या इंग्लिश में बात कर सकते हैं।
4. **💻 कोड एक्सपर्ट:** मैं मुश्किल प्रोग्रामिंग कोड को समझा सकता हूँ।

बताइए, इस PDF में मैं क्या ढूंढूं?
"""
          : """
I am **CodeNetra AI**. Here is my capability suite:

1. **📄 DocuMind:** I can read, analyze, and summarize complex PDF documents.
2. **👁️ Netra Vision:** I act as 'Digital Eyes' for the visually impaired.
3. **🗣️ Voice Commander:** I support hands-free interaction.
4. **💻 Code Expert:** I can explain complex programming logic.
""";

      setState(() {
        _isLoading = false;
        _messages.add({"role": "ai", "msg": reply});
      });
      _scrollToBottom();
      return;
    }
    // =========================================================

    // 2. CHECK PDF
    if (_pdfText.isEmpty) {
      setState(() {
        _isLoading = false;
        _messages.add({
          "role": "ai",
          "msg": isHindi
              ? "कृपया पहले कोई PDF अपलोड करें! 📂"
              : "Please upload a PDF first! 📂"
        });
      });
      return;
    }

    // 3. API CALL
    String prompt = """
    CONTEXT FROM PDF:
    $_pdfText
    
    USER QUESTION: "$query"
    
    INSTRUCTIONS:
    1. Answer ONLY based on the PDF context.
    2. Detect user language ($query). If Hindi, answer in Hindi.
    """;

    String? res = await _brain.askLaravel(prompt);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add({"role": "ai", "msg": res ?? "Connection Error."});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "DocuMind PDF",
      icon: Icons.picture_as_pdf_rounded,
      child: Column(
        children: [
          // 1. TOP BAR
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle)),
            child: Row(
              children: [
                Icon(Icons.description,
                    color: _fileName.isEmpty ? Colors.grey : Colors.redAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _fileName.isEmpty ? "No PDF Selected" : _fileName,
                    style: TextStyle(
                        color: _fileName.isEmpty ? Colors.grey : Colors.white,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickPDF,
                  icon: const Icon(Icons.upload_file,
                      size: 18, color: Colors.black),
                  label: const Text("Upload",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. CHAT LIST
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  bool isAi = msg['role'] == 'ai';
                  return Align(
                    alignment:
                        isAi ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                          color: isAi
                              ? AppColors.cardSurface
                              : AppColors.primaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft:
                                isAi ? Radius.zero : const Radius.circular(12),
                            bottomRight:
                                isAi ? const Radius.circular(12) : Radius.zero,
                          ),
                          border: Border.all(
                              color: isAi
                                  ? Colors.white10
                                  : AppColors.primaryAccent.withOpacity(0.5))),
                      child: SelectableText(
                        msg['msg']!,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                  color: AppColors.primaryAccent, minHeight: 2),
            ),

          // 3. CHIPS
          if (_suggestedChips.isNotEmpty && !_isLoading)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _suggestedChips.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(_suggestedChips[index]),
                      labelStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                      backgroundColor: AppColors.cardSurface,
                      side: BorderSide(
                          color: AppColors.primaryAccent.withOpacity(0.5)),
                      shape: const StadiumBorder(),
                      onPressed: () => _askAI(_suggestedChips[index]),
                    ),
                  );
                },
              ),
            ),

          // 4. INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.borderSubtle)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: "Ask something about this PDF...",
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                    onSubmitted: (val) => _askAI(val),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryAccent),
                  onPressed: () => _askAI(_ctrl.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 11. CONTENT STUDIO (THE CREATOR SUITE)
// =============================================================================

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});
  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final List<Map<String, dynamic>> _tools = [
    {
      "id": "blog",
      "title": "Blog Writer",
      "icon": Icons.article_rounded,
      "color": Colors.orangeAccent,
      "desc": "SEO optimized full blog posts.",
      "chips": [
        "AI in 2026",
        "Healthy Diet Tips",
        "Flutter vs React",
        "Space Travel",
        "Digital Marketing",
        "Passive Income",
        "Cyber Security",
        "Remote Work"
      ],
      "prompt":
          "Write a professional, SEO-optimized blog post about: [TOPIC]. Include a catchy title, introduction, 3 main headings, and a conclusion."
    },
    {
      "id": "youtube",
      "title": "YouTube Kit",
      "icon": Icons.play_circle_fill,
      "color": Colors.redAccent,
      "desc": "Viral description & hashtags.",
      "chips": [
        "Gaming Setup Tour",
        "Coding Tutorial",
        "Vlog: Day in Life",
        "Tech Review",
        "Comedy Skit",
        "Fitness Routine",
        "Travel Guide",
        "Cooking Recipe"
      ],
      "prompt":
          "Write a VIRAL YouTube Video Description for: [TOPIC]. \nREQUIREMENTS:\n1. Catchy Hook in first line.\n2. Detailed summary (3-4 lines).\n3. 'Don't forget to Subscribe' CTA.\n4. EXACTLY 10 High-Ranking Hashtags at the end."
    },
    {
      "id": "insta",
      "title": "Insta Captions",
      "icon": Icons.camera_alt,
      "color": Colors.purpleAccent,
      "desc": "Engaging captions & emojis.",
      "chips": [
        "Sunset Vibes",
        "Gym Motivation",
        "Coffee Date",
        "New Car",
        "Coding Life",
        "Throwback Thursday",
        "Outfit of the Day",
        "Monday Motivation"
      ],
      "prompt":
          "Write 3 different Instagram Caption options (Funny, Inspirational, Short) for: [TOPIC]. Include relevant emojis and 15 hashtags."
    },
    {
      "id": "email",
      "title": "Cold Email",
      "icon": Icons.email,
      "color": Colors.blueAccent,
      "desc": "Professional business emails.",
      "chips": [
        "Job Application",
        "Freelance Proposal",
        "Sales Pitch",
        "Meeting Request",
        "Follow Up",
        "Resignation",
        "Collaboration",
        "Sponsorship"
      ],
      "prompt":
          "Write a professional Cold Email for: [TOPIC]. Keep it concise, persuasive, and polite. Include a Subject Line."
    },
    {
      "id": "twitter",
      "title": "X / Twitter",
      "icon": Icons.alternate_email,
      "color": Colors.lightBlueAccent,
      "desc": "Viral threads & tweets.",
      "chips": [
        "Tech Trends",
        "Startup Advice",
        "Crypto News",
        "Life Hack",
        "Coding Tip",
        "Political Opinion",
        "Joke",
        "Motivational Quote"
      ],
      "prompt":
          "Write a viral Twitter Thread (5 tweets) about: [TOPIC]. Use a hook in the first tweet. Keep sentences short and punchy."
    },
    {
      "id": "linkedin",
      "title": "LinkedIn Pro",
      "icon": Icons.business_center,
      "color": Colors.blue[800],
      "desc": "Thought leadership posts.",
      "chips": [
        "Career Update",
        "Project Launch",
        "Leadership Lesson",
        "Hiring Alert",
        "Industry Analysis",
        "Achievement",
        "Work Culture",
        "Event Experience"
      ],
      "prompt":
          "Write a professional LinkedIn post about: [TOPIC]. Tone: Professional yet engaging. Use bullet points and a call to action."
    },
    {
      "id": "script",
      "title": "Reels Script",
      "icon": Icons.movie_creation,
      "color": Colors.pinkAccent,
      "desc": "60-sec video scripts.",
      "chips": [
        "Tech Tip",
        "Funny Skit",
        "Educational Fact",
        "Product Teaser",
        "Life Advice",
        "Behind the Scenes",
        "Dance Challenge",
        "Storytime"
      ],
      "prompt":
          "Write a 60-second Reels/TikTok script for: [TOPIC]. Format: \n[0-5s] Hook\n[5-45s] Content/Value\n[45-60s] Call to Action."
    },
  ];

  void _openGenerator(BuildContext context, Map<String, dynamic> tool) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentGeneratorScreen(tool: tool),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "Content Studio",
      icon: Icons.auto_awesome_mosaic,
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _tools.length,
        itemBuilder: (context, index) {
          final tool = _tools[index];
          return GestureDetector(
            onTap: () => _openGenerator(context, tool),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: (tool['color'] as Color).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (tool['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tool['icon'], color: tool['color'], size: 32),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    tool['title'],
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      tool['desc'],
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 🧠 THE GENERATOR SCREEN (REUSABLE FOR ALL TOOLS)
// =============================================================================

class ContentGeneratorScreen extends StatefulWidget {
  final Map<String, dynamic> tool;
  const ContentGeneratorScreen({super.key, required this.tool});

  @override
  State<ContentGeneratorScreen> createState() => _ContentGeneratorScreenState();
}

class _ContentGeneratorScreenState extends State<ContentGeneratorScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final AIBrain _brain = AIBrain();
  String _result = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  void _generate() async {
    if (_ctrl.text.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _result = "";
    });

    String rawPrompt = widget.tool['prompt'];
    String finalPrompt = rawPrompt.replaceAll("[TOPIC]", _ctrl.text);

    String? res = await _brain.askLaravel(finalPrompt);

    setState(() {
      _loading = false;
      _result = res ?? "Failed to generate content. Please try again.";
    });
  }

  void _copyToClipboard() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Content Copied to Clipboard! 📋")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = widget.tool['color'];

    return Scaffold(
      backgroundColor: AppColors.background, // Fixed: Uses 'background' alias
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.tool['title'],
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What should I write about?",
                      style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.5))),
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter topic (e.g., Future of AI)",
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Quick Ideas:",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (widget.tool['chips'] as List<String>).map((chip) {
                      return ActionChip(
                        label: Text(chip),
                        backgroundColor: AppColors.cardSurface,
                        labelStyle: TextStyle(
                            color: themeColor, fontWeight: FontWeight.bold),
                        side: BorderSide(color: themeColor.withOpacity(0.3)),
                        onPressed: () {
                          _ctrl.text = chip;
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _generate,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text(
                          _loading ? " WRITING MAGIC..." : "GENERATE CONTENT",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_result.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.check_circle,
                                    color: themeColor, size: 18),
                                const SizedBox(width: 8),
                                const Text("AI Output",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ]),
                              IconButton(
                                icon: const Icon(Icons.copy,
                                    color: Colors.white70),
                                onPressed: _copyToClipboard,
                                tooltip: "Copy Text",
                              )
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          SelectableText(
                            _result,
                            style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                height: 1.5),
                          ),
                        ],
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
              if (parts.indexOf(part) % 2 == 0) {
                return Text(part,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 16));
              } else {
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
              }
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
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: code.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: AppColors.vsNormal)));
      }
      String token = match.group(0)!;
      Color color = AppColors.vsNormal;
      if (match.group(1) != null) {
        color = AppColors.vsComment;
      } else if (match.group(2) != null)
        color = AppColors.vsString;
      else if (match.group(3) != null)
        color = AppColors.vsKeyword;
      else if (match.group(5) != null) color = AppColors.vsType;
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < code.length) {
      spans.add(TextSpan(
          text: code.substring(lastMatchEnd),
          style: const TextStyle(color: AppColors.vsNormal)));
    }
    return TextSpan(children: spans);
  }
}
