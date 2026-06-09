// lib/src/features/insightmind/domain/usecases/calculate_risk_level.dart
//
// Threshold seragam (skor total maks = 30, dari 10 soal × skala 0–3):
//   0  – 9  → Rendah
//   10 – 19 → Sedang
//   20 – 30 → Tinggi

class CalculateRiskLevel {
  /// Mengembalikan teks level risiko berdasarkan skor total.
  String execute(int score) {
    if (score >= 20) return 'Tinggi';
    if (score >= 10) return 'Sedang';
    return 'Rendah';
  }

  /// Range teks per level untuk ditampilkan di UI.
  static String rangeLabel(int score) {
    if (score >= 20) return 'Skor 20–30: Risiko Tinggi';
    if (score >= 10) return 'Skor 10–19: Risiko Sedang';
    return 'Skor 0–9: Risiko Rendah';
  }
}
