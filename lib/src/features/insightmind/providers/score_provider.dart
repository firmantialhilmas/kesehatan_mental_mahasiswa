// lib/src/features/insightmind/providers/score_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/calculate_risk_level.dart';
import '../data/repositories/score_repository.dart';
import 'questionnaire_provider.dart';

/// Simpan jawaban kuisioner di memori (sementara).
final answersProvider = StateProvider<List<int>>((ref) => []);

/// Repository sederhana untuk hitung skor total.
final scoreRepositoryProvider = Provider<ScoreRepository>((ref) => ScoreRepository());

/// Use case untuk konversi skor → level risiko.
final calculateRiskProvider = Provider<CalculateRiskLevel>((ref) => CalculateRiskLevel());

/// Hasil skoring mentah dari questionnaire (sesuai kode asli kamu).
final scoreProvider = Provider<int>((ref) {
  final questionnaire = ref.watch(questionnaireProvider);
  return questionnaire.totalScore;
});

/// Entity hasil final
class MentalResult {
  final int score;
  final String riskLevel;
  final String recommendation;

  const MentalResult({
    required this.score,
    required this.riskLevel,
    required this.recommendation,
  });
}

/// Hasil akhir (skor + level risiko + rekomendasi)
final resultProvider = Provider<MentalResult>((ref) {
  final score = ref.watch(scoreProvider);
  final riskUseCase = ref.watch(calculateRiskProvider);

  final riskLevel = riskUseCase.execute(score);

  String recommendation;
  if (score >= 24) {
    recommendation = 'Segera konsultasikan kondisi Anda dengan profesional kesehatan mental.';
  } else if (score >= 12) {
    recommendation = 'Kelola stres dengan baik, perbaiki pola hidup, dan pertimbangkan konsultasi ke psikolog.';
  } else {
    recommendation = 'Kondisi Anda tergolong baik. Pertahankan kebiasaan positif dan jaga kesehatan mental.';
  }

  return MentalResult(
    score: score,
    riskLevel: riskLevel,
    recommendation: recommendation,
  );
});