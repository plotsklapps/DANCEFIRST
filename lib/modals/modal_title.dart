import 'package:flutter/material.dart';

class ModalTitle extends StatelessWidget {
  const ModalTitle({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(width: 48),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
