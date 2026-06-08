import 'dart:async';

import 'package:dancefirst/services/firebase_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    required this.user,
    required this.onVerified,
    super.key,
  });
  final User user;
  final VoidCallback onVerified;

  @override
  State<VerificationScreen> createState() {
    return _VerificationScreenState();
  }
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _reloadTimer;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _reloadTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await widget.user.reload();
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.emailVerified) {
        _reloadTimer?.cancel();
        widget.onVerified();
      }
    });
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 30;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        _cooldownTimer?.cancel();
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_cooldownSeconds > 0 || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await widget.user.sendEmailVerification();
      ToastService.showSuccess(
        title: 'E-mail Verzonden',
        subtitle: 'Verificatie-e-mail is opnieuw verzonden.',
      );
      _startCooldown();
    } on Exception catch (_) {
      ToastService.showError(
        title: 'Verzenden Mislukt',
        subtitle: 'Probeer het later nog eens.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primaryContainer.withValues(alpha: 100),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 100),
            ],
            stops: const <double>[0, 0.4, 0.8, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // VERIFICATION CARD.
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // ICON.
                          CircleAvatar(
                            radius: 64,
                            backgroundColor: theme.colorScheme.primary
                                .withAlpha(50),
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // TITLE.
                          Text(
                            'Verifieer je e-mailadres',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TEXT.
                          const Text(
                            'We hebben een verificatielink gestuurd naar:',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.user.email ?? '',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // SPAM BANNER.
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer.withAlpha(
                                100,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error.withAlpha(50),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Geen mail ontvangen?',
                                        style: theme.textTheme.bodyMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme
                                                  .colorScheme
                                                  .onErrorContainer,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Controleer altijd je spam- of '
                                        'ongewenste e-mailfolder. Onze '
                                        'verificatiemails komen daar helaas geregeld in terecht.',
                                        style: theme.textTheme.bodySmall!
                                            .copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onErrorContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // LOADING INDICATOR.
                          const SizedBox(
                            width: 180,
                            child: LinearProgressIndicator(
                              year2023: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Wachten op verificatie...',
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ACTIONS.
                  if (_cooldownSeconds > 0)
                    Text(
                      'Je kunt de mail opnieuw sturen over $_cooldownSeconds seconden',
                      textAlign: TextAlign.center,
                    )
                  else
                    FilledButton.icon(
                      onPressed: _isSending ? null : _resendVerificationEmail,
                      icon: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(year2023: false),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Mail opnieuw verzenden'),
                    ),

                  const SizedBox(height: 24),

                  TextButton.icon(
                    onPressed: () async {
                      await FirebaseService().signOut();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: 16,
                    ),
                    label: const Text('Terug naar inloggen'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
