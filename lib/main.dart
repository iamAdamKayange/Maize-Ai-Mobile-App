import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/loading_screen.dart';
import 'screens/started_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/scan_progress_screen.dart';
import 'screens/scan_results_screen.dart';
import 'screens/my_plant_screen.dart';
import 'screens/notification_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MaizeAIApp());
}

class MaizeAIApp extends StatelessWidget {
  const MaizeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaizeAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoadingScreen(),
        '/started': (ctx) => const StartedScreen(),
        '/onboarding': (ctx) => const OnboardingScreen(),
        '/dashboard': (ctx) => const DashboardScreen(),
        '/scanner': (ctx) => const ScannerScreen(),
        '/scan-progress': (ctx) => const ScanProgressScreen(),
        '/scan-results': (ctx) => const ScanResultsScreen(),
        '/my-plant': (ctx) => const MyPlantScreen(),
        '/notifications': (ctx) => const NotificationScreen(),
        '/settings': (ctx) => const SettingsScreen(),
        '/about': (ctx) => const AboutScreen(),
        '/privacy': (ctx) => const PrivacyScreen(),
      },
    );
  }
}
