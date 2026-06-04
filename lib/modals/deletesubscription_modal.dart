import 'package:dancefirst/modals/modal_title.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';

class DeleteSubscriptionModal extends StatelessWidget {
  const DeleteSubscriptionModal({
    required this.subscription,
    super.key,
  });

  final Map<String, dynamic> subscription;

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ModalTitle(title: 'Abonnement Verwijderen'),
        Text(
          'Weet je zeker dat je ${subscription['name']} wilt verwijderen? '
          'Dit kan invloed hebben op actieve inschrijvingen.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuleren'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  await firestoreService.deleteSubscription(
                    subscription['id'] as String,
                  );
                  ToastService.showSuccess(
                    title: 'Abonnement verwijderd',
                    subtitle: 'Het abonnement is permanent gewist.',
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Verwijderen'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
