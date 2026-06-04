import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureDataCard extends StatefulWidget {
  const SignatureDataCard({
    required this.signatureController,
    this.existingSignatureBase64,
    super.key,
  });

  final SignatureController signatureController;
  final String? existingSignatureBase64;

  @override
  State<SignatureDataCard> createState() => _SignatureDataCardState();
}

class _SignatureDataCardState extends State<SignatureDataCard> {
  bool _showPad = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingSignatureBase64 != null &&
        widget.existingSignatureBase64!.isNotEmpty) {
      _showPad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                Icon(
                  Icons.border_color_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '5. Handtekening',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (!_showPad) ...<Widget>[
              const Text(
                'Bestaande handtekening:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(widget.existingSignatureBase64!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showPad = true;
                  });
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Handtekening opnieuw zetten'),
              ),
            ] else ...<Widget>[
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
                    controller: widget.signatureController,
                    backgroundColor: Colors.grey.shade100,
                    height: 150,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (widget.existingSignatureBase64 != null &&
                      widget.existingSignatureBase64!.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPad = false;
                        });
                      },
                      icon: const Icon(Icons.undo),
                      label: const Text('Annuleren'),
                    )
                  else
                    const SizedBox.shrink(),
                  TextButton.icon(
                    onPressed: widget.signatureController.clear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Wissen'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
