import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:signals/signals.dart';

// Signal verwijderd

StreamSubscription<User?>? _authSubscription;

// Initialize the auth state listener
void initAuthStateListener() {
  unawaited(_authSubscription?.cancel());
  _authSubscription = FirebaseAuth.instance.userChanges().listen((_) {});
}

/// Manually reload the current Firebase User to fetch latest verification.
/// Useful for verification polling or "I verified" check button.
Future<void> refreshUserVerification() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.reload();
  }
}

/// Dispose of resources if needed (generally runs for lifetime of app).
void disposeAuthStateListener() {
  unawaited(_authSubscription?.cancel());
  _authSubscription = null;
}
