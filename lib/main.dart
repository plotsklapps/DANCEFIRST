import 'package:dancefirst/auth_state.dart';
import 'package:dancefirst/firebase_options.dart';
import 'package:dancefirst/screens/auth_gate.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui_auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaV3Provider(
      '6LdMXwQtAAAAAOXOqaTMGiBf2q1q-E-a2AB0NY-c',
    ),
  );

  // Configure Firebase UI Auth providers (Email/Password and Phone only)
  ui_auth.FirebaseUIAuth.configureProviders(
    <ui_auth.AuthProvider<ui_auth.AuthListener, AuthCredential>>[
      ui_auth.EmailAuthProvider(),
      ui_auth.PhoneAuthProvider(),
    ],
  );

  // Initialize the global auth listener
  initAuthStateListener();

  runApp(const MainEntry());
}

class MainEntry extends StatelessWidget {
  const MainEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DanceFirst',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: GoogleFonts.questrial().fontFamily,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const AuthGate(),
        '/schedule': (BuildContext context) => const RoosterScreen(),
      },
    );
  }
}
