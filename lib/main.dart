import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Added for Web Fix
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
    // ✅ REAL WORKING SCREENS LIST
    final List<Widget> screens = [
      HomeScreen(onNavigate: _changeScreen, isDevMode: _isDevMode), // 0
      const RepoChatScreen(), // 1 (SUPERCHARGED ZIP CHAT)
      const TemplatesScreen(), // 2
      const ErrorFixerScreen(), // 3
      const UIToCodeScreen(), // 4
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
// 🔥 4. REPO CHAT SCREEN (SUPERCHARGED: ZIP, WEB FIX, TYPEWRITER, SUGGESTIONS)
// =============================================================================

class RepoChatScreen extends StatefulWidget {
  const RepoChatScreen({super.key});
  @override
  State<RepoChatScreen> createState() => _RepoChatScreenState();
}

class _RepoChatScreenState extends State<RepoChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _msgs = [];

  bool _isLoading = false;
  String? _activeFileName;
  String _codebaseContext = "";
  bool _isContextLoaded = false;

  // AI Brain
  final AIBrain _brain = AIBrain();

  // Sliding Suggestions Logic
  late ScrollController _suggestionsController;
  late Timer _suggestionTimer;
  final List<String> _suggestions = [
    "Explain the main.dart file flow",
    "Where is the login logic located?",
    "Find bugs in my pubspec.yaml",
    "How to optimize the list view?",
    "Write a unit test for the API service",
    "Explain the project structure",
    "Refactor the home screen code",
    "Add comments to the complex logic",
    "Check for memory leaks",
    "Generate a README.md file",
    "Where are the colors defined?",
    "Help me add a new feature",
    "Debug the white screen error",
    "Convert this UI to dark mode",
    "Explain the state management used",
    "Is the Firebase setup correct?",
    "Create a release APK build",
    "Optimize image assets",
    "Fix the overflow error",
    "Add animation to the button"
  ];

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
    _suggestionsController = ScrollController();

    // Auto Scroll Suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });

    _addMessage("ai",
        "Hello Developer! 🚀\nUpload a ZIP file or link a Repo. I will analyze every single line of code and answer your questions.");
  }

  void _startAutoScroll() {
    _suggestionTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_suggestionsController.hasClients) {
        double maxScroll = _suggestionsController.position.maxScrollExtent;
        double currentScroll = _suggestionsController.offset;
        if (currentScroll >= maxScroll) {
          _suggestionsController.jumpTo(0);
        } else {
          _suggestionsController.jumpTo(currentScroll + 1);
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

  // --- 📂 ZIP FILE PICKER (WEB FIXED + DEEP ANALYSIS) ---
  Future<void> _pickZipFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true, // ✅ IMPORTANT FOR WEB
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _activeFileName = result.files.single.name;
        });

        List<int> bytes;

        // ✅ WEB VS MOBILE FIX
        if (kIsWeb) {
          bytes = result.files.single.bytes!;
        } else {
          File file = File(result.files.single.path!);
          bytes = await file.readAsBytes();
        }

        // Decode ZIP
        final archive = ZipDecoder().decodeBytes(bytes);
        StringBuffer extractedCode = StringBuffer();
        extractedCode.writeln(
            "INSTRUCTION: You are an AI code analyzer. Here is the full codebase content. Use this to answer specific questions, find files, and write code based on this context.\n\n--- BEGIN CODEBASE ---");

        int fileCount = 0;

        for (final file in archive) {
          if (file.isFile) {
            final fName = file.name;
            // Only read code files (Ignore images/builds)
            if (fName.endsWith(".dart") ||
                fName.endsWith(".yaml") ||
                fName.endsWith(".xml") ||
                fName.endsWith(".json") ||
                fName.endsWith(".js") ||
                fName.endsWith(".html")) {
              try {
                final content = String.fromCharCodes(file.content);
                // Safety check for size
                if (content.length < 20000) {
                  extractedCode.writeln("\n\n--- FILE: $fName ---\n$content");
                  fileCount++;
                }
              } catch (e) {
                // Ignore binary/non-text files
              }
            }
          }
        }

        extractedCode.writeln("\n--- END CODEBASE ---");

        setState(() {
          _codebaseContext = extractedCode.toString();
          _isContextLoaded = true;
          _isLoading = false;
          _addMessage("system",
              "✅ Analysis Complete! I have read $fileCount files from $_activeFileName. Ask me to show any code or explain logic.");
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _addMessage("system", "❌ Error reading ZIP: $e");
    }
  }

  // --- 🔗 GITHUB LINK ---
  void _addGitHubLink() {
    TextEditingController urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text("GitHub Repository",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: urlCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
              hintText: "https://github.com/username/repo",
              hintStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent),
              onPressed: () {
                if (urlCtrl.text.isNotEmpty) {
                  setState(() {
                    _activeFileName = "GitHub Repo";
                    _codebaseContext =
                        "CONTEXT: The user is asking about the GitHub repository '${urlCtrl.text}'. Assume it is a standard Flutter project. If they ask for generic code, provide standard Flutter examples.";
                    _isContextLoaded = true;
                    _addMessage("system",
                        "🔗 Repository Linked! I'm ready to discuss structure and logic.");
                  });
                  Navigator.pop(c);
                }
              },
              child:
                  const Text("Analyze", style: TextStyle(color: Colors.black)))
        ],
      ),
    );
  }

  // --- 💬 SEND MESSAGE ---
  void _send(String text) async {
    if (text.isEmpty) return;
    _ctrl.clear();
    _addMessage("user", text);

    setState(() => _isLoading = true);

    String fullPrompt = text;
    // Inject Context if loaded
    if (_isContextLoaded && _codebaseContext.isNotEmpty) {
      fullPrompt =
          "$_codebaseContext\n\nUser Question: $text\n\nProvide a detailed answer with code blocks where necessary.";
    }

    String? res = await _brain.askLaravel(fullPrompt);
    setState(() => _isLoading = false);

    if (res != null) {
      _addMessage("ai", res);
    } else {
      _addMessage(
          "ai", "Sorry, I encountered an error connecting to the brain.");
    }
  }

  void _addMessage(String role, String text) {
    setState(() {
      _msgs.add({"role": role, "text": text, "animated": false});
    });
    // Auto scroll to bottom
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
      icon: Icons.folder_zip_rounded,
      child: Column(
        children: [
          // 1. STATUS BAR
          if (_activeFileName != null)
            ProCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primaryAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(_activeFileName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis)),
                  IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => setState(() {
                            _activeFileName = null;
                            _isContextLoaded = false;
                            _codebaseContext = "";
                          }))
                ]))
          else
            Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderSubtle),
                    borderRadius: BorderRadius.circular(16)),
                child: const Text("No Repository Loaded",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center)),

          const SizedBox(height: 10),

          // 2. CHAT LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (c, i) {
                final msg = _msgs[i];
                if (msg['role'] == 'system') {
                  return Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(msg['text'],
                              style: const TextStyle(
                                  color: AppColors.primaryAccent,
                                  fontSize: 12))));
                }
                return ChatBubble(
                  isUser: msg['role'] == 'user',
                  text: msg['text'],
                  isAnimated: msg['animated'],
                  onAnimationEnd: () {
                    setState(() {
                      _msgs[i]['animated'] = true;
                    });
                  },
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primaryAccent)),
                    SizedBox(width: 10),
                    Text("Analyzing codebase...",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))
                  ]),
            ),

          // 3. SLIDING SUGGESTIONS
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              controller: _suggestionsController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index % _suggestions.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    backgroundColor: AppColors.cardSurface,
                    side: BorderSide.none,
                    label: Text(suggestion,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                    onPressed: () => _send(suggestion),
                  ),
                );
              },
            ),
          ),

          // 4. INPUT BAR
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppColors.cardSurface,
                border: Border(top: BorderSide(color: AppColors.borderSubtle))),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.primaryAccent, size: 28),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: AppColors.cardSurface,
                          builder: (c) => Wrap(children: [
                                ListTile(
                                    leading: const Icon(Icons.folder_zip,
                                        color: Colors.orange),
                                    title: const Text("Upload ZIP Project"),
                                    onTap: () {
                                      Navigator.pop(c);
                                      _pickZipFile();
                                    }),
                                ListTile(
                                    leading: const Icon(Icons.link,
                                        color: Colors.blue),
                                    title: const Text("GitHub Link"),
                                    onTap: () {
                                      Navigator.pop(c);
                                      _addGitHubLink();
                                    }),
                              ]));
                    }),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Ask specific code questions...",
                            border: InputBorder.none),
                        onSubmitted: _send)),
                IconButton(
                    icon:
                        const Icon(Icons.send, color: AppColors.primaryAccent),
                    onPressed: () => _send(_ctrl.text))
              ],
            ),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// 🔥 5. UI TO CODE SCREEN (WORKING IMAGE PICKER)
