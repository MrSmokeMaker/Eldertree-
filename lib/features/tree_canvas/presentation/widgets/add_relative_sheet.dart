import 'package:flutter/material.dart';
import '../../../../data/models/enums.dart';

class AddRelativeSheet extends StatefulWidget {
  final String relationType;
  final Function(String name, Gender gender) onAdd;

  const AddRelativeSheet({super.key, required this.relationType, required this.onAdd});

  static void show(BuildContext context, String relationType, Function(String, Gender) onAdd) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AddRelativeSheet(relationType: relationType, onAdd: onAdd),
    );
  }

  @override
  State<AddRelativeSheet> createState() => _AddRelativeSheetState();
}

class _AddRelativeSheetState extends State<AddRelativeSheet> {
  final _nameController = TextEditingController();
  Gender _gender = Gender.female;

  @override
  Widget build(BuildContext context) {
    String title = 'Add Relative';
    if (widget.relationType == 'parent') title = 'Add Parent';
    if (widget.relationType == 'child') title = 'Add Child';
    if (widget.relationType == 'spouse') title = 'Add Spouse';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          SegmentedButton<Gender>(
            segments: const [
              ButtonSegment(value: Gender.female, label: Text('Female')),
              ButtonSegment(value: Gender.male, label: Text('Male')),
            ],
            selected: {_gender},
            onSelectionChanged: (set) => setState(() => _gender = set.first),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                widget.onAdd(_nameController.text.trim(), _gender);
                Navigator.pop(context);
              }
            },
            child: const Text('Add to Tree'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
