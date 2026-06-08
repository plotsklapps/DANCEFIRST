import 'package:dancefirst/screens/onboardingscreen/account_slide.dart';
import 'package:dancefirst/screens/onboardingscreen/auth_slide.dart';
import 'package:dancefirst/screens/onboardingscreen/profiles_slide.dart';
import 'package:dancefirst/screens/onboardingscreen/welcome_slide.dart';
import 'package:dancefirst/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class OnboardingScreen extends SignalStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() {
    return _OnboardingScreenState();
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Signal<int> _currentPage = signal<int>(
    0,
    options: const SignalOptions<int>(name: '_currentPage'),
  );
  final Signal<bool> _isLogin = signal<bool>(
    true,
    options: const SignalOptions<bool>(name: '_isLogin'),
  );
  final Signal<bool> _isLoading = signal<bool>(
    false,
    options: const SignalOptions<bool>(name: '_isLoading'),
  );
  final Signal<bool> _obscurePassword = signal<bool>(
    true,
    options: const SignalOptions<bool>(name: '_obscurePassword'),
  );

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage.value < 3) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage.value > 0) {
      await _pageController.previousPage(
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
    } on Exception catch (_) {
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
    final int currentPageVal = _currentPage.value;

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
          child: Column(
            children: <Widget>[
              // HEADER.
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/dfLogoBlack.png',
                      height: 36,
                    ),
                  ],
                ),
              ),

              // MAIN SLIDER.
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int page) {
                    _currentPage.value = page;
                  },
                  children: <Widget>[
                    const WelcomeSlide(),
                    const AccountSlide(),
                    const ProfilesSlide(),
                    AuthSlide(
                      firebaseService: _firebaseService,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      formKey: _formKey,
                      isLogin: _isLogin,
                      isLoading: _isLoading,
                      obscurePassword: _obscurePassword,
                      onPreviousPage: _previousPage,
                      onSubmit: _submit,
                    ),
                  ],
                ),
              ),

              // BOTTOM NAVIGATION.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // PREVIOUS BUTTON (Conditional).
                    Opacity(
                      opacity: currentPageVal > 0 ? 1.0 : 0.0,
                      child: TextButton(
                        onPressed: currentPageVal > 0 ? _previousPage : null,
                        child: Text(
                          'Vorige',
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    // DOT INDICATORS (Conditional).
                    if (currentPageVal < 3)
                      Row(
                        children: List<Widget>.generate(3, (int index) {
                          final bool isActive = index == currentPageVal;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 24 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 200,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                    // NEXT BUTTON (Conditional).
                    if (currentPageVal < 3)
                      FilledButton(
                        onPressed: _nextPage,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Volgende'),
                            SizedBox(width: 4),
                            Icon(Icons.navigate_next),
                          ],
                        ),
                      )
                    else
                      const SizedBox(
                        width: 48,
                      ), // Spacer to keep layout balanced
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
