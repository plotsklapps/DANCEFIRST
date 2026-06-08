import 'dart:async';

import 'package:dancefirst/screens/homescreen/home_screen.dart';
import 'package:dancefirst/screens/loading_screen.dart';
import 'package:dancefirst/screens/onboardingscreen/onboarding_screen.dart';
import 'package:dancefirst/screens/onboardingscreen/verification_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() {
    return _AuthGateState();
  }
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  String? _userRole;
  bool _showSplash = true;
  bool _isCheckingVerification = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    // Show 2-sec LoadingScreen.
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });

    // Subscribe to changes in User Object.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isVerified = user?.emailVerified ?? false;
        });
        if (user != null) {
          unawaited(_checkVerificationAndLoadRole());
        }
      }
    });
  }

  @override
  void dispose() {
    // Kill subscription.
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  Future<void> _checkVerificationAndLoadRole() async {
    if (_currentUser == null) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      await _currentUser!.reload();
      final User? updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null) {
        setState(() {
          _currentUser = updatedUser;
          _isVerified = updatedUser.emailVerified;
        });

        if (_isVerified) {
          final String role = await FirestoreService().getUserRole();
          setState(() {
            _userRole = role;
          });
        }
      }
    } on Exception catch (_) {
      // Silent catch.
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On startup, show LoadingScreen.
    if (_showSplash || _isCheckingVerification) {
      return const LoadingScreen();
    }

    // If not logged in, show OnboardingScreen.
    if (_currentUser == null) {
      return const OnboardingScreen();
    }

    // If logged in but not verified, show VerificationScreen.
    if (!_isVerified) {
      return VerificationScreen(
        user: _currentUser!,
        onVerified: () async {
          await _checkVerificationAndLoadRole();
        },
      );
    }

    // If logged in and verified, show HomeScreen.
    return HomeScreen(role: _userRole ?? 'client');
  }
}
