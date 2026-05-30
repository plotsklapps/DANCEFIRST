import 'package:dancefirst/auth_state.dart';
import 'package:dancefirst/firebase_options.dart';
import 'package:dancefirst/screens/auth_gate.dart';
import 'package:dancefirst/screens/rooster_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAnalytics.instance.logAppOpen();

  // App Check tijdelijk uitgeschakeld voor lokaal testen
  // await FirebaseAppCheck.instance.activate(
  //   providerWeb: ReCaptchaV3Provider(
  //     '6LdMXwQtAAAAAOXOqaTMGiBf2q1q-E-a2AB0NY-c',
  //   ),
  // );

  // Initialize the global auth listener
  initAuthStateListener();

  runApp(const MainEntry());
}

class MainEntry extends StatelessWidget {
  const MainEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
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
      ),
    );
  }
}
