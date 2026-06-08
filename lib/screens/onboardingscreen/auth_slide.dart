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
                      color: theme.cardColor,
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
                                      : theme.cardColor,
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
                                      : theme.cardColor,
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

                    // FORM.
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
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 20),

                            // EMAIL.
                            TextFormField(
                              controller: emailController,
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
                                labelText: 'E-mailadres',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // PASSWORD.
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePasswordVal,
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
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePasswordVal
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    obscurePassword.value = !obscurePasswordVal;
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // SUBMIT BUTTON.
                            FilledButton(
                              onPressed: isLoadingVal ? null : onSubmit,
                              child: isLoadingVal
                                  ? const SizedBox(
                                      width: double.infinity,
                                      child: LinearProgressIndicator(),
                                    )
                                  : Text(
                                      isLoginVal ? 'Inloggen' : 'Registreren',
                                    ),
                            ),

                            // FORGOT PASSWORD.
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
            ],
          ),
        ),
      ),
    );
  }
}
