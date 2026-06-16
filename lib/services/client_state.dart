import 'dart:async';

import 'package:dancefirst/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signals/signals_flutter.dart';

class ClientState {
  ClientState._internal();
  static final ClientState instance = ClientState._internal();

  // Signals
  final Signal<User?> sUser = signal<User?>(
    null,
    options: const SignalOptions<User?>(name: 'sUser'),
  );
  final Signal<String> sRole = signal<String>(
    'client',
    options: const SignalOptions<String>(name: 'sRole'),
  );
  final Signal<List<Map<String, dynamic>>> sProfiles =
      signal<List<Map<String, dynamic>>>(
    const <Map<String, dynamic>>[],
    options: const SignalOptions<List<Map<String, dynamic>>>(name: 'sProfiles'),
  );
  final Signal<String?> sActiveProfileId = signal<String?>(
    null,
    options: const SignalOptions<String?>(name: 'sActiveProfileId'),
  );

  StreamSubscription<List<Map<String, dynamic>>>? _profilesSubscription;

  // Computed signal for the active profile
  late final Computed<Map<String, dynamic>?> cActiveProfile = computed(() {
    final String? id = sActiveProfileId.value;
    if (id == null) return null;
    final List<Map<String, dynamic>> list = sProfiles.value;
    return list.firstWhere(
      (Map<String, dynamic> p) => p['id'] == id,
      orElse: () => <String, dynamic>{},
    );
  });

  // Check if initialization is complete
  final Signal<bool> sIsLoaded = signal<bool>(
    false,
    options: const SignalOptions<bool>(name: 'sIsLoaded'),
  );

  Future<void> initialize(User firebaseUser) async {
    sIsLoaded.value = false;
    sUser.value = firebaseUser;

    // Fetch user role
    final String roleStr = await FirestoreService().getUserRole();
    sRole.value = roleStr;

    // Subscribe to profiles and wait for initial snapshot
    unawaited(_profilesSubscription?.cancel());
    final Completer<void> completer = Completer<void>();
    _profilesSubscription = FirestoreService()
        .getProfilesStream(firebaseUser.uid)
        .listen(
      (List<Map<String, dynamic>> profs) {
        sProfiles.value = profs;

        // Auto-select first profile if sActiveProfileId is null or invalid
        final String? currentActiveId = sActiveProfileId.value;
        final bool isInvalidOrNull = currentActiveId == null ||
            !profs.any((Map<String, dynamic> p) => p['id'] == currentActiveId);

        if (isInvalidOrNull) {
          if (profs.isNotEmpty) {
            sActiveProfileId.value = profs.first['id'] as String?;
          } else {
            sActiveProfileId.value = null;
          }
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    try {
      await completer.future;
    } on Exception catch (_) {
      // Catch Firestore stream subscription errors gracefully
    } finally {
      sIsLoaded.value = true;
    }
  }

  void clear() {
    unawaited(_profilesSubscription?.cancel());
    _profilesSubscription = null;
    sUser.value = null;
    sRole.value = 'client';
    sProfiles.value = const <Map<String, dynamic>>[];
    sActiveProfileId.value = null;
    sIsLoaded.value = false;
  }
}
