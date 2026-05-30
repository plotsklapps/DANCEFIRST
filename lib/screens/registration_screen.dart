import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() {
    return _RegistrationScreenState();
  }
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final List<GlobalKey<FormState>> _formKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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

  int _currentStep = 0;

  String _enrollmentType = 'child';
  String? _selectedTariff;

  final List<Map<String, String>> _kidsTariffs = <Map<String, String>>[
    <String, String>{
      'label': '1x per week, maandelijks opzegbaar',
      'price': '€45,00',
    },
    <String, String>{
      'label': '1x per week, halfjaar abonnement',
      'price': '€37,50',
    },
    <String, String>{
      'label': '1x per week, jaar abonnement',
      'price': '€30,00',
    },
    <String, String>{
      'label': '2x per week, maandelijks opzegbaar',
      'price': '€60,00',
    },
    <String, String>{
      'label': '2x per week, halfjaar abonnement',
      'price': '€52,50',
    },
    <String, String>{
      'label': '2x per week, jaar abonnement',
      'price': '€45,00',
    },
    <String, String>{
      'label': 'Onbeperkt, maandelijks opzegbaar',
      'price': '€75,00',
    },
    <String, String>{
      'label': 'Onbeperkt, halfjaar abonnement',
      'price': '€67,50',
    },
    <String, String>{
      'label': 'Onbeperkt, jaar abonnement',
      'price': '€60,00',
    },
  ];

  final List<Map<String, String>> _adultTariffs = <Map<String, String>>[
    <String, String>{
      'label': '1x per week, maandelijks opzegbaar',
      'price': '€45,00',
    },
    <String, String>{
      'label': '1x per week, 1 jaar abonnement',
      'price': '€37,50',
    },
    <String, String>{
      'label': '1x per week, 2 jaar abonnement',
      'price': '€30,00',
    },
    <String, String>{
      'label': '2x per week, maandelijks opzegbaar',
      'price': '€60,00',
    },
    <String, String>{
      'label': '2x per week, 1 jaar abonnement',
      'price': '€52,50',
    },
    <String, String>{
      'label': '2x per week, 2 jaar abonnement',
      'price': '€45,00',
    },
    <String, String>{
      'label': 'Onbeperkt, maandelijks opzegbaar',
      'price': '€65,00',
    },
    <String, String>{
      'label': 'Onbeperkt, 1 jaar abonnement',
      'price': '€57,50',
    },
    <String, String>{
      'label': 'Onbeperkt, 2 jaar abonnement',
      'price': '€50,00',
    },
  ];

  bool isValidIban(String input) {
    final String iban = input.replaceAll(' ', '').toUpperCase();

    if (iban.length < 15 || iban.length > 34) return false;

    // CountryCode + 2 digits + rest Letters/Numbers
    final RegExp regex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]+$');
    if (!regex.hasMatch(iban)) return false;

    // Move first 4 chars to back.
    final String rearranged = iban.substring(4) + iban.substring(0, 4);

    // Set Letters to Digits (A=10, B=11, ..., Z=35).
    final String numeric = rearranged.split('').map((String c) {
      final int code = c.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        return (code - 55).toString();
      }
      return c;
    }).join();

    // Mod-97 check.
    final BigInt big = BigInt.parse(numeric);
    return big % BigInt.from(97) == BigInt.one;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DanceFirst Inschrijving')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_formKeys[_currentStep].currentState!.validate()) {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else {
              // Final submit
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: details.onStepContinue,
                  child: const Text('Verder'),
                ),
                const SizedBox(width: 16),
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Terug'),
                  ),
              ],
            ),
          );
        },
        steps: <Step>[
          Step(
            title: const Text('Type'),
            content: Form(
              key: _formKeys[0],
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'child', label: Text('Kind')),
                  ButtonSegment<String>(
                    value: 'adult',
                    label: Text('Volwassene'),
                  ),
                ],
                selected: <String>{_enrollmentType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _enrollmentType = newSelection.first);
                },
              ),
            ),
          ),
          Step(
            title: const Text('Abonnement'),
            content: Form(
              key: _formKeys[1],
              child: Column(
                children: <Widget>[
                  ...(_enrollmentType == 'child' ? _kidsTariffs : _adultTariffs)
                      .map(
                        (Map<String, String> t) => RadioListTile<String>(
                          title: Text(t['label']!),
                          subtitle: Text(t['price']!),
                          value: t['label']!,
                          groupValue: _selectedTariff,
                          onChanged: (String? value) =>
                              setState(() => _selectedTariff = value),
                        ),
                      ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Gegevens'),
            content: Form(
              key: _formKeys[2],
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Voornaam'),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Achternaam'),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Geboortedatum (DD-MM-YYYY)',
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return '01-01-1990';
                      if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(v))
                        return 'Formaat DD-MM-YYYY';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return 'naam@email.com';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(v))
                        return 'Ongeldig e-mailadres';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefoon'),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return '0612345678';
                      final RegExp phoneRegex = RegExp(
                        r'^(\+31|0031|0)?6[0-9]{8}$|^(\+|00)[0-9]{7,15}$',
                      );
                      if (!phoneRegex.hasMatch(
                        v.replaceAll(RegExp(r'\s|-'), ''),
                      ))
                        return 'Ongeldig nummer';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Adres & Bank'),
            content: Form(
              key: _formKeys[3],
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Adres'),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return 'Adres + huisnummer';
                      final RegExp addressRegex = RegExp(
                        r'^[a-zA-Z\s\.]+\s?\d+[a-zA-Z]*$',
                      );
                      if (!addressRegex.hasMatch(v.trim()))
                        return 'Bijv. Bakkerstraat 105';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _zipController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Postcode'),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return '1234AB';
                      if (!RegExp(
                        r'^\d{4}\s?[a-zA-Z]{2}$',
                      ).hasMatch(v.trim().toUpperCase()))
                        return 'Bijv. 1234AB';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Woonplaats'),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Verplicht' : null,
                  ),
                  TextFormField(
                    controller: _ibanController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'IBAN'),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return 'NL01BANK0123456789';
                      if (!isValidIban(v.replaceAll(' ', '')))
                        return 'Ongeldig IBAN';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _accountHolderController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Naam rekeninghouder',
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) return 'A.B. Achternaam';
                      if (!RegExp(r'^[a-zA-Z\. \-]+$').hasMatch(v.trim()))
                        return 'Voer een geldige naam in';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Handtekening'),
            content: Form(
              key: _formKeys[4],
              child: Column(
                children: <Widget>[
                  FormField<bool>(
                    initialValue: false,
                    validator: (bool? value) =>
                        value == true ? null : 'Je moet akkoord gaan',
                    builder: (FormFieldState<bool> state) => Column(
                      children: <Widget>[
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: state.value,
                          title: const Text(
                            'Ik ga akkoord met automatische incasso',
                          ),
                          onChanged: (bool? value) => state.didChange(value),
                        ),
                        if (state.hasError)
                          Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Zet hieronder je handtekening:'),
                  Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.grey[200]!,
                    height: 200,
                  ),
                  TextButton(
                    onPressed: _signatureController.clear,
                    child: const Text('Wissen'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
