import 'package:dancefirst/models/danceclass_model.dart';
import 'package:dancefirst/models/sportsclass_model.dart';
import 'package:flutter/material.dart';

enum DanceGroup { kids, adults }

class RoosterScreen extends StatefulWidget {
  const RoosterScreen({super.key});

  @override
  State<RoosterScreen> createState() {
    return _RoosterScreenState();
  }
}

class _RoosterScreenState extends State<RoosterScreen> {
  DanceGroup selectedDanceGroup = DanceGroup.kids;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> activeRooster =
        selectedDanceGroup == DanceGroup.kids ? dkRooster : dfRooster;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SegmentedButton<DanceGroup>(
                  segments: const <ButtonSegment<DanceGroup>>[
                    ButtonSegment<DanceGroup>(
                      value: DanceGroup.kids,
                      label: Text('Kids'),
                    ),
                    ButtonSegment<DanceGroup>(
                      value: DanceGroup.adults,
                      label: Text('18+'),
                    ),
                  ],
                  selected: <DanceGroup>{selectedDanceGroup},
                  onSelectionChanged: (Set<DanceGroup> newSelection) {
                    setState(() {
                      selectedDanceGroup = newSelection.first;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: activeRooster.keys.length,
              itemBuilder: (BuildContext context, int index) {
                final String day = activeRooster.keys.elementAt(index);
                final List<dynamic> classes = activeRooster[day]!;

                if (classes.isEmpty) return const SizedBox.shrink();

                return ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: classes.map((dynamic item) {
                    final String time = (item as dynamic).time.toString();
                    final String name = (item as dynamic).name.toString();
                    final String teacher = (item as dynamic).teacher.toString();
                    return ListTile(
                      leading: Text(time),
                      title: Text(name),
                      subtitle: Text('Docent: $teacher'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
