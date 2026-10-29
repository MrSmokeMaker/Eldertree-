import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interview_controller.dart';
import '../../../data/models/member_model.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  final MemberModel member;
  const InterviewScreen({super.key, required this.member});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _textController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitAnswer(WidgetRef ref) {
    if (_textController.text.trim().isEmpty) return;
    ref
        .read(interviewControllerProvider(widget.member.id).notifier)
        .saveAnswer(_textController.text, _selectedDate);
    _textController.clear();
    setState(() => _selectedDate = null);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(interviewControllerProvider(widget.member.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        title: Text('Interview: ${widget.member.firstName}',
            style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (state) {
          final question = state.currentQuestion;
          if (question == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text('Интервью завершено!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Вернуться в профиль'))
                ],
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      question.text,
                      key: ValueKey(question.id),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Ваш ответ...',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2A2D35)
                            : const Color(0xFFF0F0F0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ActionChip(
                        label: Text(_selectedDate != null
                            ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                            : 'Указать дату события'),
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        onPressed: _pickDate,
                        backgroundColor: _selectedDate != null
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2)
                            : null,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: state.isSaving
                            ? null
                            : () {
                                _textController.clear();
                                ref
                                    .read(interviewControllerProvider(
                                            widget.member.id)
                                        .notifier)
                                    .skipQuestion();
                              },
                        child: const Text('Пропустить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.isSaving ? null : () => _submitAnswer(ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Сохранить и продолжить',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
