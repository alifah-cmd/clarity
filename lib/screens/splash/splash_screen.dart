import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; 
import '../../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  void _redirect() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final initialSession = supabase.auth.currentSession;
      if (initialSession == null) {
        Get.offAllNamed(AppRoutes.welcome);
      } else {
        Get.offAllNamed(AppRoutes.main);
      }

      _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session == null) {
          Get.offAllNamed(AppRoutes.welcome);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD4C2FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/images/clarity.png', width: 150),
            // const SizedBox(height: 24),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
