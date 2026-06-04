import 'dart:async';

import 'package:dancefirst/screens/homescreen/home_screen.dart';
import 'package:dancefirst/screens/login_screen.dart';
import 'package:dancefirst/screens/splashscreen/loading_screen.dart';
import 'package:dancefirst/screens/splashscreen/verification_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _firebaseAuth.userChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final User? user = snapshot.data;

        if (user != null) {
          if (!user.emailVerified) {
            return VerificationScreen(user: user);
          } else {
            return FutureBuilder<String>(
              // Wait at least 2 seconds, but never longer than the actual
              // fetching time.
              future: () async {
                final List<dynamic> results = await Future.wait(
                  <Future<dynamic>>[
                    FirestoreService().getUserRole(),
                    Future<void>.delayed(const Duration(seconds: 2)),
                  ],
                );
                return results[0] as String;
              }(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> roleSnapshot) {
                    if (!roleSnapshot.hasData) return const LoadingScreen();
                    return HomeScreen(role: roleSnapshot.data!);
                  },
            );
          }
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: const LoginScreen(),
              ),
            ),
          ),
        );
      },
    );
  }
}
