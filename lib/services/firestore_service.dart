import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USER & ROLES ---
  Future<String> getUserRole(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _db
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data()?['role'] as String? ?? 'client';
      }
      return 'client';
    } on Exception catch (_) {
      return 'client';
    }
  }

  Future<void> createUserDocument(String uid, String email) async {
    final String role =
        (email == 'dancefirstalkmaar@gmail.com' ||
            email == 'plotsklapps@gmail.com')
        ? 'admin'
        : 'client';
    await _db.collection('users').doc(uid).set(<String, dynamic>{
      'uid': uid,
      'email': email,
      'role': role,
    }, SetOptions(merge: true));
  }

  // --- PROFILES (FOR FAMILY ACCOUNTS) ---
  Stream<List<Map<String, dynamic>>> getProfilesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> addProfile(
    String uid, {
    required String name,
    required String type,
    required String dob,
    required String tariff,
  }) async {
    await _db.collection('users').doc(uid).collection('profiles').add(
      <String, dynamic>{
        'name': name,
        'type': type,
        'dob': dob,
        'tariff': tariff,
      },
    );
  }

  Future<void> deleteProfile(String uid, String profileId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId)
        .delete();
  }

  // --- BASE SCHEDULE ---
  Stream<List<Map<String, dynamic>>> getBaseScheduleStream() {
    return _db.collection('base_schedule').snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      return snapshot.docs.map((
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> saveBaseScheduleClass({
    required String day,
    required String time,
    required String name,
    required String teacher,
    required String type,
    required int maxParticipants,
    String? id,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'day': day,
      'time': time,
      'name': name,
      'teacher': teacher,
      'type': type,
      'maxParticipants': maxParticipants,
    };
    if (id == null) {
      await _db.collection('base_schedule').add(data);
    } else {
      await _db
          .collection('base_schedule')
          .doc(id)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteBaseScheduleClass(String id) async {
    await _db.collection('base_schedule').doc(id).delete();
  }

  // --- SCHEDULE OVERRIDES (AD-HOC CHANGES) ---
  Stream<List<Map<String, dynamic>>> getScheduleOverridesStream(String date) {
    return _db
        .collection('schedule_overrides')
        .where('date', isEqualTo: date)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> saveScheduleOverride({
    required String date,
    required String classId,
    required bool isCancelled,
    String? teacherOverride,
    String? timeOverride,
    String? nameOverride,
    String? notes,
  }) async {
    final String docId = '${date}_$classId';
    final Map<String, dynamic> data = <String, dynamic>{
      'date': date,
      'classId': classId,
      'isCancelled': isCancelled,
    };
    if (teacherOverride != null) {
      data['teacherOverride'] = teacherOverride;
    }
    if (timeOverride != null) {
      data['timeOverride'] = timeOverride;
    }
    if (nameOverride != null) {
      data['nameOverride'] = nameOverride;
    }
    if (notes != null) {
      data['notes'] = notes;
    }
    await _db
        .collection('schedule_overrides')
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> removeScheduleOverride(String date, String classId) async {
    final String docId = '${date}_$classId';
    await _db.collection('schedule_overrides').doc(docId).delete();
  }

  // --- BOOKINGS ---
  Stream<List<Map<String, dynamic>>> getBookingsStream(
    String date,
    String classId,
  ) {
    return _db
        .collection('bookings')
        .where('date', isEqualTo: date)
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getUserBookingsStream(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<bool> bookClass({
    required String date,
    required String classId,
    required String profileId,
    required String userId,
    required String profileName,
    required int maxParticipants,
  }) async {
    final String docId = '${date}_${classId}_$profileId';
    final DocumentReference<Map<String, dynamic>> docRef = _db
        .collection('bookings')
        .doc(docId);

    return _db.runTransaction((Transaction transaction) async {
      final QuerySnapshot<Map<String, dynamic>> currentBookings = await _db
          .collection('bookings')
          .where('date', isEqualTo: date)
          .where('classId', isEqualTo: classId)
          .get();

      if (currentBookings.docs.length >= maxParticipants) {
        return false;
      }

      transaction.set(docRef, <String, dynamic>{
        'date': date,
        'classId': classId,
        'profileId': profileId,
        'userId': userId,
        'profileName': profileName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  Future<void> cancelBooking({
    required String date,
    required String classId,
    required String profileId,
  }) async {
    final String docId = '${date}_${classId}_$profileId';
    await _db.collection('bookings').doc(docId).delete();
  }

  // --- REGISTRATIONS ---
  Future<void> submitRegistration(Map<String, dynamic> data) async {
    data['status'] = 'pending';
    data['timestamp'] = FieldValue.serverTimestamp();
    await _db.collection('registrations').add(data);
  }

  Stream<List<Map<String, dynamic>>> getPendingRegistrationsStream() {
    return _db
        .collection('registrations')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> updateRegistrationStatus(String regId, String status) async {
    await _db.collection('registrations').doc(regId).update(<String, dynamic>{
      'status': status,
    });
  }
}
