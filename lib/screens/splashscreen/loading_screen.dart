import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/dfLogoBlack.png', width: 200),
            const SizedBox(height: 32),
            const SizedBox(width: 200, child: LinearProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
