import 'dart:async';

import 'package:dancefirst/screens/homescreen/home_screen.dart';
import 'package:dancefirst/screens/loadingscreen/loading_screen.dart';
import 'package:dancefirst/screens/loadingscreen/verification_screen.dart';
import 'package:dancefirst/screens/onboardingscreen/onboarding_screen.dart';
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
  bool _showSplash = true;
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  bool _isCheckingVerification = false;
  bool _isVerified = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    // Show splash animation for at least 2 seconds on app launch
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isVerified = user?.emailVerified ?? false;
        });
        if (user != null) {
          _checkVerificationAndLoadRole();
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
      // Silent catch
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
    // 1. Show splash screen on initial startup
    if (_showSplash || _isCheckingVerification) {
      return const LoadingScreen();
    }

    // 2. If not logged in, show onboarding/login
    if (_currentUser == null) {
      return const OnboardingScreen();
    }

    // 3. If logged in but not verified, show verification screen
    if (!_isVerified) {
      return VerificationScreen(
        user: _currentUser!,
        onVerified: () {
          _checkVerificationAndLoadRole();
        },
      );
    }

    // 4. If logged in and verified, show home screen
    return HomeScreen(role: _userRole ?? 'client');
  }
}
