import 'dart:convert';

import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/scroll_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() {
    return _RegistrationScreenState();
  }
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penColor: Colors.teal.shade900,
  );

  // States
  String _enrollmentType = 'DanceKids'; // 'DanceKids' | 'DanceFirst'
  String? _selectedSubscriptionId;
  String _selectedCountryCode = '+31';
  bool _mandateAccepted = false;
  bool _isSubmitting = false;

  final List<Map<String, String>> _countryCodes = const <Map<String, String>>[
    <String, String>{'code': '+31', 'name': 'NL (+31)'},
    <String, String>{'code': '+32', 'name': 'BE (+32)'},
    <String, String>{'code': '+49', 'name': 'DE (+49)'},
    <String, String>{'code': '+44', 'name': 'GB (+44)'},
  ];

  bool _isValidIban(String input) {
    final String iban = input.replaceAll(' ', '').toUpperCase();
    if (iban.length < 15 || iban.length > 34) return false;

    final RegExp regex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]+$');
    if (!regex.hasMatch(iban)) return false;

    final String rearranged = iban.substring(4) + iban.substring(0, 4);
    final String numeric = rearranged.split('').map((String c) {
      final int code = c.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        return (code - 55).toString();
      }
      return c;
    }).join();

    try {
      final BigInt big = BigInt.parse(numeric);
      return big % BigInt.from(97) == BigInt.one;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      ToastService.showError(
        title: 'Formulier incompleet',
        subtitle: 'Controleer of alle verplichte velden correct zijn ingevuld.',
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ToastService.showError(
        title: 'Handtekening verplicht',
        subtitle:
            'Zet je handtekening om de automatische incasso te bevestigen.',
      );
      return;
    }

    if (!_mandateAccepted) {
      ToastService.showError(
        title: 'Machtiging verplicht',
        subtitle: 'Je moet akkoord gaan met de automatische incasso.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Geen actieve gebruiker gevonden. Log opnieuw in.');
      }

      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      String signatureBase64 = '';
      if (signatureBytes != null) {
        signatureBase64 = base64Encode(signatureBytes);
      }

      final String fullPhoneNumber =
          '$_selectedCountryCode ${_phoneController.text.trim()}';

      await _firestore.saveProfile(
        currentUser.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: fullPhoneNumber,
        dob: _dobController.text.trim(),
        type: _enrollmentType,
        address: _addressController.text.trim(),
        postalCode: _zipController.text.trim().toUpperCase(),
        city: _cityController.text.trim(),
        iban: _ibanController.text.trim().toUpperCase(),
        accountHolder: _accountHolderController.text.trim(),
        mandateAccepted: _mandateAccepted,
        selectedSubscriptionId: _selectedSubscriptionId!,
        signaturePng: signatureBase64,
      );

      ToastService.showSuccess(
        title: 'Inschrijving succesvol',
        subtitle: 'Je profiel is succesvol aangemaakt!',
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      ToastService.showError(
        title: 'Fout bij inschrijven',
        subtitle: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Inschrijven'),
      ),
      body: ScrollService(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // CARDS / SECTIONS
                _buildSectionCard(
                  title: '1. Persoonsgegevens',
                  icon: Icons.person_outline,
                  theme: theme,
                  children: <Widget>[
                    TextFormField(
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Voornaam *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (String? v) => (v == null || v.trim().isEmpty)
                          ? 'Voornaam is verplicht'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Achternaam *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (String? v) => (v == null || v.trim().isEmpty)
                          ? 'Achternaam is verplicht'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dobController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Geboortedatum * (DD-MM-YYYY)',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (String? v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Geboortedatum is verplicht';
                        }
                        if (!RegExp(
                          r'^\d{2}-\d{2}-\d{4}$',
                        ).hasMatch(v.trim())) {
                          return 'Formaat moet DD-MM-YYYY zijn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 110,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCountryCode,
                            decoration: const InputDecoration(
                              labelText: 'Land',
                            ),
                            items: _countryCodes
                                .map(
                                  (Map<String, String> c) =>
                                      DropdownMenuItem<String>(
                                        value: c['code'],
                                        child: Text(c['name']!),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCountryCode = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefoonnummer *',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Telefoonnummer is verplicht';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: '2. Adresgegevens',
                  icon: Icons.home_outlined,
                  theme: theme,
                  children: <Widget>[
                    TextFormField(
                      controller: _addressController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Straatnaam & Huisnummer *',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (String? v) => (v == null || v.trim().isEmpty)
                          ? 'Adres is verplicht'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _zipController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Postcode *',
                              hintText: '1234 AB',
                            ),
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Verplicht';
                              }
                              if (!RegExp(
                                r'^\d{4}\s?[a-zA-Z]{2}$',
                              ).hasMatch(v.trim())) {
                                return 'Formaat: 1234 AB';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _cityController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Woonplaats *',
                            ),
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                ? 'Verplicht'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: '3. Abonnement Keuze',
                  icon: Icons.card_membership_outlined,
                  theme: theme,
                  children: <Widget>[
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'DanceKids',
                          label: Text('Kids (4-18 jr)'),
                          icon: Icon(Icons.child_care),
                        ),
                        ButtonSegment<String>(
                          value: 'DanceFirst',
                          label: Text('Adults (18+)'),
                          icon: Icon(Icons.directions_run),
                        ),
                      ],
                      selected: <String>{_enrollmentType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _enrollmentType = newSelection.first;
                          _selectedSubscriptionId = null; // Reset selection
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestore.getSubscriptionsStream(),
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                          ) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text(
                                'Geen abonnementen beschikbaar.',
                              );
                            }

                            final List<Map<String, dynamic>> filtered = snapshot
                                .data!
                                .where(
                                  (Map<String, dynamic> s) =>
                                      s['category'] == _enrollmentType &&
                                      (s['isActive'] as bool? ?? true),
                                )
                                .toList();

                            if (filtered.isEmpty) {
                              return const Text(
                                'Geen actieve abonnementen gevonden.',
                              );
                            }

                            return DropdownButtonFormField<String>(
                              initialValue: _selectedSubscriptionId,
                              decoration: const InputDecoration(
                                labelText: 'Kies een abonnement *',
                                prefixIcon: Icon(Icons.check_circle_outline),
                              ),
                              items: filtered
                                  .map(
                                    (Map<String, dynamic> s) =>
                                        DropdownMenuItem<String>(
                                          value: s['id'] as String,
                                          child: Text(
                                            '${s['name']} (€${s['price']})',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedSubscriptionId = value;
                                });
                              },
                              validator: (String? v) =>
                                  v == null ? 'Selecteer een abonnement' : null,
                            );
                          },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: '4. Automatische Incasso (SEPA)',
                  icon: Icons.account_balance_outlined,
                  theme: theme,
                  children: <Widget>[
                    TextFormField(
                      controller: _ibanController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'IBAN Nummer *',
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                      validator: (String? v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'IBAN is verplicht';
                        }
                        if (!_isValidIban(v.trim())) {
                          return 'Ongeldig Europees IBAN formaat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accountHolderController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Naam Rekeninghouder *',
                        prefixIcon: Icon(Icons.person_pin_outlined),
                      ),
                      validator: (String? v) => (v == null || v.trim().isEmpty)
                          ? 'Naam rekeninghouder is verplicht'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(
                        'Ik geef DanceFirst toestemming voor automatische'
                        ' incasso rond de 1e van de maand *',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _mandateAccepted,
                      onChanged: (bool val) {
                        setState(() {
                          _mandateAccepted = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: '5. Handtekening',
                  icon: Icons.border_color_outlined,
                  theme: theme,
                  children: <Widget>[
                    const Text(
                      'Zet hieronder je handtekening op het scherm:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Signature(
                          controller: _signatureController,
                          backgroundColor: Colors.grey.shade100,
                          height: 150,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _signatureController.clear,
                        icon: const Icon(Icons.clear),
                        label: const Text('Wissen'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSubmitting ? null : _submitRegistration,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Inschrijving Bevestigen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}
