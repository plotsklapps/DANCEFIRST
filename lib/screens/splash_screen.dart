import 'dart:async';

import 'package:dancefirst/screens/auth/auth_screens.dart';
import 'package:dancefirst/screens/home_screen.dart';
import 'package:dancefirst/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minDurationMet = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _minDurationMet = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_minDurationMet) return const SplashView();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        }

        final user = snapshot.data;
        if (user != null) {
          if (!user.emailVerified) return VerificationView(user: user);
          return const HomeScreen();
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AuthScreen(service: FirebaseService()),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/dfLogoBlack.png', width: 200),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationView extends StatefulWidget {
  const VerificationView({required this.user, super.key});
  final User user;

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      // Forceer een rebuild om de status te checken
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-mail Verificatie'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Verifieer je e-mailadres voor ${widget.user.email}'),
            ],
          ),
        ),
      ),
    );
  }
}
