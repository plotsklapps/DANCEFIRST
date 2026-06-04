import 'dart:convert';

import 'package:dancefirst/screens/registration/addressdata_card.dart';
import 'package:dancefirst/screens/registration/paymentdata_card.dart';
import 'package:dancefirst/screens/registration/personaldata_card.dart';
import 'package:dancefirst/screens/registration/signaturedata_card.dart';
import 'package:dancefirst/screens/registration/subscriptiondata_card.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/scroll_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:signature/signature.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    this.profileData,
    super.key,
  });

  final Map<String, dynamic>? profileData;

  @override
  State<RegistrationScreen> createState() {
    return _RegistrationScreenState();
  }
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final Logger _logger = Logger();

  // Controllers.
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
    penColor: Colors.cyan.shade900,
  );

  // States.
  String _enrollmentType = 'DanceKids';
  String? _selectedSubscriptionId;
  String _selectedCountryCode = '+31';
  bool _mandateAccepted = false;
  bool _isSubmitting = false;
  bool _isEdit = false;
  String? _existingSignatureBase64;

  final List<Map<String, String>> _countryCodes = const <Map<String, String>>[
    <String, String>{'code': '+31', 'name': 'NL (+31)'},
    <String, String>{'code': '+32', 'name': 'BE (+32)'},
    <String, String>{'code': '+49', 'name': 'DE (+49)'},
    <String, String>{'code': '+44', 'name': 'GB (+44)'},
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.profileData != null;

    if (_isEdit) {
      final Map<String, dynamic> p = widget.profileData!;
      _firstNameController.text = p['firstName'] as String? ?? '';
      _lastNameController.text = p['lastName'] as String? ?? '';
      _dobController.text = p['dob'] as String? ?? '';
      _addressController.text = p['address'] as String? ?? '';
      _zipController.text = p['postalCode'] as String? ?? '';
      _cityController.text = p['city'] as String? ?? '';
      _ibanController.text = p['iban'] as String? ?? '';
      _accountHolderController.text = p['accountHolder'] as String? ?? '';
      _mandateAccepted = p['mandateAccepted'] as bool? ?? false;
      _enrollmentType = p['type'] as String? ?? 'DanceKids';
      _selectedSubscriptionId = p['selectedSubscriptionId'] as String?;
      _existingSignatureBase64 = p['signaturePng'] as String?;

      // Parse phone number to extract country code if possible.
      final String fullPhone = p['phone'] as String? ?? '';
      if (fullPhone.isNotEmpty) {
        bool parsed = false;
        for (final Map<String, String> c in _countryCodes) {
          final String prefix = c['code']!;
          if (fullPhone.startsWith(prefix)) {
            _selectedCountryCode = prefix;
            _phoneController.text = fullPhone.substring(prefix.length).trim();
            parsed = true;
            break;
          }
        }
        if (!parsed) {
          _phoneController.text = fullPhone;
        }
      }
    }
  }

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
      // Show toast to user.
      ToastService.showError(
        title: 'Formulier incompleet',
        subtitle: 'Controleer of alle verplichte velden correct zijn ingevuld.',
      );
      return;
    }

    // signature is mandatory if there is no prefilled signature,
    // OR if they opened the drawing pad and wiped/altered it.
    final bool hasNoExistingSignature =
        _existingSignatureBase64 == null || _existingSignatureBase64!.isEmpty;
    if (hasNoExistingSignature && _signatureController.isEmpty) {
      // Show toast to user.
      ToastService.showError(
        title: 'Handtekening verplicht',
        subtitle:
            'Zet je handtekening om de automatische incasso te bevestigen.',
      );
      return;
    }

    if (!_mandateAccepted) {
      // Show toast to user.
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
        // Show toast to user.
        ToastService.showError(
          title: 'Geen Actieve Gebruiker',
          subtitle: 'Log uit en probeer opnieuw.',
        );

        // Log error.
        _logger.e('Gebruikersfout. CurrentUser == null');

        throw Exception('Geen actieve gebruiker gevonden. Log opnieuw in.');
      }

      String finalSignatureBase64 = _existingSignatureBase64 ?? '';
      // If signature is drawn or modified, capture it.
      if (_signatureController.isNotEmpty) {
        final Uint8List? signatureBytes = await _signatureController
            .toPngBytes();
        if (signatureBytes != null) {
          finalSignatureBase64 = base64Encode(signatureBytes);
        }
      }

      final String fullPhoneNumber =
          '$_selectedCountryCode ${_phoneController.text.trim()}';

      await _firestoreService.saveProfile(
        currentUser.uid,
        profileId: widget.profileData?['id'] as String?,
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
        signaturePng: finalSignatureBase64,
      );

      ToastService.showSuccess(
        title: _isEdit ? 'Profiel bijgewerkt' : 'Inschrijving succesvol',
        subtitle: _isEdit
            ? 'Je profiel is succesvol bijgewerkt!'
            : 'Je profiel is succesvol aangemaakt!',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Profiel Bewerken' : 'Direct Inschrijven'),
      ),
      body: ScrollService(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                PersonalDataCard(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  dobController: _dobController,
                  phoneController: _phoneController,
                  selectedCountryCode: _selectedCountryCode,
                  countryCodes: _countryCodes,
                  onCountryCodeChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountryCode = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                AddressDataCard(
                  addressController: _addressController,
                  zipController: _zipController,
                  cityController: _cityController,
                ),
                const SizedBox(height: 16),
                SubscriptionDataCard(
                  enrollmentType: _enrollmentType,
                  selectedSubscriptionId: _selectedSubscriptionId,
                  onEnrollmentTypeChanged: (String value) {
                    setState(() {
                      _enrollmentType = value;
                      _selectedSubscriptionId = null; // Reset selection
                    });
                  },
                  onSubscriptionChanged: (String? value) {
                    setState(() {
                      _selectedSubscriptionId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                PaymentDataCard(
                  ibanController: _ibanController,
                  accountHolderController: _accountHolderController,
                  mandateAccepted: _mandateAccepted,
                  onMandateChanged: (bool val) {
                    setState(() {
                      _mandateAccepted = val;
                    });
                  },
                  isValidIban: _isValidIban,
                ),
                const SizedBox(height: 16),
                SignatureDataCard(
                  signatureController: _signatureController,
                  existingSignatureBase64: _existingSignatureBase64,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: _isSubmitting ? null : _submitRegistration,
                  child: _isSubmitting
                      ? const LinearProgressIndicator()
                      : Text(
                          _isEdit
                              ? 'Profiel Opslaan'
                              : 'Inschrijving Bevestigen',
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
}
