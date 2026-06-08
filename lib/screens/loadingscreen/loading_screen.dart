import 'package:dancefirst/screens/homescreen/home_screen.dart';
import 'package:dancefirst/screens/loadingscreen/onboarding_screen.dart';
import 'package:dancefirst/screens/loadingscreen/verification_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  Future<Widget> _determineNextScreen(User? user) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    // User is not logged in.
    if (user == null) {
      return const OnboardingScreen();
    }

    await user.reload();

    // User is not verified.
    if (!user.emailVerified) {
      return VerificationScreen(user: user);
    }

    // Fetch userRole (admin/client).
    final String role = await FirestoreService().getUserRole();
    return HomeScreen(role: role);
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primaryContainer.withOpacity(0.4),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.primary.withOpacity(0.08),
            ],
            stops: const <double>[0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Animated pulsing logo or icon wrapper
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (BuildContext context, double scale, Widget? child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/dfLogoBlack.png',
                  width: 180,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Text(
                      'DanceFirst',
                      style: GoogleFonts.questrial(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
              // Modern, thin, custom-themed loading indicator
              SizedBox(
                width: 160,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(context);
        }

        final User? user = snapshot.data;

        return FutureBuilder<Widget>(
          future: _determineNextScreen(user),
          builder:
              (BuildContext context, AsyncSnapshot<Widget> screenSnapshot) {
                if (!screenSnapshot.hasData) {
                  return _buildLoadingIndicator(context);
                }
                return screenSnapshot.data!;
              },
        );
      },
    );
  }
}

