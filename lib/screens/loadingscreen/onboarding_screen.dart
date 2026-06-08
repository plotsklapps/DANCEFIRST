import 'package:dancefirst/services/firebase_service.dart';
import 'package:dancefirst/services/scroll_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals/signals_flutter.dart';

class OnboardingScreen extends SignalStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Signal<int> _currentPage = signal<int>(0);
  final Signal<bool> _isLogin = signal<bool>(true);
  final Signal<bool> _isLoading = signal<bool>(false);
  final Signal<bool> _obscurePassword = signal<bool>(true);

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage.value < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
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
    } catch (_) {
      // Errors are handled inside FirebaseService
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int currentPageVal = _currentPage.watch(context);
    final bool isLoginVal = _isLogin.watch(context);
    final bool isLoadingVal = _isLoading.watch(context);
    final bool obscurePasswordVal = _obscurePassword.watch(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primaryContainer.withOpacity(0.4),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.primary.withOpacity(0.08),
            ],
            stops: const <double>[0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Top Brand Header (Static across all onboarding pages)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/dfLogoBlack.png',
                      height: 36,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Text(
                          'DanceFirst',
                          style: GoogleFonts.questrial(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Main Slider View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int page) {
                    _currentPage.value = page;
                  },
                  children: <Widget>[
                    _buildWelcomeSlide(theme),
                    _buildAccountMandatorySlide(theme),
                    _buildMultiProfilesSlide(theme),
                    _buildAuthSlide(theme, isLoginVal, isLoadingVal, obscurePasswordVal),
                  ],
                ),
              ),

              // Bottom Navigation & Indicators (Only show if not on the Auth Slide)
              if (currentPageVal < 3)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Previous button (Disabled or hidden on first slide)
                      Opacity(
                        opacity: currentPageVal > 0 ? 1.0 : 0.0,
                        child: TextButton(
                          onPressed: currentPageVal > 0 ? _previousPage : null,
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text(
                            'Vorige',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Animated dot indicators
                      Row(
                        children: List<Widget>.generate(4, (int index) {
                          final bool isActive = index == currentPageVal;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 24 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Next button
                      FilledButton(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text(
                              'Volgende',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
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

  // --- SLIDE BUILDERS ---

  Widget _buildWelcomeSlide(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Dance first, think later',
              textAlign: TextAlign.center,
              style: GoogleFonts.questrial(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welkom bij DanceFirst! Dé plek waar passie, plezier en dans samenkomen. Laten we jouw dansavontuur beginnen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMandatorySlide(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Account is Verplicht',
              textAlign: TextAlign.center,
              style: GoogleFonts.questrial(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Om je aan te melden voor lessen, het actuele rooster in te zien en abonnementen te beheren, is een account noodzakelijk. Veilig en overzichtelijk voor iedereen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiProfilesSlide(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_alt_rounded,
                size: 80,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Meerdere Profielen',
              textAlign: TextAlign.center,
              style: GoogleFonts.questrial(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dansen er meerdere kinderen binnen jouw gezin? Geen probleem! Onder één account kun je eenvoudig meerdere profielen aanmaken en beheren.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSlide(
    ThemeData theme,
    bool isLoginVal,
    bool isLoadingVal,
    bool obscurePasswordVal,
  ) {
    return Center(
      child: ScrollService(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Elegant Auth Card
              Card(
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: <Widget>[
                    // Tab-like Toggle Button Header
                    Container(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () => _isLogin.value = true,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isLoginVal
                                      ? theme.colorScheme.surface
                                      : Colors.transparent,
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
                                  style: TextStyle(
                                    fontWeight:
                                        isLoginVal ? FontWeight.bold : FontWeight.w500,
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
                              onTap: () => _isLogin.value = false,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: !isLoginVal
                                      ? theme.colorScheme.surface
                                      : Colors.transparent,
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
                                  style: TextStyle(
                                    fontWeight:
                                        !isLoginVal ? FontWeight.bold : FontWeight.w500,
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
                        key: _formKey,
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
                              controller: _emailController,
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
                                prefixIcon: const Icon(Icons.email_outlined, size: 20),
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
                              controller: _passwordController,
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
                                prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePasswordVal
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _obscurePassword.value = !obscurePasswordVal;
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
                              onPressed: isLoadingVal ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  if (_emailController.text.isNotEmpty) {
                                    await _firebaseService.resetPassword(
                                      _emailController.text.trim().toLowerCase(),
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
                onPressed: _previousPage,
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
