import 'package:dancefirst/services/firestore_service.dart';
import 'package:flutter/material.dart';

class OverrideClassModal extends StatefulWidget {
  const OverrideClassModal({
    required this.dateStr,
    required this.classData,
    this.currentOverride,
    super.key,
  });

  final String dateStr;
  final Map<String, dynamic> classData;
  final Map<String, dynamic>? currentOverride;

  @override
  State<OverrideClassModal> createState() => _OverrideClassModalState();
}

class _OverrideClassModalState extends State<OverrideClassModal> {
  final FirestoreService _firestore = FirestoreService();
  late TextEditingController _teacherC;
  late TextEditingController _timeC;
  late TextEditingController _notesC;
  late bool _isCancelled;

  @override
  void initState() {
    super.initState();
    _teacherC = TextEditingController(
      text:
          widget.currentOverride?['teacherOverride'] as String? ??
          widget.classData['teacher'] as String,
    );
    _timeC = TextEditingController(
      text:
          widget.currentOverride?['timeOverride'] as String? ??
          widget.classData['time'] as String,
    );
    _notesC = TextEditingController(
      text: widget.currentOverride?['notes'] as String? ?? '',
    );
    _isCancelled = widget.currentOverride?['isCancelled'] as bool? ?? false;
  }

  @override
  void dispose() {
    _teacherC.dispose();
    _timeC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Ad-hoc Wijziging',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SwitchListTile(
            title: const Text('Geannuleerd?'),
            value: _isCancelled,
            onChanged: (bool val) {
              setState(() => _isCancelled = val);
            },
          ),
          if (!_isCancelled) ...<Widget>[
            TextFormField(
              controller: _teacherC,
              decoration: const InputDecoration(labelText: 'Docent Vervanger'),
            ),
            TextFormField(
              controller: _timeC,
              decoration: const InputDecoration(labelText: 'Tijd Aanpassing'),
            ),
          ],
          TextFormField(
            controller: _notesC,
            decoration: const InputDecoration(labelText: 'Opmerkingen'),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _firestore.removeScheduleOverride(
                      widget.dateStr,
                      widget.classData['id'] as String,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Herstel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await _firestore.saveScheduleOverride(
                      date: widget.dateStr,
                      classId: widget.classData['id'] as String,
                      isCancelled: _isCancelled,
                      teacherOverride: _isCancelled
                          ? null
                          : _teacherC.text.trim(),
                      timeOverride: _isCancelled ? null : _timeC.text.trim(),
                      notes: _notesC.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Opslaan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
