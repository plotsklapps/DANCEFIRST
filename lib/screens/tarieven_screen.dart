import 'package:flutter/material.dart';

class TarievenScreen extends StatelessWidget {
  const TarievenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          const SectionTitle(title: 'Kids lessen (4-18 jaar)'),
          const TariffCard(
            items: <Map<String, String>>[
              <String, String>{
                'label': 'Proefles naar keuze',
                'price': 'GRATIS',
              },
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
            ],
            footer:
                'Onbeperkt = incl. Musical, Hip-Hop, Modern '
                'en K-Pop!',
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Dans & Sport lessen (18+)'),
          const TariffCard(
            items: <Map<String, String>>[
              <String, String>{
                'label': 'Proefles naar keuze',
                'price': 'GRATIS',
              },
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
            ],
            footer: 'Onbeperkt = incl. Streetdance, Modern en Musical.',
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Inschrijven'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  const Text(
                    'De eerste keer inschrijven is bij ons altijd gratis! '
                    'Kom je voor een tweede keer terug? Dan hanteren wij eenmalig €25,- inschrijfkosten.\n\n'
                    'Heb je al een gratis proefles gehad? Dan heb je een inschrijfformulier ontvangen. '
                    'Lever deze gerust in tijdens je volgende les, of schrijf je direct online in.',
                    style: TextStyle(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      // Nog te implementeren
                    },
                    child: const Text('Direct inschrijven'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Betalen'),
          const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'DanceFirst werkt uitsluitend via automatische incasso, '
                'die rond de 1e van de maand plaatsvindt.\n\n'
                'Je abonnement start formeel op de 1e van de eerstvolgende '
                'maand. Begin je bijvoorbeeld op 8 oktober? Dan betaal je'
                ' naar rato voor de resterende weken in oktober, en gaat '
                'je abonnement officieel op 1 november in.',
                style: TextStyle(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Opzeggen of wijzigen'),
          const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '- Maand abonnementen zijn maandelijks opzegbaar.\n'
                '- 6 Maanden & Jaar abonnementen zijn na de contractperiode '
                'opzegbaar.\n'
                '- Je kunt je abonnement ten alle tijden ophogen, niet '
                'verlagen.\n\n'
                'Geen stilzwijgende verlenging: Na afloop van je '
                'contractperiode wordt je abonnement automatisch omgezet naar het flexibele maandtarief. Dit is maandelijks opzegbaar, maar voordeliger is het om tijdig je contract te verlengen voor een nieuwe termijn!\n\n'
                'Houd zelf je einddatum in de gaten en stuur op tijd een '
                'wijziging of verlenging door.\n\n'
                'Opzeggingen of wijzigingen doorgeven? Vóór de 14e van de '
                'maand per email naar dancefirstalkmaar@gmail.com',
                style: TextStyle(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Pauzeren'),
          const Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Volwassen klanten van DanceFirst kunnen hun abonnement voor 1 '
                'maand laten pauzeren.\n\n'
                'Pauze doorgeven? Vóór de 14e van de maand per email naar dancefirstalkmaar@gmail.com',
                style: TextStyle(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    super.key,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class TariffCard extends StatelessWidget {
  const TariffCard({
    required this.items,
    required this.footer,
    super.key,
  });
  final List<Map<String, String>> items;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            ...items.map(
              (Map<String, String> item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(item['label']!),
                    Text(
                      item['price']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Text(footer, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
