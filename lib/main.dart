import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_status_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/profile_screen.dart';

// =======================================================
// GANTI DENGAN KREDENSIAL SUPABASE ANDA
// Bisa didapat di: Project Settings -> API
// =======================================================
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://wzsyeuuapniwhhmwuedf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6c3lldXVhcG5pd2hobXd1ZWRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3ODYzMzksImV4cCI6MjA5NzM2MjMzOX0.1aW2Wz3Ci3CdPipNOeaqh1qUdse790vYrFlitK6o8wg',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const LaundryApp());
}

// Helper global untuk akses client Supabase di seluruh app
final supabase = Supabase.instance.client;

class LaundryApp extends StatelessWidget {
  const LaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3192),
          primary: const Color(0xFF2E3192),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Cek session: jika user sudah login, langsung ke Home
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(serviceId: ''),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/order-status': (context) {
          final orderId = ModalRoute.of(context)?.settings.arguments as String?;
          return OrderStatusScreen(orderId: orderId);
        },
        '/order-history': (context) => const OrderHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
