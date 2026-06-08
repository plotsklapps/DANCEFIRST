import 'package:flutter/material.dart';

class ProfilesSlide extends StatelessWidget {
  const ProfilesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withAlpha(50),
              radius: 64,
              child: Icon(
                Icons.people_alt_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Meerdere Profielen',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dansen er meerdere personen binnen jouw gezin? Geen probleem! '
              'Onder één account kun je eenvoudig meerdere profielen aanmaken en beheren.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