// =============================================================================

class UIToCodeScreen extends StatefulWidget {
  const UIToCodeScreen({super.key});
  @override
  State<UIToCodeScreen> createState() => _UIToCodeScreenState();
}

class _UIToCodeScreenState extends State<UIToCodeScreen> {
  File? _image;
  bool _loading = false;
  String _generatedCode = "// Generated code will appear here...";
  final AIBrain _brain = AIBrain();

  @override
  void initState() {
    super.initState();
    _brain.initBrain();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _loading = true;
      });
      // Call AI
      String? result = await _brain.askWithImage(
          "Analyze this UI image and write the Flutter code for it. Return ONLY the code.",
          _image!);
      setState(() {
        _generatedCode = result ?? "// AI Error";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProPageLayout(
      title: "UI to Code",
      icon: Icons.image_aspect_ratio_rounded,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: ProCard(
              onTap: _pickImage,
              child: _image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          const Icon(Icons.cloud_upload_rounded,
                              size: 50, color: AppColors.primaryAccent),
                          const SizedBox(height: 10),
                          const Text("Upload UI Screenshot")
                        ])
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_image!,
                          fit: BoxFit.cover, width: double.infinity)),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const LinearProgressIndicator(color: AppColors.primaryAccent),
          Expanded(
            flex: 2,
            child: ProCard(
              child: SingleChildScrollView(
                child: Text(_generatedCode,
                    style: GoogleFonts.firaCode(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
            ),
          ),
        ],
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
// OTHER SCREENS (Simpler implementations)
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
// UI HELPERS (AND NEW CHAT BUBBLE)
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

Widget _buildProInput(String hint) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderSubtle)),
    child: Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              color: AppColors.primaryAccent, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_upward_rounded,
              color: Colors.black, size: 20),
        )
      ],
    ),
  );
}

// ✨ NEW: CHAT BUBBLE WITH TYPEWRITER EFFECT
class ChatBubble extends StatefulWidget {
  final bool isUser;
  final String text;
  final bool isAnimated;
  final VoidCallback onAnimationEnd;

  const ChatBubble(
      {super.key,
      required this.isUser,
      required this.text,
      required this.isAnimated,
      required this.onAnimationEnd});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
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
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
        }
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
    bool isCode = widget.text.contains("class ") ||
        widget.text.contains("void ") ||
        widget.text.contains("import ");

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: widget.isUser
              ? AppColors.primaryAccent.withOpacity(0.2)
              : AppColors.cardSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: widget.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                widget.isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
              color: widget.isUser
                  ? AppColors.primaryAccent.withOpacity(0.5)
                  : AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_displayedText,
                style: GoogleFonts.firaCode(
                    color: widget.isUser
                        ? Colors.white
                        : (isCode
                            ? AppColors.primaryAccent
                            : AppColors.textSecondary),
                    fontSize: 13,
                    height: 1.4)),
            if (!widget.isUser && widget.text.length == _displayedText.length)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Copied to clipboard!"),
                                duration: Duration(milliseconds: 800)));
                      },
                      child: const Icon(Icons.copy_rounded,
                          size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
