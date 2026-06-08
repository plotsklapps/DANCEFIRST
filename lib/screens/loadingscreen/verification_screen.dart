import 'dart:async';

import 'package:dancefirst/services/firebase_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({required this.user, super.key});
  final User user;

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
    // Poll Firebase Auth status every 2 seconds
    _reloadTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await widget.user.reload();
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.emailVerified) {
        _reloadTimer?.cancel();
        // Since authStateChanges might not fire automatically on reload,
        // we can force a token refresh or reload by signing in again
        // or letting the auth state update itself.
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
      appBar: AppBar(
        title: Text(
          'E-mail Verificatie',
          style: GoogleFonts.questrial(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Uitloggen',
            onPressed: () async {
              await FirebaseService().signOut();
            },
          ),
        ],
      ),
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

                          // Title
                          Text(
                            'Verifieer je e-mailadres',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Text
                          Text(
                            'We hebben een verificatielink gestuurd naar:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Spam Warning Alert Banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Geen mail ontvangen?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Controleer altijd je spam- of ongewenste e-mailfolder. Firebase verificatiemails komen daar helaas geregeld in terecht.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme
                                              .colorScheme
                                              .onErrorContainer
                                              .withValues(alpha: 0.85),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Progress Indicator to show active status
                          SizedBox(
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const LinearProgressIndicator(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Wachten op verificatie...',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  if (_cooldownSeconds > 0)
                    Text(
                      'Je kunt de mail opnieuw sturen over $_cooldownSeconds seconden',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _isSending ? null : _resendVerificationEmail,
                      icon: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Mail opnieuw verzenden'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: () async {
                      await FirebaseService().signOut();
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
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
