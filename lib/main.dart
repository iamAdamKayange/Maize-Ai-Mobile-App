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
import 'screens/expert_dashboard.dart'; // Import expert dashboard

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
        '/my-plant': (ctx) => const MyPlantScreen(),
        '/notifications': (ctx) => const NotificationScreen(),
        '/settings': (ctx) => const SettingsScreen(),
        '/about': (ctx) => const AboutScreen(),
        '/privacy': (ctx) => const PrivacyScreen(),
        '/expert-dashboard': (ctx) =>
            const ExpertDashboard(), // Expert dashboard route
      },
      //Tumia onGenerateRoute kwa screen zinazohitaji parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/scan-progress') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ScanProgressScreen(
              imageFile: args['imageFile'],
              classifier: args['classifier'],
            ),
          );
        }

        if (settings.name == '/scan-results') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ScanResultsScreen(
              diseaseName: args['diseaseName'],
              confidence: args['confidence'],
              imageFile: args['imageFile'],
            ),
          );
        }

        return null;
      },
    );
  }
}

// ========== PLACEHOLDER SCREENS (Tengeneza kama hazipo) ==========

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: const Center(child: Text('Settings Screen - Coming Soon')),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: const Center(child: Text('About MaizeAI - Coming Soon')),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: const Center(child: Text('Privacy Policy - Coming Soon')),
    );
  }
}
