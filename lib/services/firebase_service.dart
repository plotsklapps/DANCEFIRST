import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirestoreService _firestore = FirestoreService();
  final Logger _logger = Logger();

  // SIGN IN.
  Future<void> signIn(String email, String password) async {
    try {
      // Use FirebaseAuth to sign in.
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure the user document exists.
      if (credential.user != null) {
        await _firestore.createUserDocument(credential.user!.uid, email);
      }

      // Log Analytics Event.
      await _analytics.logLogin(loginMethod: 'email');

      // Log success.
      _logger.i('Signed in user $email');

      // Show toast to user.
      ToastService.showSuccess(
        title: 'Login Succesvol',
        subtitle: 'Je bent ingelogd als $email',
      );
    } on FirebaseAuthException catch (e) {
      // User helper method.
      await _handleAuthError(e);
      rethrow;
    }
  }

  // SIGN UP.
  Future<void> signUp(String email, String password) async {
    try {
      // Use FirebaseAuth to sign up.
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      // Ensure the user document exists.
      if (credential.user != null) {
        await _firestore.createUserDocument(credential.user!.uid, email);
      }

      // Send verification email.
      await credential.user?.sendEmailVerification();

      // Log Analytics Event.
      await _analytics.logSignUp(signUpMethod: 'email');

      // Log success.
      _logger.i('Signing up user $email');

      // Show toast to user.
      ToastService.showSuccess(
        title: 'Registratie Succesvol',
        subtitle: 'Check je e-mail (spam) om te verifiëren.',
      );
    } on FirebaseAuthException catch (e) {
      // Use helper method.
      await _handleAuthError(e);
      rethrow;
    }
  }

  // RESET PASSWORD.
  Future<void> resetPassword(String email) async {
    try {
      // Use FirebaseAuth to reset password.
      await _auth.sendPasswordResetEmail(email: email);

      // Log Analytics Event.
      await _analytics.logEvent(
        name: 'password_reset',
        parameters: <String, Object>{'email': email},
      );

      // Log success.
      _logger.i('Reset password link verzonden naar $email');

      // Show toast to user.
      ToastService.showSuccess(
        title: 'E-mail Verzonden',
        subtitle:
            'Als je email bij ons bekend is krijg je een resetlink. Check '
            'ook je spamfolder.',
      );
    } on FirebaseAuthException catch (e) {
      // Use helper method.
      await _handleAuthError(e);
      rethrow;
    }
  }

  // SIGN OUT.
  Future<void> signOut() async {
    try {
      // Use FirebaseAuth to sign out.
      await _auth.signOut();

      // Log Analytics Event.
      await _analytics.logEvent(name: 'sign_out');

      // Log success.
      _logger.i('Signed out.');

      // Show toast to user.
      ToastService.showSuccess(
        title: 'Uitgelogd',
        subtitle: 'Je kunt weer inloggen.',
      );
    } on FirebaseAuthException catch (e) {
      // Use helper method.
      await _handleAuthError(e);
      rethrow;
    }
  }

  Future<void> _handleAuthError(FirebaseAuthException e) async {
    String message = 'Er is iets misgegaan.';
    switch (e.code) {
      case 'invalid-credential':
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
    // Log analytics Event.
    await _analytics.logEvent(
      name: 'auth_error',
      parameters: <String, Object>{'code': e.code},
    );

    // Log error.
    _logger.e(e);

    // Show toast to user.
    ToastService.showError(title: 'Login Fout', subtitle: message);
  }
}
