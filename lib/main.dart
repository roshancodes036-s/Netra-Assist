// =============================================================================
// 🔥 CODENETRA AI - MAIN ENTRY POINT (Clean Architecture)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ IMPORTS (Connecting your new folders)
import 'firebase_options.dart';
import 'theme/app_colors.dart'; // Design Colors
import 'screens/splash_screen.dart'; // First Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase (Legacy/Backup)
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("⚠️ Firebase Warning: $e");
  }

  // 2. System UI Styling (Immersive Pitch Black Mode)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // White Icons
    systemNavigationBarColor:
        Color(0xFF050505), // Matches AppColors.backgroundDark
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // 3. Run App
  runApp(const CodeNetraApp());
}

class CodeNetraApp extends StatelessWidget {
  const CodeNetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeNetra AI',
      debugShowCheckedModeBanner: false, // Hides the 'Debug' banner

      // ✅ GLOBAL THEME SETUP (One place to control design)
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            AppColors.backgroundDark, // From your theme file
        primaryColor: AppColors.primaryAccent, // From your theme file
        canvasColor: AppColors.backgroundDark,
        useMaterial3: true,

        // Font Setup (Applies Google Fonts globally)
        fontFamily: GoogleFonts.outfit().fontFamily,
        textTheme:
            GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),

        // Drawer Theme
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.backgroundDark,
        ),
      ),

      // ✅ START SCREEN
      home: const SplashView(),
    );
  }
}
