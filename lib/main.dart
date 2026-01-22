import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/screening_screen.dart';
import 'screens/result_screening.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_tabs.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_questions_screen.dart';
import 'screens/admin_results_screen.dart';
import 'screens/emotional_detector_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/consultation_screen.dart';

void main() {
  runApp(const InsightMindApp());
}

class InsightMindApp extends StatelessWidget {
  const InsightMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightMind',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: LoadingScreen.routeName,
      routes: {
        LoadingScreen.routeName: (ctx) => const LoadingScreen(),
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        MainTabs.routeName: (ctx) => const MainTabs(),
        RegisterScreen.routeName: (ctx) => const RegisterScreen(),
        ScreeningScreen.routeName: (ctx) => const ScreeningScreen(),
        EmotionalDetectorScreen.routeName: (ctx) =>
            const EmotionalDetectorScreen(),
        ResultScreening.routeName: (ctx) => const ResultScreening(),
        HistoryScreen.routeName: (ctx) => const HistoryScreen(),
        ProfileScreen.routeName: (ctx) => const ProfileScreen(),
        // Admin routes
        AdminLoginScreen.routeName: (ctx) => const AdminLoginScreen(),
        AdminDashboardScreen.routeName: (ctx) => const AdminDashboardScreen(),
        AdminUsersScreen.routeName: (ctx) => const AdminUsersScreen(),
        AdminQuestionsScreen.routeName: (ctx) => const AdminQuestionsScreen(),
        AdminResultsScreen.routeName: (ctx) => const AdminResultsScreen(),
        // Feature routes
        MeditationScreen.routeName: (ctx) => const MeditationScreen(),
        JournalScreen.routeName: (ctx) => const JournalScreen(),
        ConsultationScreen.routeName: (ctx) => const ConsultationScreen(),
      },
    );
  }
}
