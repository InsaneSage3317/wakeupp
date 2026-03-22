import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const WakeUppApp(),
    ),
  );
}

class WakeUppApp extends StatelessWidget {
  const WakeUppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WakeUpp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3EFFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.light,
          primary: const Color(0xFF7C4DFF),
          secondary: const Color(0xFF9C6FFF),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
