import 'dart:async';

import 'package:dancefirst/auth_state.dart';
import 'package:dancefirst/screens/auth/auth_screens.dart';
import 'package:dancefirst/screens/home_screen.dart';
import 'package:dancefirst/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// AuthGate responsible for sign in, email verification and showing
// correct HomeScreen based on sVerifiedUser Signal.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() {
    return _AuthGateState();
  }
}

class _AuthGateState extends State<AuthGate> {
  Timer? _verificationTimer;
  late final void Function() _unsubscribe;

  @override
  void initState() {
    super.initState();

    // Subscribe to changes in sVerifiedUser Signal.
    _unsubscribe = sVerifiedUser.subscribe((bool value) {
      if (mounted) {
        setState(() {});
      }
    });

    // Periodically check email verification status automatically.
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 4),
      (Timer timer) async {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified && user.phoneNumber == null) {
          await refreshUserVerification();
        }
      },
    );
  }

  @override
  void dispose() {
    // Kill timers and subscriptions.
    _unsubscribe();
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If user is signed in AND verified, show HomeScreen.
    if (sVerifiedUser.value) {
      return const HomeScreen();
    }

    final User? user = FirebaseAuth.instance.currentUser;

    // If not signed in, show AuthScreen.
    if (user == null) {
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

    // If signed in but email is NOT verified, show verification screen
    if (!user.emailVerified && user.phoneNumber == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('E-mail Verificatie'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 64,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verifieer je e-mailadres',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.questrial(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Er is een verificatielink gestuurd naar:\n'
                      '${user.email}\n\n'
                      'Klik op de link in de e-mail om je '
                      'account te activeren. Zodra je dit hebt gedaan, '
                      'word je automatisch ingelogd.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.questrial(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await refreshUserVerification();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ik heb op de link geklikt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        try {
                          await user.sendEmailVerification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Verificatie e-mail opnieuw verzonden!',
                                ),
                                backgroundColor: Colors.teal,
                              ),
                            );
                          }
                        } on Exception catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fout bij verzenden: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Stuur e-mail opnieuw'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fallback loading indicator
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
