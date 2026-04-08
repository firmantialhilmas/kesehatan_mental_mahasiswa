class CalculateRiskLevel {
  /// Mengembalikan hanya teks level risiko
  String execute(int score) {
    if (score >= 20) {
      return 'Tinggi';
    } else if (score >= 10) {
      return 'Sedang';
    } else {
      return 'Rendah';
    }
  }
}
