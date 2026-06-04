import 'package:dancefirst/modals/deleteclass_modal.dart';
import 'package:dancefirst/modals/editclass_modal.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/modal_service.dart';
import 'package:flutter/material.dart';

class VastRoosterTab extends StatelessWidget {
  const VastRoosterTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getBaseScheduleStream(),
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LinearProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Geen lessen in het rooster.'));
              }

              final List<Map<String, dynamic>> classes = snapshot.data!;
              final List<String> days = <String>[
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
                itemBuilder: (BuildContext context, int dIdx) {
                  final String day = days[dIdx];
                  final List<Map<String, dynamic>> dayClasses = classes.where(
                    (Map<String, dynamic> classData) {
                      return classData['day'] == day;
                    },
                  ).toList();
                  if (dayClasses.isEmpty) return const SizedBox.shrink();
                  dayClasses.sort(
                    (Map<String, dynamic> a, Map<String, dynamic> b) {
                      return (a['time'] as String).compareTo(
                        b['time'] as String,
                      );
                    },
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                            (Map<String, dynamic> classData) => ListTile(
                              leading: Text(
                                classData['time'] as String? ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              title: Text(
                                classData['name'] as String? ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Docent: ${classData['teacher']} '
                                '(${classData['type'] == 'adults' ? '18+'
                                          '' : 'Kids'})',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    onPressed: () async {
                                      await ModalService.showModal(
                                        context: context,
                                        child: EditClassModal(
                                          classData: classData,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    onPressed: () async {
                                      await ModalService.showModal(
                                        context: context,
                                        child: DeleteClassModal(
                                          classData: classData,
                                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ModalService.showModal(
            context: context,
            child: const EditClassModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
