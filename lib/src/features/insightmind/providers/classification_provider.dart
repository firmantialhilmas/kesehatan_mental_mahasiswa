// lib/src/features/insightmind/providers/classification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/naive_bayes_classifier.dart';
import '../domain/usecases/saw_classifier.dart';

// ── Naive Bayes ──────────────────────────────────────────────────────────────

final naiveBayesProvider = Provider<NaiveBayesClassifier>((ref) {
  return NaiveBayesClassifier();
});

final classificationResultProvider =
    Provider.family<ClassificationResult, List<int>>((ref, answers) {
  final classifier = ref.watch(naiveBayesProvider);
  return classifier.classify(answers);
});

// ── SAW (Simple Additive Weighting) ─────────────────────────────────────────

final sawClassifierProvider = Provider<SawClassifier>((ref) {
  return SawClassifier();
});

/// Menghitung dimensi stres, kecemasan, dan kualitas tidur
/// berdasarkan metode SAW, menghasilkan [SawResult].
final sawResultProvider = Provider.family<SawResult, List<int>>((ref, answers) {
  final classifier = ref.watch(sawClassifierProvider);
  return classifier.classify(answers);
});
