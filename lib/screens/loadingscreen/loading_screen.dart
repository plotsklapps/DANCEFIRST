import 'package:dancefirst/screens/homescreen/home_screen.dart';
import 'package:dancefirst/screens/loadingscreen/login_screen.dart';
import 'package:dancefirst/screens/loadingscreen/verification_screen.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  Future<Widget> _determineNextScreen(User? user) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    // User is not logged in.
    if (user == null) {
      return const LoginScreen();
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/dfLogoBlack.png', width: 200),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
          );
        }

        final User? user = snapshot.data;

        return FutureBuilder<Widget>(
          future: _determineNextScreen(user),
          builder:
              (BuildContext context, AsyncSnapshot<Widget> screenSnapshot) {
                if (!screenSnapshot.hasData) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/dfLogoBlack.png', width: 200),
                          const SizedBox(height: 32),
                          const SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return screenSnapshot.data!;
              },
        );
      },
    );
  }
}
