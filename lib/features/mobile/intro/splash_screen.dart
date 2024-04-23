import 'dart:async';

import 'package:equiresolve/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// The `initApp` function uses a timer to navigate to the sign-in screen after every 3 seconds.
  void initApp() {
    Future.delayed(const Duration(seconds: 3), () {
      GoRouter.of(context).pushReplacementNamed(NamedRoutes.signIn.name);
    });
  }

  @override
  void initState() {
    initApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'EQUI|resolve',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2AE0),
          ),
        ),
      ),
    );
  }
}
