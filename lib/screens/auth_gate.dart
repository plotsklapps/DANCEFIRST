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

  @override
  void initState() {
    super.initState();
    // Luister naar auth changes direct van Firebase
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (mounted) setState(() {});
    });

    // Periodiek checken
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer timer) async {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          await refreshUserVerification();
          if (user.emailVerified) {
            if (mounted) setState(() {});
          }
        }
      },
    );
  }

  @override
  void dispose() {
    // Kill timers.
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If user is signed in.
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is NOT verified, show verification screen.
      if (!user.emailVerified) {
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
                        'Het kan enkele minuten duren voordat de e-mail aankomt. '
                        'Controleer ook je map met ongewenste e-mail (spam) als je niets ontvangt.\n\n'
                        'Je wordt automatisch doorgestuurd zodra je account is geverifieerd.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.questrial(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Wachten op verificatie...',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return const HomeScreen();
    }

    // If not signed in, show AuthScreen.
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
