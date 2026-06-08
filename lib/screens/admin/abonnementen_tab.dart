import 'package:dancefirst/modals/deletesubscription_modal.dart';
import 'package:dancefirst/modals/editsubscription_modal.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/modal_service.dart';
import 'package:flutter/material.dart';

class AbonnementenTab extends StatefulWidget {
  const AbonnementenTab({super.key});

  @override
  State<AbonnementenTab> createState() => _AbonnementenTabState();
}

class _AbonnementenTabState extends State<AbonnementenTab> {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ModalService.showModal(
            context: context,
            child: const EditSubscriptionModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getSubscriptionsStream(),
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Geen abonnementen gevonden.'),
                );
              }

              // Groepeer op categorie
              final List<Map<String, dynamic>> kids = snapshot.data!
                  .where(
                    (Map<String, dynamic> s) => s['category'] == 'DanceKids',
                  )
                  .toList();
              final List<Map<String, dynamic>> adults = snapshot.data!
                  .where(
                    (Map<String, dynamic> s) => s['category'] == 'DanceFirst',
                  )
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  if (kids.isNotEmpty) ...<Widget>[
                    const SectionHeader(title: 'DanceKids (4-18 jaar)'),
                    ...kids.map(
                      _buildSubscriptionCard,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (adults.isNotEmpty) ...<Widget>[
                    const SectionHeader(title: 'DanceFirst (18+)'),
                    ...adults.map(
                      _buildSubscriptionCard,
                    ),
                  ],
                ],
              );
            },
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> s) {
    final bool isActive = s['isActive'] as bool? ?? true;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isActive ? 2 : 0,
      color: isActive ? null : Colors.grey[100],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.cyan[100] : Colors.grey[300],
          child: Text(
            s['id'].toString().substring(0, 2),
            style: TextStyle(
              color: isActive ? Colors.cyan[900] : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: <Widget>[
            Text(s['name'] as String? ?? ''),
            const SizedBox(width: 8),
            if (!isActive)
              const Badge(
                label: Text('Gearchiveerd'),
                backgroundColor: Colors.grey,
              ),
          ],
        ),
        subtitle: Text('Code: ${s['id']} | Prijs: €${s['price']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                await ModalService.showModal(
                  context: context,
                  child: EditSubscriptionModal(subscription: s),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await ModalService.showModal(
                  context: context,
                  child: DeleteSubscriptionModal(subscription: s),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
