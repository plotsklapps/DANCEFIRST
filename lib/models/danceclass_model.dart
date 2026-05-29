class DanceClass {
  DanceClass({
    required this.time,
    required this.name,
    required this.teacher,
  });
  final String time;
  final String name;
  final String teacher;
}

final Map<String, List<DanceClass>> dkRooster = <String, List<DanceClass>>{
  'Maandag': <DanceClass>[
    DanceClass(time: '16:00', name: 'Streetdance 7-9 jaar', teacher: 'Laila'),
    DanceClass(time: '17:00', name: 'Streetdance 10-13 jaar', teacher: 'Laila'),
    DanceClass(time: '18:00', name: 'Streetdance 14-16 jaar', teacher: 'Laila'),
  ],
  'Dinsdag': <DanceClass>[
    DanceClass(time: '16:00', name: 'The Remix', teacher: 'Laila'),
    DanceClass(time: '17:00', name: 'Demoteam', teacher: 'Laila'),
    DanceClass(time: '18:00', name: 'The Originals', teacher: 'Laila'),
  ],
  'Woensdag': <DanceClass>[
    DanceClass(time: '15:00', name: 'Streetdance 10-13 jaar', teacher: 'Laila'),
    DanceClass(time: '16:00', name: 'Streetdance 7-9 jaar', teacher: 'Laila'),
    DanceClass(time: '17:00', name: 'Streetdance 10-13 jaar', teacher: 'Laila'),
    DanceClass(
      time: '18:00',
      name: 'Streetdance 13-16 jaar',
      teacher: 'Vlinder',
    ),
    DanceClass(time: '19:00', name: 'Hiphop 14+ jaar', teacher: 'Vlinder'),
  ],
  'Donderdag': <DanceClass>[
    DanceClass(time: '16:00', name: 'K-pop 7-9 jaar', teacher: 'Laila'),
    DanceClass(
      time: '17:00',
      name: 'Musicalles vanaf 7 jaar',
      teacher: 'Laila',
    ),
    DanceClass(time: '17:00', name: 'K-pop 10-13 jaar', teacher: 'Shay-Ann'),
    DanceClass(time: '18:00', name: 'K-pop 14+ jaar', teacher: 'Shay-Ann'),
  ],
  'Vrijdag': <DanceClass>[
    DanceClass(time: '16:30', name: 'Streetdance 7-9 jaar', teacher: 'Evy'),
    DanceClass(time: '17:30', name: 'Streetdance 10-13 jaar', teacher: 'Sanne'),
    DanceClass(time: '18:30', name: 'Streetdance 14-16 jaar', teacher: 'Sanne'),
  ],
  'Zaterdag': <DanceClass>[
    DanceClass(time: '10:30', name: 'Streetdance 7-9 jaar', teacher: 'Evy'),
    DanceClass(time: '11:30', name: 'Streetdance 10-13 jaar', teacher: 'Evy'),
  ],
};
