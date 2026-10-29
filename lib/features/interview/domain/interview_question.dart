import '../../../data/models/enums.dart';

class InterviewQuestion {
  final String id;
  final String text;
  final FactCategory targetCategory;
  final bool isMultipleAllowed;
  final bool asksForDate;

  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.targetCategory,
    this.isMultipleAllowed = false,
    this.asksForDate = false,
  });
}

const List<InterviewQuestion> defaultInterviewQuestions = [
  InterviewQuestion(
    id: 'q_birth',
    text: 'Когда и где он/она родился(лась)?',
    targetCategory: FactCategory.birthplace,
    asksForDate: true,
  ),
  InterviewQuestion(
    id: 'q_childhood',
    text: 'Где он вырос и каким был ребёнком?',
    targetCategory: FactCategory.trait,
  ),
  InterviewQuestion(
    id: 'q_education_job',
    text: 'Где учился? Какая была первая работа?',
    targetCategory: FactCategory.occupation,
  ),
  InterviewQuestion(
    id: 'q_love',
    text: 'Как познакомился со своей второй половиной? Расскажите о свадьбе.',
    targetCategory: FactCategory.story,
    isMultipleAllowed: true,
    asksForDate: true,
  ),
  InterviewQuestion(
    id: 'q_phrase',
    text: 'Какая у него/неё была любимая фраза или присловье?',
    targetCategory: FactCategory.phrase,
  ),
  InterviewQuestion(
    id: 'q_memory',
    text: 'Каким моментом из его жизни вы дорожите больше всего?',
    targetCategory: FactCategory.story,
    isMultipleAllowed: true,
  ),
];
