import 'package:dancefirst/services/firebase_service.dart';
import 'package:dancefirst/services/scroll_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class LoginScreen extends SignalStatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Signal<bool> _isLogin = signal<bool>(
    true,
    options: const SignalOptions<bool>(
      name: '_isLogin',
      autoDispose: true,
    ),
  );
  final Signal<bool> _isLoading = signal<bool>(
    false,
    options: const SignalOptions<bool>(
      name: '_isLoading',
      autoDispose: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ScrollService(
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: <Widget>[
                // HEADER.
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: Image.asset(
                      'assets/dfLogoWhite.png',
                    ),
                  ),
                ),
                // FORM.
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _isLogin.value ? 'Inloggen' : 'Registreren',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
                            prefixIcon: Icon(Icons.email_outlined),
                            labelText: 'E-mailadres',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: (String? value) {
                            if (value == null || value.length < 6) {
                              return 'Wachtwoord moet minimaal 6 tekens zijn';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outlined),
                            labelText: 'Wachtwoord',
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: _submit,
                          child: _isLoading.value
                              ? const LinearProgressIndicator()
                              : Text(
                                  _isLogin.value ? 'Inloggen' : 'Registreren',
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _isLogin.value = !_isLogin.value;
                          },
                          child: Text(
                            _isLogin.value
                                ? 'Nog geen account?'
                                : 'Heb je al een account?',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_emailController.text.isNotEmpty) {
                              await _firebaseService.resetPassword(
                                _emailController.text.trim().toLowerCase(),
                              );
                            } else {
                              ToastService.showWarning(
                                title: 'Controleer Emailadres',
                                subtitle:
                                    'Vul je emailadres in om een '
                                    'resetlink te ontvangen.',
                              );
                            }
                          },
                          child: const Text(
                            'Wachtwoord vergeten?',
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
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _isLoading.value = true;

    try {
      if (_isLogin.value) {
        await _firebaseService.signIn(
          _emailController.text.trim().toLowerCase(),
          _passwordController.text.trim(),
        );
      } else {
        await _firebaseService.signUp(
          _emailController.text.trim().toLowerCase(),
          _passwordController.text.trim(),
        );
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }
}
