// =============================================================================
// 🔥 CODENETRA AI - MAIN ENTRY POINT
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ FIX: flutter_dotenv पैकेज को इम्पोर्ट किया गया है
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ IMPORTS
import 'theme/app_colors.dart'; 
import 'screens/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIX: .env फाइल को ऐप शुरू होने से पहले लोड करें
  await dotenv.load(fileName: ".env");

  // 1. Safe Firebase Initialization (वेब प्रीव्यू के लिए सेफ तरीका)
  // इससे अगर Firebase कंफिगर नहीं होगा, तो भी ऐप क्रैश नहीं होगी और UI रन हो जाएगा।
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Web Error Bypassed for UI Preview: $e");
  }

  // 2. System UI Styling (Immersive Pitch Black Mode)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, 
    systemNavigationBarColor: Color(0xFF050505), 
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
      debugShowCheckedModeBanner: false, 

      // ✅ GLOBAL THEME SETUP
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark, 
        primaryColor: AppColors.primaryAccent, 
        canvasColor: AppColors.backgroundDark,
        useMaterial3: true,

        // Font Setup
        fontFamily: GoogleFonts.outfit().fontFamily,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
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