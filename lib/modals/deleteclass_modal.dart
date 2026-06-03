import 'package:dancefirst/modals/modal_title.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:flutter/material.dart';

class DeleteClassModal extends StatelessWidget {
  const DeleteClassModal({
    this.c,
    super.key,
  });

  final Map<String, dynamic>? c;

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const ModalTitle(title: 'Les Verwijderen'),
          const Text('Weet je zeker dat je deze les wilt verwijderen?'),
          const SizedBox(height: 20),
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
                    await firestoreService.deleteBaseScheduleClass(
                      c?['id'] as String,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Verwijderen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
