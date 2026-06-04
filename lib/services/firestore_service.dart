import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // USER ROLE.
  Future<String> getUserRole() async {
    // Fetch current User Object.
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'client';

    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _database
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        // Check of user 'admin' is of 'client'.
        return doc.data()?['role'] as String? ?? 'client';
      }
      return 'client';
    } on Exception catch (e) {
      // Log error.
      _logger.e('Error in getUserRole: $e');

      return 'client';
    }
  }

  // USER DOC.
  Future<void> createUserDocument(String uid, String email) async {
    // Laila and Jeremy are admin.
    final String role =
        (email == 'dancefirstalkmaar@gmail.com' ||
            email == 'plotsklapps@gmail.com')
        ? 'admin'
        : 'client';

    // Create new user doc with correct role.
    await _database.collection('users').doc(uid).set(<String, dynamic>{
      'uid': uid,
      'email': email,
      'role': role,
    }, SetOptions(merge: true));
  }

  // --- SUBSCRIPTIONS (TARIEVEN) ---
  Stream<List<Map<String, dynamic>>> getSubscriptionsStream() {
    return _database.collection('subscriptions').snapshots().map((
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

  Future<void> saveSubscription({
    required String id,
    required String category,
    required String name,
    required double price,
    required String description,
    required bool isActive,
  }) async {
    await _database.collection('subscriptions').doc(id).set(<String, dynamic>{
      'category': category,
      'name': name,
      'price': price,
      'description': description,
      'isActive': isActive,
    }, SetOptions(merge: true));
  }

  Future<void> populateInitialSubscriptions() async {
    final QuerySnapshot<Map<String, dynamic>> existing = await _database
        .collection('subscriptions')
        .get();
    if (existing.docs.isNotEmpty) return; // Already populated

    final List<Map<String, dynamic>> initialPlans = <Map<String, dynamic>>[
      // DanceKids
      <String, dynamic>{
        'id': 'DK-1-M',
        'category': 'DanceKids',
        'name': '1x per week, maandelijks opzegbaar',
        'price': 45.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-1-HJ',
        'category': 'DanceKids',
        'name': '1x per week, halfjaar abonnement',
        'price': 37.50,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-1-J',
        'category': 'DanceKids',
        'name': '1x per week, jaar abonnement',
        'price': 30.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-2-M',
        'category': 'DanceKids',
        'name': '2x per week, maandelijks opzegbaar',
        'price': 60.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-2-HJ',
        'category': 'DanceKids',
        'name': '2x per week, halfjaar abonnement',
        'price': 52.50,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-2-J',
        'category': 'DanceKids',
        'name': '2x per week, jaar abonnement',
        'price': 45.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-O-M',
        'category': 'DanceKids',
        'name': 'Onbeperkt, maandelijks opzegbaar',
        'price': 75.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-O-HJ',
        'category': 'DanceKids',
        'name': 'Onbeperkt, halfjaar abonnement',
        'price': 67.50,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DK-O-J',
        'category': 'DanceKids',
        'name': 'Onbeperkt, jaar abonnement',
        'price': 60.00,
        'description': '',
        'isActive': true,
      },
      // DanceFirst
      <String, dynamic>{
        'id': 'DF-1-M',
        'category': 'DanceFirst',
        'name': '1x per week, maandelijks opzegbaar',
        'price': 45.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-1-J',
        'category': 'DanceFirst',
        'name': '1x per week, 1 jaar abonnement',
        'price': 37.50,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-1-2J',
        'category': 'DanceFirst',
        'name': '1x per week, 2 jaar abonnement',
        'price': 30.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-2-M',
        'category': 'DanceFirst',
        'name': '2x per week, maandelijks opzegbaar',
        'price': 60.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-2-J',
        'category': 'DanceFirst',
        'name': '2x per week, 1 jaar abonnement',
        'price': 52.50,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-2-2J',
        'category': 'DanceFirst',
        'name': '2x per week, 2 jaar abonnement',
        'price': 45.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-O-M',
        'category': 'DanceFirst',
        'name': 'Onbeperkt, maandelijks opzegbaar',
        'price': 65.00,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-O-J',
        'category': 'DanceFirst',
        'name': 'Onbeperkt, 1 jaar abonnement',
        'price': 57.50,
        'description': '',
        'isActive': true,
      },
      <String, dynamic>{
        'id': 'DF-O-2J',
        'category': 'DanceFirst',
        'name': 'Onbeperkt, 2 jaar abonnement',
        'price': 50.00,
        'description': '',
        'isActive': true,
      },
    ];

    final WriteBatch batch = _database.batch();
    for (final Map<String, dynamic> plan in initialPlans) {
      final DocumentReference<Map<String, dynamic>> ref = _database
          .collection('subscriptions')
          .doc(plan['id'] as String);
      batch.set(ref, <String, dynamic>{
        'category': plan['category'],
        'name': plan['name'],
        'price': plan['price'],
        'description': plan['description'],
        'isActive': plan['isActive'],
      });
    }
    await batch.commit();
  }

  Future<void> deleteSubscription(String id) async {
    await _database.collection('subscriptions').doc(id).delete();
  }

  // --- PROFILES (FOR FAMILY ACCOUNTS) ---
  Stream<List<Map<String, dynamic>>> getProfilesStream(String uid) {
    return _database
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

  Future<void> saveProfile(
    String uid, {
    required String firstName,
    required String lastName,
    required String phone,
    required String dob,
    required String type,
    required String address,
    required String postalCode,
    required String city,
    required String iban,
    required String accountHolder,
    required bool mandateAccepted,
    required String selectedSubscriptionId,
    required String signaturePng,
    String? profileId,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dob': dob,
      'type': type,
      'address': address,
      'postalCode': postalCode,
      'city': city,
      'iban': iban,
      'accountHolder': accountHolder,
      'mandateAccepted': mandateAccepted,
      'selectedSubscriptionId': selectedSubscriptionId,
      'signaturePng': signaturePng,
    };

    if (profileId == null) {
      await _database
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .add(data);
    } else {
      await _database
          .collection('users')
          .doc(uid)
          .collection('profiles')
          .doc(profileId)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteProfile(String uid, String profileId) async {
    await _database
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId)
        .delete();
  }

  // --- BASE SCHEDULE ---
  Stream<List<Map<String, dynamic>>> getBaseScheduleStream() {
    return _database.collection('base_schedule').snapshots().map((
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

  // --- MERGED SCHEDULE STREAM ---
  Stream<List<Map<String, dynamic>>> getMergedScheduleStream(String date) {
    return CombineLatestStream.combine2(
      getBaseScheduleStream(),
      getScheduleOverridesStream(date),
      (List<Map<String, dynamic>> base, List<Map<String, dynamic>> overrides) {
        return base.map((Map<String, dynamic> baseClass) {
          final Map<String, dynamic> override = overrides.firstWhere(
            (Map<String, dynamic> o) => o['classId'] == baseClass['id'],
            orElse: () => <String, dynamic>{},
          );
          return <String, dynamic>{...baseClass, ...override};
        }).toList();
      },
    );
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
      await _database.collection('base_schedule').add(data);
    } else {
      await _database
          .collection('base_schedule')
          .doc(id)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteBaseScheduleClass(String id) async {
    await _database.collection('base_schedule').doc(id).delete();
  }

  // --- SCHEDULE OVERRIDES (AD-HOC CHANGES) ---
  Stream<List<Map<String, dynamic>>> getScheduleOverridesStream(String date) {
    return _database
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
    await _database
        .collection('schedule_overrides')
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> removeScheduleOverride(String date, String classId) async {
    final String docId = '${date}_$classId';
    await _database.collection('schedule_overrides').doc(docId).delete();
  }

  // --- BOOKINGS ---
  Stream<List<Map<String, dynamic>>> getBookingsStream(
    String date,
    String classId,
  ) {
    return _database
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
    return _database
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
    final DocumentReference<Map<String, dynamic>> docRef = _database
        .collection('bookings')
        .doc(docId);

    return _database.runTransaction((Transaction transaction) async {
      final QuerySnapshot<Map<String, dynamic>> currentBookings =
          await _database
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
    await _database.collection('bookings').doc(docId).delete();
  }

  // --- REGISTRATIONS ---
  Future<void> submitRegistration(Map<String, dynamic> data) async {
    data['status'] = 'pending';
    data['timestamp'] = FieldValue.serverTimestamp();
    await _database.collection('registrations').add(data);
  }

  Stream<List<Map<String, dynamic>>> getPendingRegistrationsStream() {
    return _database
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
    await _database.collection('registrations').doc(regId).update(
      <String, dynamic>{
        'status': status,
      },
    );
  }
}
