import 'package:dancefirst/services/firebase_service.dart';
import 'package:dancefirst/services/scroll_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class AuthSlide extends SignalWidget {
  const AuthSlide({
    required this.firebaseService,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    required this.obscurePassword,
    required this.onPreviousPage,
    required this.onSubmit,
    super.key,
  });
  final FirebaseService firebaseService;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final Signal<bool> isLogin;
  final Signal<bool> isLoading;
  final Signal<bool> obscurePassword;
  final VoidCallback onPreviousPage;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLoginVal = isLogin.value;
    final bool isLoadingVal = isLoading.value;
    final bool obscurePasswordVal = obscurePassword.value;

    return Center(
      child: ScrollService(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // AUTH CARD.
              Card(
                elevation: 4,
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: <Widget>[
                    // TAB TOGGLE.
                    ColoredBox(
                      color: theme.colorScheme.primary.withValues(alpha: 240),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                isLogin.value = true;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isLoginVal
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.primary.withAlpha(10),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isLoginVal
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Inloggen',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: isLoginVal
                                        ? FontWeight.bold
                                        : null,
                                    color: isLoginVal
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                isLogin.value = false;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: !isLoginVal
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.primary.withAlpha(10),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: !isLoginVal
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Registreren',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: !isLoginVal
                                        ? FontWeight.bold
                                        : null,
                                    color: !isLoginVal
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Forms Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              isLoginVal
                                  ? 'Welkom terug! Log in op je account.'
                                  : 'Maak een nieuw account aan.',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email input field
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 15),
                              validator: (String? value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Voer een geldig e-mailadres in';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'E-mailadres',
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password input field
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePasswordVal,
                              style: const TextStyle(fontSize: 15),
                              validator: (String? value) {
                                if (value == null || value.length < 6) {
                                  return 'Wachtwoord moet minimaal 6 tekens zijn';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Wachtwoord',
                                prefixIcon: const Icon(
                                  Icons.lock_outlined,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePasswordVal
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    obscurePassword.value = !obscurePasswordVal;
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            FilledButton(
                              onPressed: isLoadingVal ? null : onSubmit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoadingVal
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isLoginVal ? 'Inloggen' : 'Registreren',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),

                            // Forgot Password Text Button (Only for login)
                            if (isLoginVal) ...<Widget>[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () async {
                                  if (emailController.text.isNotEmpty) {
                                    await firebaseService.resetPassword(
                                      emailController.text.trim().toLowerCase(),
                                    );
                                  } else {
                                    ToastService.showWarning(
                                      title: 'Controleer E-mailadres',
                                      subtitle:
                                          'Vul je e-mailadres in om een resetlink te ontvangen.',
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                                child: const Text('Wachtwoord vergeten?'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Button to go back to info slides
              TextButton.icon(
                onPressed: onPreviousPage,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Bekijk info slides'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Preview to test layout
class AuthSlidePreview extends StatelessWidget {
  const AuthSlidePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AuthSlide(
          firebaseService: FirebaseService(),
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          formKey: GlobalKey<FormState>(),
          isLogin: signal<bool>(true),
          isLoading: signal<bool>(false),
          obscurePassword: signal<bool>(true),
          onPreviousPage: () {},
          onSubmit: () async {},
        ),
      ),
    );
  }
}
