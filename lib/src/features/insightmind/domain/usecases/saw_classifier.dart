// lib/src/features/insightmind/domain/usecases/saw_classifier.dart
//
// Metode SAW (Simple Additive Weighting) untuk menghitung persentase
// per dimensi: Stres, Kecemasan, dan Kualitas Tidur.
//
// Pemetaan pertanyaan (indeks 0–9, berlaku untuk semua kelompok usia):
//   Struktur kuesioner per kelompok usia:
//     Q1–Q4  (indeks 0–3) → Stres
//     Q5–Q7  (indeks 4–6) → Kecemasan
//     Q8–Q10 (indeks 7–9) → Kualitas Tidur
//
// Bobot per dimensi (SAW weight, total = 1.0):
//   Stres: 0.35  |  Kecemasan: 0.35  |  Kualitas Tidur: 0.30
//
// Setiap jawaban berskala 0–3. Nilai dinormalisasi ke [0, 1],
// kemudian dikalikan bobot → skor SAW per dimensi.
// Persentase = skor_ternormalisasi × 100.

class SawResult {
  /// Persentase tingkat stres (0–100)
  final double stressPercent;

  /// Persentase tingkat kecemasan (0–100)
  final double anxietyPercent;

  /// Persentase masalah kualitas tidur (0–100)
  /// Nilai tinggi = kualitas tidur buruk
  final double sleepQualityPercent;

  /// Kategori per dimensi: 'rendah' | 'sedang' | 'tinggi'
  final String stressLevel;
  final String anxietyLevel;
  final String sleepLevel;

  const SawResult({
    required this.stressPercent,
    required this.anxietyPercent,
    required this.sleepQualityPercent,
    required this.stressLevel,
    required this.anxietyLevel,
    required this.sleepLevel,
  });
}

class SawClassifier {
  // ── Bobot dimensi (harus berjumlah 1.0) ──────────────────────────────
  static const double _wStress  = 0.35;
  static const double _wAnxiety = 0.35;
  static const double _wSleep   = 0.30;

  // ── Indeks pertanyaan per dimensi (0-based dari List<int> answers) ───
  // Sesuai struktur kuesioner baru (berlaku semua kelompok usia):
  //   Q1–Q4  → Stres          (indeks 0, 1, 2, 3)
  //   Q5–Q7  → Kecemasan      (indeks 4, 5, 6)
  //   Q8–Q10 → Kualitas Tidur (indeks 7, 8, 9)
  static const List<int> _stressIdx  = [0, 1, 2, 3];
  static const List<int> _anxietyIdx = [4, 5, 6];
  static const List<int> _sleepIdx   = [7, 8, 9];

  // ── Nilai maks per pertanyaan (skala 0–3) ────────────────────────────
  static const int _maxScore = 3;

  SawResult classify(List<int> answers) {
    if (answers.length < 10) {
      // Jika jawaban tidak lengkap, fallback ke 0
      return const SawResult(
        stressPercent: 0,
        anxietyPercent: 0,
        sleepQualityPercent: 0,
        stressLevel: 'rendah',
        anxietyLevel: 'rendah',
        sleepLevel: 'rendah',
      );
    }

    final stressRaw  = _dimensionScore(answers, _stressIdx);
    final anxietyRaw = _dimensionScore(answers, _anxietyIdx);
    final sleepRaw   = _dimensionScore(answers, _sleepIdx);

    // Normalisasi: nilai / (jumlah_pertanyaan × maks_skor)
    final stressNorm  = stressRaw  / (_stressIdx.length  * _maxScore);
    final anxietyNorm = anxietyRaw / (_anxietyIdx.length * _maxScore);
    final sleepNorm   = sleepRaw   / (_sleepIdx.length   * _maxScore);

    // Skor SAW = nilai_ternormalisasi × bobot
    final stressSaw  = stressNorm  * _wStress;
    final anxietySaw = anxietyNorm * _wAnxiety;
    final sleepSaw   = sleepNorm   * _wSleep;

    // Persentase relatif terhadap bobot maksimum dimensi
    final stressPercent  = (stressSaw  / _wStress)  * 100;
    final anxietyPercent = (anxietySaw / _wAnxiety) * 100;
    final sleepPercent   = (sleepSaw   / _wSleep)   * 100;

    return SawResult(
      stressPercent:       stressPercent.clamp(0, 100),
      anxietyPercent:      anxietyPercent.clamp(0, 100),
      sleepQualityPercent: sleepPercent.clamp(0, 100),
      stressLevel:  _toLevel(stressPercent),
      anxietyLevel: _toLevel(anxietyPercent),
      sleepLevel:   _toLevel(sleepPercent),
    );
  }

  // ── Helper: jumlahkan skor dari indeks dimensi ───────────────────────
  int _dimensionScore(List<int> answers, List<int> indices) {
    int total = 0;
    for (final i in indices) {
      if (i < answers.length) total += answers[i];
    }
    return total;
  }

  // ── Konversi persentase ke level teks ────────────────────────────────
  String _toLevel(double percent) {
    if (percent >= 66.7) return 'tinggi';
    if (percent >= 33.3) return 'sedang';
    return 'rendah';
  }
}
