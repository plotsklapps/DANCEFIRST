import 'package:dancefirst/services/firebase_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.service,
    super.key,
  });
  final FirebaseService service;

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await widget.service.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await widget.service.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
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
        ToastService.showError(
          title: 'Inlogfout',
          subtitle: message,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ToastService.showError(
          title: 'Er is iets misgegaan',
          subtitle: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // HEADER.
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.teal.withAlpha(40),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Image.asset('assets/dfLogoBlack.png'),
                  ),
                ),
                // FORM.
                Card(
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _isLogin ? 'Inloggen' : 'Registreren',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            validator: (String? value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Voer een geldig e-mailadres in';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 15, right: 10),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMail01,
                                  size: 20,
                                ),
                              ),
                              labelText: 'E-mailadres',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (String? value) {
                              if (value == null || value.length < 6) {
                                return 'Wachtwoord moet min. 6 tekens zijn';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 15, right: 10),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedSquareLock01,
                                  size: 20,
                                ),
                              ),
                              labelText: 'Wachtwoord',
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.tonal(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _submit,
                            child: _isLoading
                                ? const LinearProgressIndicator()
                                : Text(
                                    _isLogin ? 'Inloggen' : 'Registreren',
                                  ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Nog geen account? Registreer'
                                  : 'Heb je al een account? Log in',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
