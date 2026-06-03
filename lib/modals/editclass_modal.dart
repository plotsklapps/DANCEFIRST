import 'package:dancefirst/modals/modal_title.dart';
import 'package:dancefirst/services/firestore_service.dart';
import 'package:dancefirst/services/toast_service.dart';
import 'package:flutter/material.dart';

class EditClassModal extends StatefulWidget {
  const EditClassModal({
    this.c,
    super.key,
  });

  final Map<String, dynamic>? c;

  @override
  State<EditClassModal> createState() {
    return _EditClassModalState();
  }
}

class _EditClassModalState extends State<EditClassModal> {
  final FirestoreService _firestore = FirestoreService();
  late TextEditingController _nameC;
  late TextEditingController _teacherC;
  late TextEditingController _timeC;
  late TextEditingController _maxC;
  late String _selectedDay;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(
      text: widget.c?['name'] as String? ?? '',
    );
    _teacherC = TextEditingController(
      text: widget.c?['teacher'] as String? ?? '',
    );
    _timeC = TextEditingController(
      text: widget.c?['time'] as String? ?? '',
    );
    _maxC = TextEditingController(
      text: (widget.c?['maxParticipants'] ?? 20).toString(),
    );
    _selectedDay = widget.c?['day'] as String? ?? 'Maandag';
    _selectedType = widget.c?['type'] as String? ?? 'kids';
  }

  @override
  void dispose() {
    _nameC.dispose();
    _teacherC.dispose();
    _timeC.dispose();
    _maxC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ModalTitle(title: widget.c == null ? 'Nieuwe Les' : 'Les Bewerken'),
        TextFormField(
          controller: _nameC,
          decoration: const InputDecoration(labelText: 'Lesnaam'),
        ),
        TextFormField(
          controller: _teacherC,
          decoration: const InputDecoration(labelText: 'Docent'),
        ),
        TextFormField(
          controller: _timeC,
          decoration: const InputDecoration(labelText: 'Tijd'),
        ),
        TextFormField(
          controller: _maxC,
          decoration: const InputDecoration(labelText: 'Max Deelnemers'),
        ),
        DropdownButtonFormField<String>(
          initialValue: _selectedDay,
          items:
              <String>[
                'Maandag',
                'Dinsdag',
                'Woensdag',
                'Donderdag',
                'Vrijdag',
                'Zaterdag',
                'Zondag',
              ].map(
                (String d) {
                  return DropdownMenuItem<String>(value: d, child: Text(d));
                },
              ).toList(),
          onChanged: (String? val) {
            setState(() {
              _selectedDay = val!;
            });
          },
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () async {
            await _firestore.saveBaseScheduleClass(
              id: widget.c?['id'] as String?,
              day: _selectedDay,
              time: _timeC.text.trim(),
              name: _nameC.text.trim(),
              teacher: _teacherC.text.trim(),
              type: _selectedType,
              maxParticipants: int.tryParse(_maxC.text) ?? 20,
            );
            ToastService.showSuccess(
              title: 'Les opgeslagen',
              subtitle: 'Les is bijgewerkt.',
            );
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
