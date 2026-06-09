// lib/src/features/insightmind/domain/usecases/naive_bayes_classifier.dart
import 'dart:math';

class NaiveBayesClassifier {
  static const categories = ['rendah', 'sedang', 'tinggi'];

  // Prior probabilities (bisa di-update dengan data historis)
  final Map<String, double> _priors = {
    'rendah': 0.40,
    'sedang': 0.35,
    'tinggi': 0.25,
  };

  // Parameter Gaussian per kategori (mean & std untuk 10 pertanyaan)
  // Nilai ini bisa di-tuning berdasarkan dataset training
  final Map<String, Map<int, _Gaussian>> _gaussians = {
    'rendah': {for (var i = 0; i < 10; i++) i: _Gaussian(mean: 0.7, std: 0.6)},
    'sedang': {for (var i = 0; i < 10; i++) i: _Gaussian(mean: 1.5, std: 0.7)},
    'tinggi': {for (var i = 0; i < 10; i++) i: _Gaussian(mean: 2.4, std: 0.5)},
  };

  ClassificationResult classify(List<int> answers) {
    if (answers.isEmpty) {
      return ClassificationResult(
        category: 'sedang',
        probability: 0.33,
        allProbabilities: {'rendah': 0.33, 'sedang': 0.34, 'tinggi': 0.33},
      );
    }

    final logProbs = <String, double>{};

    for (final cat in categories) {
      double logProb = log(_priors[cat]!);
      for (var i = 0; i < answers.length; i++) {
        final g = _gaussians[cat]?[i];
        if (g != null) logProb += g.logProbability(answers[i].toDouble());
      }
      logProbs[cat] = logProb;
    }

    // Softmax conversion
    final maxLog = logProbs.values.reduce((a, b) => a > b ? a : b);
    final exps = logProbs.map((k, v) => MapEntry(k, exp(v - maxLog)));
    final sumExp = exps.values.reduce((a, b) => a + b);
    final probs = exps.map((k, v) => MapEntry(k, v / sumExp));

    final predicted = probs.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return ClassificationResult(
      category: predicted,
      probability: probs[predicted]!,
      allProbabilities: probs,
    );
  }
}

class _Gaussian {
  final double mean;
  final double std;
  _Gaussian({required this.mean, required this.std});

  double logProbability(double x) {
    final exponent = -0.5 * pow((x - mean) / std, 2);
    return log(1 / (std * sqrt(2 * pi))) + exponent;
  }
}

class ClassificationResult {
  final String category;
  final double probability;
  final Map<String, double> allProbabilities;

  const ClassificationResult({
    required this.category,
    required this.probability,
    required this.allProbabilities,
  });

  String get displayCategory {
    switch (category) {
      case 'rendah': return 'Risiko Rendah';
      case 'sedang': return 'Risiko Sedang';
      case 'tinggi': return 'Risiko Tinggi';
      default: return 'Belum Terklasifikasi';
    }
  }

  String get recommendation {
    switch (category) {
      case 'rendah': return 'Kondisi mental Anda baik. Pertahankan pola hidup sehat dan tetap terhubung dengan lingkungan sosial.';
      case 'sedang': return 'Perhatikan kesejahteraan mental Anda. Cobalah teknik relaksasi, cukup istirahat, dan bicara dengan orang terpercaya.';
      case 'tinggi': return 'Disarankan untuk berkonsultasi dengan profesional kesehatan mental untuk evaluasi lebih lanjut.';
      default: return 'Silakan lengkapi kuesioner untuk mendapatkan hasil yang akurat.';
    }
  }
}