import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dancefirst/models/danceclass_model.dart';
import 'package:dancefirst/models/sportsclass_model.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';

// Dedicated service to refresh dkRooster en dfRooster from Firestore.
class SeedService {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    // Clear existing schedule.
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('base_schedule')
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      await doc.reference.delete();
    }

    // Re-seed Kids.
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

    // Re-seed Adults.
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

    // Show toast to user.
    ToastService.showSuccess(
      title: 'Rooster ververst',
      subtitle: 'Meest recente rooster ingeladen vanuit Firebase.',
    );
  }
}
