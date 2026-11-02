import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/supabase_providers.dart';
import 'domain/interview_question.dart';

part 'interview_controller.g.dart';

class InterviewState {
  final List<InterviewQuestion> pendingQuestions;
  final int currentIndex;
  final bool isSaving;

  InterviewState({
    required this.pendingQuestions,
    required this.currentIndex,
    this.isSaving = false,
  });

  InterviewQuestion? get currentQuestion =>
      pendingQuestions.isNotEmpty && currentIndex < pendingQuestions.length
          ? pendingQuestions[currentIndex]
          : null;

  double get progress =>
      pendingQuestions.isEmpty ? 1.0 : currentIndex / pendingQuestions.length;
}

@riverpod
class InterviewController extends _$InterviewController {
  @override
  FutureOr<InterviewState> build(String memberId) async {
    final client = ref.watch(supabaseProvider);
    final factsRes =
        await client.from('facts').select('category').eq('member_id', memberId);
    final existingCategories =
        factsRes.map((f) => f['category'] as String).toSet();

    final pending = defaultInterviewQuestions.where((q) {
      if (q.isMultipleAllowed) return true;
      return !existingCategories.contains(q.targetCategory.name);
    }).toList();

    return InterviewState(pendingQuestions: pending, currentIndex: 0);
  }

  Future<void> saveAnswer(String answerText, DateTime? factDate) async {
    if (state.value == null || answerText.trim().isEmpty) return;
    final currentState = state.value!;
    final question = currentState.currentQuestion;
    if (question == null) return;

    state = AsyncValue.data(InterviewState(
      pendingQuestions: currentState.pendingQuestions,
      currentIndex: currentState.currentIndex,
      isSaving: true,
    ));
    final client = ref.watch(supabaseProvider);

    try {
      await client.from('facts').insert({
        'member_id': memberId,
        'category': question.targetCategory.name,
        'value': answerText.trim(),
        'fact_date': factDate?.toIso8601String(),
      });
      state = AsyncValue.data(InterviewState(
        pendingQuestions: currentState.pendingQuestions,
        currentIndex: currentState.currentIndex + 1,
        isSaving: false,
      ));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void skipQuestion() {
    if (state.value == null) return;
    final currentState = state.value!;
    state = AsyncValue.data(InterviewState(
      pendingQuestions: currentState.pendingQuestions,
      currentIndex: currentState.currentIndex + 1,
    ));
  }
}
