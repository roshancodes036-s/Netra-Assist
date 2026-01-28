import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';

// ✅ IMPORT ALL SCREENS (Code Expert Removed)
import 'repo_chat.dart';
import 'ui_to_code.dart';
import 'vision_mode.dart';
import 'voice_assistant.dart';
import 'error_fixer.dart';
import 'pdf_mind.dart';

// 🚀 NEW FEATURES IMPORTS
import 'architect_mode.dart';
import 'interview_mode.dart';
import 'visual_qa.dart';
import 'face_emotion.dart';

// Upgrade Screen Placeholder
class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) => const ProPageLayout(
      title: "Upgrade",
      icon: Icons.bolt,
      child: Center(child: Text("Pro Plan")));
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isDevMode = true;

  void _changeScreen(int index) => setState(() => _selectedIndex = index);
  void _toggleMode(bool isDev) => setState(() {
        _isDevMode = isDev;
        _selectedIndex = 0;
      });

  @override
  Widget build(BuildContext context) {
    // ✅ MASTER LIST OF SCREENS
    // Sequence Updated (Code Expert Removed)
    final List<Widget> screens = [
      HomeScreen(onNavigate: _changeScreen, isDevMode: _isDevMode), // 0

      // --- DEV TOOLS ---
      const RepoChatScreen(), // 1
      const UIToCodeScreen(), // 2
      const ErrorFixerScreen(), // 3
      const ArchitectScreen(), // 4
      const InterviewScreen(), // 5

      // --- NETRA TOOLS ---
      const LiveCameraScreen(), // 6
      const VoiceScreen(), // 7
      const PDFScreen(), // 8
      const VisualQAScreen(), // 9
      const FaceEmotionScreen(), // 10

      const UpgradeScreen(), // 11
    ];

    // Safety check
    final safeIndex = _selectedIndex < screens.length ? _selectedIndex : 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.5)))),
        title: _buildAppBarTitle(),
        centerTitle: true,
        leading: Builder(
            builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: AppColors.primaryAccent, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer())),
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
              })),
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: screens[safeIndex]),
    );
  }

  Widget _buildAppBarTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.borderSubtle)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_isDevMode ? Icons.terminal_rounded : Icons.visibility_rounded,
            color: AppColors.primaryAccent, size: 18),
        const SizedBox(width: 10),
        Text(_isDevMode ? "Developer Mode" : "Netra Vision Mode",
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔥 SIDEBAR CONTENT (Buttons Updated)
// -----------------------------------------------------------------------------
class SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final bool isDevMode;
  final Function(bool) onModeChange;
  const SidebarContent(
      {super.key,
      required this.selectedIndex,
      required this.onTap,
      required this.isDevMode,
      required this.onModeChange});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.backgroundDark,
        child: Column(children: [
          const SizedBox(height: 60),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.code_rounded,
                color: AppColors.primaryAccent, size: 32),
            const SizedBox(width: 10),
            Text("CodeNetra",
                style: GoogleFonts.outfit(
                    fontSize: 26, fontWeight: FontWeight.w800))
          ]),
          const SizedBox(height: 30),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.borderSubtle)),
              child: Row(children: [
                _modeButton("Code", Icons.code_rounded, true),
                _modeButton("Netra", Icons.visibility_rounded, false)
              ])),
          const SizedBox(height: 30),
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(isDevMode
                            ? "DEVELOPMENT SUITE"
                            : "ACCESSIBILITY SUITE"),
                        _btn("Dashboard", Icons.dashboard_rounded, 0),

                        // 🔥 DEV BUTTONS (Code Expert Removed)
                        if (isDevMode) ...[
                          _btn("Repo Chat", Icons.folder_zip_rounded, 1),
                          _btn("UI to Code", Icons.image_aspect_ratio_rounded,
                              2),
                          _btn("Error Debugger", Icons.bug_report_rounded, 3),
                          _btn("System Architect", Icons.architecture, 4),
                          _btn("Mock Interview", Icons.record_voice_over, 5),
                        ]
                        // 🔥 NETRA BUTTONS (Indices Updated)
                        else ...[
                          _btn("Live Vision", Icons.camera_enhance_rounded, 6),
                          _btn("Voice Assistant", Icons.graphic_eq_rounded, 7),
                          _btn("PDF Intelligence", Icons.picture_as_pdf_rounded,
                              8),
                          _btn("Visual Q&A", Icons.help_outline, 9),
                          _btn("Face & Emotion", Icons.face_retouching_natural,
                              10),
                        ],
                      ]))),
          _btn("Upgrade Plan", Icons.bolt_rounded, 11),
          const SizedBox(height: 20),
        ]));
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
                    color:
                        isActive ? AppColors.primaryAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(12)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon,
                      size: 18,
                      color: isActive ? Colors.black : AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(text,
                      style: TextStyle(
                          color:
                              isActive ? Colors.black : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16))
                ]))));
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: isSelected
                ? AppColors.primaryAccent.withOpacity(0.15)
                : Colors.transparent,
            leading: Icon(icon,
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.textSecondary,
                size: 24),
            title: Text(title,
                style: GoogleFonts.outfit(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16)),
            dense: true));
  }
}

// -----------------------------------------------------------------------------
// 🔥 HOME SCREEN (Dashboard Cards Updated)
// -----------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final bool isDevMode;
  const HomeScreen(
      {super.key, required this.onNavigate, required this.isDevMode});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Hello, ${isDevMode ? 'Developer' : 'Netra User'}",
                  style: GoogleFonts.outfit(
                      fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StatusBadge(isDevMode: isDevMode)
            ]),
            const CircleAvatar(
                backgroundColor: AppColors.cardSurface,
                child: Icon(Icons.person, color: Colors.white))
          ]),
          const SizedBox(height: 30),

          // BIG CARD
          _largeActionCard(
              title: isDevMode ? "System Architect" : "Live Vision",
              subtitle: isDevMode
                  ? "Design Databases & APIs Instantly"
                  : "Identify Objects & Read Text",
              icon: isDevMode ? Icons.architecture : Icons.remove_red_eye,
              color: AppColors.primaryAccent,
              onTap: () => onNavigate(isDevMode ? 4 : 6) // Updated Index
              ),

          const SizedBox(height: 20),

          // SMALL CARDS GRID
          Row(children: [
            if (isDevMode) ...[
              Expanded(
                  child: _smallCard("Repo Chat", Icons.folder_zip, Colors.blue,
                      () => onNavigate(1))),
              const SizedBox(width: 15),
              Expanded(
                  child: _smallCard("Mock Interview", Icons.record_voice_over,
                      Colors.orange, () => onNavigate(5)))
            ] else ...[
              Expanded(
                  child: _smallCard("Visual Q&A", Icons.help_outline,
                      Colors.pink, () => onNavigate(9))),
              const SizedBox(width: 15),
              Expanded(
                  child: _smallCard("Emotion Scan", Icons.face, Colors.purple,
                      () => onNavigate(10)))
            ]
          ])
        ]));
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
                gradient:
                    LinearGradient(colors: [color.withOpacity(0.8), color]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ]),
            child: Row(children: [
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
                            fontWeight: FontWeight.w500))
                  ])),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.black, size: 32)
            ])));
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color)),
              const SizedBox(height: 15),
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold))
            ])));
  }
}
