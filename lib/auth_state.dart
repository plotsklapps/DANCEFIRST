import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signals/signals.dart';

/// Globally accessible Signal indicating if the current user is signed in and 
/// verified.
/// This will be true if:
/// 1. The user is logged in via Phone number (always considered verified).
/// 2. The user is logged in via Email/Password AND has verified their email.
final Signal<bool> sVerifiedUser = signal<bool>(false);

StreamSubscription<User?>? _authSubscription;

/// Initialize the auth state listener to keep [sVerifiedUser] in sync.
void initAuthStateListener() {
  unawaited(_authSubscription?.cancel());
  
  // Set initial value
  _updateSignal(FirebaseAuth.instance.currentUser);
  
  // Listen for subsequent changes (sign in, sign out, token changes)
  _authSubscription = FirebaseAuth.instance
      .userChanges()
      .listen(_updateSignal);
}

/// Helper method to update [sVerifiedUser] based on current Firebase User.
void _updateSignal(User? user) {
  if (user == null) {
    sVerifiedUser.value = false;
  } else {
    final bool isEmailVerified = user.emailVerified;
    final bool isPhoneAuth = user.phoneNumber != null;
    
    sVerifiedUser.value = isEmailVerified || isPhoneAuth;
  }
}

/// Manually reload the current Firebase User to fetch latest verification.
/// Useful for verification polling or "I verified" check button.
Future<void> refreshUserVerification() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.reload();
    _updateSignal(FirebaseAuth.instance.currentUser);
  }
}

/// Dispose of resources if needed (generally runs for lifetime of app).
void disposeAuthStateListener() {
  unawaited(_authSubscription?.cancel());
  _authSubscription = null;
}
