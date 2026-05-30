import 'package:dancefirst/services/firebase_service.dart';
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

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
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
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _isLogin ? 'Inloggen' : 'Registreren',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedMail01,
                            ),
                          ),
                          labelText: 'Emailadres',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 18),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSquareLock01,
                            ),
                          ),
                          labelText: 'Wachtwoord',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const LinearProgressIndicator(year2023: false)
                      else
                        FilledButton.tonal(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Inloggen' : 'Registreren'),
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
            ],
          ),
        ),
      ),
    );
  }
}
