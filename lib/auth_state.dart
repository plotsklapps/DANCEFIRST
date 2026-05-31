import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:signals/signals_flutter.dart';

// Auth stream Signal.
final StreamSignal<User?> authUserSignal = streamSignal<User?>(
  () {
    return FirebaseAuth.instance.authStateChanges();
  },
  options: AsyncSignalOptions<User?>(
    initialValue: FirebaseAuth.instance.currentUser,
  ),
);

// Manually refresh Firebase Auth Status.
Future<void> refreshUserVerification() async {
  await FirebaseAuth.instance.currentUser?.reload();
}
