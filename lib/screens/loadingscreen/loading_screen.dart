import 'dart:async';

import 'package:dancefirst/screens/homescreen/home_screen.dart';
import 'package:dancefirst/screens/loadingscreen/login_screen.dart';
import 'package:dancefirst/screens/loadingscreen/verification_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// LoadingScreen is the brain for appstart and auth-flow.class
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() {
    return _LoadingScreenState();
  }
}

class _LoadingScreenState extends State<LoadingScreen> {
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to auth changes to reinitialize.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      unawaited(_initializeApp());
    });
    // Trigger initialization immediately.
    unawaited(_initializeApp());
  }

  @override
  void dispose() {
    unawaited(_authSubscription.cancel());
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Delay 2 sec and fetch state.
    final List<dynamic> results = await Future.wait(<Future<dynamic>>[
      Future<void>.delayed(const Duration(seconds: 2)),
      _fetchAppState(),
    ]);

    final AppState state = results[1] as AppState;

    if (!mounted) return;

    // Navigate based on fetched state.
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) {
          return state.nextScreen;
        },
      ),
    );
  }

  Future<AppState> _fetchAppState() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser ?? await auth.authStateChanges().first;

    // User not logged in.
    if (user == null) {
      return AppState(const LoginScreen());
    }

    // Fetch latest status.
    await user.reload();

    // User not verified.
    if (!user.emailVerified) {
      return AppState(VerificationScreen(user: user));
    }

    // Fetch user role (admin/client).
    final String role = await FirestoreService().getUserRole();

    // Navigate to HomeScreen.
    return AppState(HomeScreen(role: role));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/dfLogoBlack.png', width: 200),
            const SizedBox(height: 32),
            const SizedBox(width: 200, child: LinearProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class AppState {
  AppState(this.nextScreen);

  final Widget nextScreen;
}
