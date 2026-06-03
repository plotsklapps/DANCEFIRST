import 'package:dancefirst/firebase_options.dart';
import 'package:dancefirst/screens/splash_screen.dart';
import 'package:dancefirst/theme/flex_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

  // Auth listener is now handled reactively by authUserSignal

  runApp(const MainEntry());
}

class MainEntry extends StatelessWidget {
  const MainEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DanceFirst',
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
