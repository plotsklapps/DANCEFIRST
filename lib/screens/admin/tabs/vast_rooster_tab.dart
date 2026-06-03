import 'package:dancefirst/constants/icon_library.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class VastRoosterTab extends StatelessWidget {
  const VastRoosterTab({
    required this.firestore,
    required this.showClassDialog,
    super.key,
  });

  final FirestoreService firestore;
  final Function({Map<String, dynamic>? c}) showClassDialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClassDialog(),
        child: const PhosphorIcon(IconLibrary.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getBaseScheduleStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Geen klassen in het rooster.'));
          }

          final classes = snapshot.data!;
          final days = [
            'Maandag',
            'Dinsdag',
            'Woensdag',
            'Donderdag',
            'Vrijdag',
            'Zaterdag',
            'Zondag',
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            itemBuilder: (context, dIdx) {
              final day = days[dIdx];
              final dayClasses = classes.where((c) => c['day'] == day).toList();
              if (dayClasses.isEmpty) return const SizedBox.shrink();
              dayClasses.sort(
                (a, b) => (a['time'] as String).compareTo(b['time'] as String),
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Divider(),
                      ...dayClasses.map(
                        (c) => ListTile(
                          leading: Text(c['time'] as String? ?? ''),
                          title: Text(c['name'] as String? ?? ''),
                          subtitle: Text(
                            'Docent: ${c['teacher']} (${c['type'] == 'adults' ? '18+' : 'Kids'}, Max: ${c['maxParticipants']})',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const PhosphorIcon(
                                  IconLibrary.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => showClassDialog(c: c),
                              ),
                              IconButton(
                                icon: const PhosphorIcon(
                                  IconLibrary.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await firestore.deleteBaseScheduleClass(
                                    c['id'] as String,
                                  );
                                  ToastService.showSuccess(
                                    title: 'Les verwijderd',
                                    subtitle: 'Les succesvol verwijderd.',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
