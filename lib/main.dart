import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'features/auth/landing_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/teacher/dashboard_page.dart';
import 'features/student/dashboard_page.dart';
import 'features/student/dengarkan_syair_page.dart';
import 'features/student/kerjakan_kuis_page.dart';
import 'features/student/pelajari_kitab_page.dart';
import 'features/student/info_page.dart';
import 'features/student/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari .env
  await dotenv.load(fileName: ".env");

  // Initialize Supabase dengan credentials dari .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize SupabaseService & AuthService
  try {
    await SupabaseService().initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  await AuthService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Imrithy's Rhymes",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF65A6F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/teacher-dashboard': (context) => const TeacherDashboardPage(),
        '/student-dashboard': (context) => const StudentDashboardPage(),
        '/dengarkan-syair': (context) => const DengarkanSyairPage(),
        '/kerjakan-kuis': (context) => const KerjakanKuisPage(),
        '/pelajari-kitab': (context) => const PelajariKitabPage(),
        '/info': (context) => const InfoPage(),
        '/profile': (context) => const StudentProfilePage(),
      },
    );
  }
}
