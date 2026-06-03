import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dancefirst/services/firestore_service.dart';

class ScheduleSyncService {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> syncSchedule() async {
    final QuerySnapshot<Object> existingClasses = await _db
        .collection('base_schedule')
        .get();
    final QuerySnapshot<Object> templates = await _db
        .collection('schedule_templates')
        .get();

    for (final QueryDocumentSnapshot<Object?> doc in templates.docs) {
      final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

      final bool exists = existingClasses.docs.any((
        QueryDocumentSnapshot<Object?> d,
      ) {
        final Map<String, dynamic> dData = d.data()! as Map<String, dynamic>;
        return dData['day'] == data['day'] &&
            dData['time'] == data['time'] &&
            dData['name'] == data['name'];
      });

      if (!exists) {
        await _firestore.saveBaseScheduleClass(
          day: data['day'] as String,
          time: data['time'] as String,
          name: data['name'] as String,
          teacher: data['teacher'] as String,
          type: data['type'] as String,
          maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 20,
        );
      }
    }
  }
}
