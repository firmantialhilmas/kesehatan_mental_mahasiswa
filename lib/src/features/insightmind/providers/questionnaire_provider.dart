// lib/src/features/insightmind/providers/questionnaire_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/question.dart';
import 'user_provider.dart';

class QuestionnaireState {
  final Map<String, int> answers;
  final List<Question> activeQuestions;

  const QuestionnaireState({
    this.answers = const {},
    this.activeQuestions = const [],
  });

  QuestionnaireState copyWith({
    Map<String, int>? answers,
    List<Question>? activeQuestions,
  }) {
    return QuestionnaireState(
      answers: answers ?? this.answers,
      activeQuestions: activeQuestions ?? this.activeQuestions,
    );
  }

  bool get isComplete => answers.length >= activeQuestions.length;
  int get totalScore => answers.values.fold(0, (a, b) => a + b);

  String getAnswerLabel(String questionId) {
    final score = answers[questionId];
    if (score == null) return 'Belum dijawab';
    final question = activeQuestions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => questionsAge21_23.first,
    );
    final option = question.options.firstWhere((opt) => opt.score == score);
    return option.label;
  }
}

class QuestionnaireNotifier extends StateNotifier<QuestionnaireState> {
  QuestionnaireNotifier() : super(const QuestionnaireState());

  void selectAnswer({required String questionId, required int score}) {
    final newMap = Map<String, int>.from(state.answers);
    newMap[questionId] = score;
    state = state.copyWith(answers: newMap);
  }

  void loadQuestionsByAge(int userAge) {
    final filtered = getQuestionsByAge(userAge);
    state = state.copyWith(
      activeQuestions: filtered,
      answers: {},
    );
  }

  void resetAnswers() {
    state = state.copyWith(
      answers: {},
      activeQuestions: state.activeQuestions,
    );
  }
}

final questionsProvider = Provider.family<List<Question>, int>((ref, userAge) {
  return getQuestionsByAge(userAge);
});

final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
  return QuestionnaireNotifier();
});

List<Question> getQuestionsByAge(int age) {
  if (age >= 17 && age <= 20) return questionsAge17_20;
  if (age >= 21 && age <= 23) return questionsAge21_23;
  if (age >= 24 && age <= 27) return questionsAge24_27;
  return questionsAge21_23;
}