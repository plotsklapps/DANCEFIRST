import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Logger _logger = Logger();

  // SIGN IN.
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _logger.i('Signing In user $email');
      await _analytics.logLogin(loginMethod: 'email');
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      rethrow;
    }
  }

  // SIGN UP
  Future<void> signUp(String email, String password) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
      _logger.i('Signing up user $email');
      await _analytics.logSignUp(signUpMethod: 'email');
      await credential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      rethrow;
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ToastService.showSuccess(
        title: 'E-mail verzonden',
        subtitle: 'Controleer je e-mail (spam) voor de resetlink.',
      );
      _logger.i('Reset password link verzonden naar $email');
      await _analytics.logEvent(
        name: 'password_reset',
        parameters: <String, Object>{'email': email},
      );
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      rethrow;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.i('Signed out.');
      await _analytics.logEvent(name: 'sign_out');
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      rethrow;
    }
  }

  Future<void> _handleAuthError(FirebaseAuthException e) async {
    String message = 'Er is iets misgegaan.';
    switch (e.code) {
      case 'user-not-found':
        message = 'Geen account gevonden met dit e-mailadres.';
      case 'wrong-password':
        message = 'Het wachtwoord is onjuist.';
      case 'email-already-in-use':
        message = 'Dit e-mailadres is al in gebruik.';
      case 'invalid-email':
        message = 'Het e-mailadres is ongeldig.';
      case 'weak-password':
        message = 'Het wachtwoord is te zwak.';
      default:
        message = e.message ?? 'Fout: ${e.code}';
    }
    ToastService.showError(title: 'Authenticatiefout', subtitle: message);
    _logger.e(e);
    await _analytics.logEvent(
      name: 'auth_error',
      parameters: <String, Object>{'code': e.code},
    );
  }
}
