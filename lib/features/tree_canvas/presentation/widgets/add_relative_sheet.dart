import 'package:flutter/material.dart';
import '../../../../data/models/enums.dart';

class AddRelativeSheet extends StatefulWidget {
  final String relationType;
  final Function({
    required String firstName,
    String? lastName,
    required Gender gender,
    DateTime? birthDate,
  }) onAdd;

  const AddRelativeSheet({
    super.key,
    required this.relationType,
    required this.onAdd,
  });

  static void show(
    BuildContext context,
    String relationType,
    Function({
      required String firstName,
      String? lastName,
      required Gender gender,
      DateTime? birthDate,
    }) onAdd,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddRelativeSheet(relationType: relationType, onAdd: onAdd),
    );
  }

  @override
  State<AddRelativeSheet> createState() => _AddRelativeSheetState();
}

class _AddRelativeSheetState extends State<AddRelativeSheet> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthYearController = TextEditingController();
  late Gender _gender;

  @override
  void initState() {
    super.initState();
    // По умолчанию разумный пол в зависимости от типа
    _gender = widget.relationType == 'spouse' ? Gender.female : Gender.male;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.relationType) {
      case 'parent':
        return 'Добавить предка (отца/мать)';
      case 'child':
        return 'Добавить потомка (сына/дочь)';
      case 'spouse':
        return 'Добавить супруга / супругу';
      case 'self':
      default:
        return 'Основатель древа';
    }
  }

  String get _subtitle {
    switch (widget.relationType) {
      case 'parent':
        return 'Ветвь потянется вниз — к корням древа рода';
      case 'child':
        return 'Ветвь потянется вверх — в пышную крону древа';
      case 'spouse':
        return 'Боковая ветвь семейного союза на этом же ярусе';
      case 'self':
      default:
        return 'Центральный узел, от которого разрастается всё древо';
    }
  }

  void _submit() {
    final first = _firstNameController.text.trim();
    if (first.isEmpty) return;

    final last = _lastNameController.text.trim();
    final yearStr = _birthYearController.text.trim();
    DateTime? bDate;
    if (yearStr.isNotEmpty) {
      final y = int.tryParse(yearStr);
      if (y != null && y > 0 && y <= DateTime.now().year + 1) {
        bDate = DateTime(y, 1, 1);
      }
    }

    widget.onAdd(
      firstName: first,
      lastName: last.isNotEmpty ? last : null,
      gender: _gender,
      birthDate: bDate,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const goldPrimary = Color(0xFFD4AF37);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Имя *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Фамилия',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _birthYearController,
              decoration: const InputDecoration(
                labelText: 'Год рождения (например 1985)',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            SegmentedButton<Gender>(
              segments: const [
                ButtonSegment(
                  value: Gender.male,
                  label: Text('Мужской'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment(
                  value: Gender.female,
                  label: Text('Женский'),
                  icon: Icon(Icons.female),
                ),
              ],
              selected: {_gender},
              onSelectionChanged: (set) => setState(() => _gender = set.first),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4A3E),
                foregroundColor: const Color(0xFFF9F8F6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: goldPrimary, width: 1),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nature_people_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Привить к древу',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
