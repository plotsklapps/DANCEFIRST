import 'package:flutter/material.dart';

class AccountSlide extends StatelessWidget {
  const AccountSlide({super.key});

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
              radius: 64,
              backgroundColor: theme.colorScheme.primary.withAlpha(50),
              child: Icon(
                Icons.lock_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Account is Verplicht',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Om je aan te melden voor lessen, het actuele rooster in te zien en abonnementen te beheren, is een account noodzakelijk. Veilig en overzichtelijk voor iedereen.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
