import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dancefirst/models/danceclass_model.dart';
import 'package:dancefirst/models/sportsclass_model.dart';
import 'package:dancefirst/services/firestore_service.dart';

class SeedService {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    // 1. Clear existing schedule
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('base_schedule')
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // 2. Re-seed Kids
    for (final MapEntry<String, List<DanceClass>> entry in dkRooster.entries) {
      for (final DanceClass c in entry.value) {
        await _firestore.saveBaseScheduleClass(
          day: entry.key,
          time: c.time,
          name: c.name,
          teacher: c.teacher,
          type: 'kids',
          maxParticipants: 20,
        );
      }
    }

    // 3. Re-seed Adults
    for (final MapEntry<String, List<SportsClass>> entry in dfRooster.entries) {
      for (final SportsClass c in entry.value) {
        await _firestore.saveBaseScheduleClass(
          day: entry.key,
          time: c.time,
          name: c.name,
          teacher: c.teacher,
          type: 'adults',
          maxParticipants: 20,
        );
      }
    }
  }
}
