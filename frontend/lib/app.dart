import 'package:flutter/material.dart';
import 'package:frontend_01/features/Home/landing.dart';
import 'package:frontend_01/features/auth/login_screen.dart';
import 'package:frontend_01/features/auth/otp.dart';
import 'package:frontend_01/features/auth/register.screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),     // Default route (root)
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp': (_) => const OtpScreen(),
        '/landing': (_) => const LandingScreen(),        
      },
    );
  }
}
