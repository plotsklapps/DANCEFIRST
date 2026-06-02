import 'dart:async';

import 'package:dancefirst/auth_state.dart';
import 'package:dancefirst/screens/auth/auth_screens.dart';
import 'package:dancefirst/screens/home_screen.dart';
import 'package:dancefirst/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class SplashScreen extends SignalStatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minDurationMet = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _minDurationMet = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncState<User?> user = authUserSignal.value;

    // Show splash logo/indicator until timer finishes
    if (!_minDurationMet) {
      return const SplashView();
    }

    final User? authUser = user.value;
    if (authUser != null) {
      if (!authUser.emailVerified) {
        return VerificationView(user: authUser);
      }
      return const HomeScreen();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AuthScreen(service: FirebaseService()),
          ),
        ),
      ),
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
          children: <Widget>[
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
  const VerificationView({
    required this.user,
    super.key,
  });
  final User user;

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      await refreshUserVerification();
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
            children: <Widget>[
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
