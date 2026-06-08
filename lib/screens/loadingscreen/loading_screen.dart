import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      // GRADIENT BACKGROUND.
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ANIMATED LOGO.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (BuildContext context, double scale, Widget? child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/dfLogoBlack.png',
                  width: 180,
                ),
              ),
              const SizedBox(height: 48),
              // LOADING INDICATOR.
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(year2023: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
