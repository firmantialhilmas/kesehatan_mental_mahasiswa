// lib/src/features/insightmind/providers/questionnaire_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/question.dart';

/// State: map id pertanyaan -> skor (0..3)
class QuestionnaireState {
  final Map<String, int> answers;
  const QuestionnaireState({this.answers = const {}});

  QuestionnaireState copyWith({Map<String, int>? answers}) {
    return QuestionnaireState(answers: answers ?? this.answers);
  }

  bool get isComplete => answers.length >= defaultQuestions.length;

  int get totalScore => answers.values.fold(0, (a, b) => a + b);

  String getAnswerLabel(String questionId) {
    final score = answers[questionId];
    if (score == null) return 'Belum dijawab';
    final question = defaultQuestions.firstWhere((q) => q.id == questionId);
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

  /// Legacy reset kept for compatibility.
  void reset() {
    state = const QuestionnaireState();
  }

  /// Reset method intended for UI actions.
  void resetAnswers() {
    state = const QuestionnaireState();
  }
}

/// Provider daftar pertanyaan (konstan)
final questionsProvider = Provider<List<Question>>((ref) {
  return defaultQuestions;
});

/// Provider state form
final questionnaireProvider =
    StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
  return QuestionnaireNotifier();
});
