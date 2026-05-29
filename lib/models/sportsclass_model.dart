class SportsClass {
  SportsClass({
    required this.time,
    required this.name,
    required this.teacher,
  });
  final String time;
  final String name;
  final String teacher;
}

final Map<String, List<SportsClass>> dfRooster = <String, List<SportsClass>>{
  'Maandag': <SportsClass>[
    SportsClass(time: '09:15', name: 'Yin Yoga', teacher: 'Laila'),
    SportsClass(
      time: '10:15',
      name: 'Zumba Gold (Beginners)',
      teacher: 'Laila',
    ),
    SportsClass(time: '19:30', name: 'Zumba (Gevorderden)', teacher: 'Laila'),
    SportsClass(time: '20:30', name: 'Pilates Flow', teacher: 'Laila'),
  ],
  'Dinsdag': <SportsClass>[
    SportsClass(
      time: '19:00',
      name: 'Moderne Dans (Beginners)',
      teacher: 'Laila/Shay-Ann',
    ),
    SportsClass(time: '20:00', name: 'Streetdance 25+', teacher: 'Laila'),
  ],
  'Woensdag': <SportsClass>[
    SportsClass(time: '09:30', name: 'Zumba (Medium)', teacher: 'Laila'),
    SportsClass(time: '10:30', name: 'Circuittraining', teacher: 'Laila'),
  ],
  'Donderdag': <SportsClass>[
    SportsClass(
      time: '09:30',
      name: 'The Mix (Dance-Workout)',
      teacher: 'Laila',
    ),
    SportsClass(time: '19:10', name: 'Krachttraining', teacher: 'Laila'),
    SportsClass(time: '20:00', name: 'Step-up', teacher: 'Laila'),
  ],
  'Vrijdag': <SportsClass>[],
  'Zaterdag': <SportsClass>[
    SportsClass(time: '09:30', name: 'Zumba & Lift', teacher: 'Laila'),
  ],
  'Zondag': <SportsClass>[
    SportsClass(time: '10:00', name: 'Yoga & Pilates', teacher: 'Laila'),
  ],
};
