import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIGN IN
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
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
      await credential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ToastService.showError(
        title: 'E-mail verzonden',
        subtitle: 'Controleer je e-mail voor de resetlink.',
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = 'Er is iets misgegaan.';
    switch (e.code) {
      case 'user-not-found':
        message = 'Geen account gevonden met dit e-mailadres.';
        break;
      case 'wrong-password':
        message = 'Het wachtwoord is onjuist.';
        break;
      case 'email-already-in-use':
        message = 'Dit e-mailadres is al in gebruik.';
        break;
      case 'invalid-email':
        message = 'Het e-mailadres is ongeldig.';
        break;
      case 'weak-password':
        message = 'Het wachtwoord is te zwak.';
        break;
      default:
        message = e.message ?? 'Fout: ${e.code}';
    }
    ToastService.showError(title: 'Authenticatiefout', subtitle: message);
  }
}
