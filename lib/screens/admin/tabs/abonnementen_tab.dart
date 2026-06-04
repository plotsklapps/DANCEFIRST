import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';

class AbonnementenTab extends StatefulWidget {
  const AbonnementenTab({super.key});

  @override
  State<AbonnementenTab> createState() => _AbonnementenTabState();
}

class _AbonnementenTabState extends State<AbonnementenTab> {
  final FirestoreService _firestore = FirestoreService();

  void _showSubscriptionDialog({Map<String, dynamic>? subscription}) {
    final bool isEdit = subscription != null;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController idController = TextEditingController(
      text: isEdit ? (subscription['id'] as String? ?? '') : '',
    );
    final TextEditingController nameController = TextEditingController(
      text: isEdit ? (subscription['name'] as String? ?? '') : '',
    );
    final TextEditingController priceController = TextEditingController(
      text: isEdit ? (subscription['price']?.toString() ?? '') : '',
    );
    final TextEditingController descController = TextEditingController(
      text: isEdit ? (subscription['description'] as String? ?? '') : '',
    );

    String category = isEdit
        ? (subscription['category'] as String? ?? 'DanceKids')
        : 'DanceKids';
    bool isActive = isEdit ? (subscription['isActive'] as bool? ?? true) : true;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Abonnement Bewerken' : 'Nieuw Abonnement'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Categorie',
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'DanceKids',
                            child: Text('DanceKids (4-18 jaar)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'DanceFirst',
                            child: Text('DanceFirst (18+)'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: idController,
                        enabled: !isEdit, // ID cannot be changed once created
                        decoration: const InputDecoration(
                          labelText: 'Abonnement Code (bijv. DK-1-J)',
                        ),
                        validator: (String? v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Code is verplicht';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Naam (bijv. 1x per week jaar)',
                        ),
                        validator: (String? v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Naam is verplicht';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Prijs per maand (€)',
                        ),
                        validator: (String? v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Prijs is verplicht';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'Geef een getal op';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Beschrijving (Optioneel)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text(
                          'Actief (Zichtbaar bij inschrijving)',
                        ),
                        value: isActive,
                        onChanged: (bool value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await _firestore.saveSubscription(
                        id: idController.text.trim().toUpperCase(),
                        category: category,
                        name: nameController.text.trim(),
                        price: double.parse(priceController.text.trim()),
                        description: descController.text.trim(),
                        isActive: isActive,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      ToastService.showSuccess(
                        title: isEdit
                            ? 'Abonnement bijgewerkt'
                            : 'Abonnement toegevoegd',
                        subtitle: 'De wijziging is opgeslagen in Firestore.',
                      );
                    }
                  },
                  child: const Text('Opslaan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubscriptionDialog(),
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
                      (Map<String, dynamic> s) => _buildSubscriptionCard(s),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (adults.isNotEmpty) ...<Widget>[
                    const SectionHeader(title: 'DanceFirst (18+)'),
                    ...adults.map(
                      (Map<String, dynamic> s) => _buildSubscriptionCard(s),
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
              onPressed: () => _showSubscriptionDialog(subscription: s),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Abonnement Verwijderen?'),
                    content: Text(
                      'Weet je zeker dat je ${s['name']} wilt verwijderen? '
                      'Dit kan invloed hebben op actieve inschrijvingen.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuleren'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _firestore.deleteSubscription(
                            s['id'] as String,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          ToastService.showSuccess(
                            title: 'Abonnement verwijderd',
                            subtitle: 'Het abonnement is permanent gewist.',
                          );
                        },
                        child: const Text('Verwijderen'),
                      ),
                    ],
                  ),
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
