import 'package:dancefirst/screens/admin/admin_dashboard.dart';
import 'package:dancefirst/screens/registration/registration_screen.dart';
import 'package:dancefirst/services/client_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class DrawerWidget extends SignalWidget {
  const DrawerWidget({
    required this.user,
    required this.role,
    super.key,
  });

  final User? user;
  final String role;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Map<String, dynamic>> profiles =
        ClientState.instance.sProfiles.value;
    final String? activeProfileId = ClientState.instance.sActiveProfileId.value;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const Icon(Icons.person, size: 48, color: Colors.white),
                Text(
                  user?.email ?? 'Gebruiker',
                ),
                Text(
                  role == 'admin' ? 'Beheerder' : 'Geverifieerd',
                ),
              ],
            ),
          ),
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Admin Dashboard'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return const AdminDashboard();
                    },
                  ),
                );
              },
            ),

          // --- INSCHRIJVEN (Nieuwe Inschrijving) ---
          ListTile(
            leading: const Icon(Icons.add_reaction_outlined),
            title: const Text('Nieuwe Inschrijving'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) {
                    return const RegistrationScreen();
                  },
                ),
              );
            },
          ),

          // --- PROFIELEN LIST ---
          if (user != null && profiles.isNotEmpty) ...<Widget>[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                'Kies actief profiel:',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List<Widget>.generate(profiles.length, (
              int index,
            ) {
              final Map<String, dynamic> p = profiles[index];
              final String firstName = p['firstName'] as String? ?? 'Profiel';
              final String dob = p['dob'] as String? ?? '';
              final String type = p['type'] as String? ?? 'DanceKids';
              final bool isKids = type == 'DanceKids';
              final bool isSelected = p['id'] == activeProfileId;

              return ListTile(
                selected: isSelected,
                selectedTileColor: theme.colorScheme.primaryContainer
                    .withValues(alpha: 100),
                leading: Icon(
                  isKids ? Icons.child_care : Icons.sports_gymnastics_outlined,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  'Profiel ${index + 1} ($firstName)',
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: dob.isNotEmpty ? Text('Geb: $dob') : null,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                  tooltip: 'Profiel bewerken',
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) {
                          return RegistrationScreen(
                            profileData: p,
                          );
                        },
                      ),
                    );
                  },
                ),
                onTap: () {
                  ClientState.instance.sActiveProfileId.value =
                      p['id'] as String?;
                },
              );
            }),
            const Divider(),
          ],

          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: const Text('Uitloggen'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
