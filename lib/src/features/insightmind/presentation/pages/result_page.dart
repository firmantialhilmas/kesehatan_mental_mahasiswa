// lib/src/features/insightmind/presentation/pages/result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/questionnaire_provider.dart';
import '../../providers/score_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/classification_provider.dart';
import '../../providers/history_provider.dart';
import '../../domain/entities/screening_history.dart';
import '../../domain/usecases/naive_bayes_classifier.dart';
import '../../domain/usecases/saw_classifier.dart';
import '../../domain/usecases/calculate_risk_level.dart';
import '../../data/local/user_storage.dart';
import 'home_page.dart';

// ── Palet warna ──────────────────────────────────────────────────────────────
const Color surfaceBrown   = Color(0xFF3D2B24);
const Color deepDarkBrown  = Color(0xFF2D1B14);
const Color primaryBrown   = Color(0xFF634832);
const Color accentPink     = Color(0xFFE07A5F);
const Color creamHighlight = Color(0xFFF4F1DE);

// ── Threshold seragam (0–9 Rendah, 10–19 Sedang, 20–30 Tinggi) ──────────────
String _scoreCategory(int score) {
  if (score >= 20) return 'Risiko Tinggi';
  if (score >= 10) return 'Risiko Sedang';
  return 'Risiko Rendah';
}

Color _scoreCategoryColor(int score) {
  if (score >= 20) return const Color(0xFFC62828);
  if (score >= 10) return const Color(0xFFE65100);
  return const Color(0xFF2E7D32);
}

String _scoreRangeTooltip(int score) {
  if (score >= 20) return 'Skor 20–30 → Risiko Tinggi\nSkor 10–19 → Risiko Sedang\nSkor 0–9   → Risiko Rendah';
  if (score >= 10) return 'Skor 10–19 → Risiko Sedang\nSkor 20–30 → Risiko Tinggi\nSkor 0–9   → Risiko Rendah';
  return 'Skor 0–9   → Risiko Rendah\nSkor 10–19 → Risiko Sedang\nSkor 20–30 → Risiko Tinggi';
}

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qState         = ref.watch(questionnaireProvider);
    final user           = ref.watch(userProvider);
    final answers        = ref.watch(answersProvider);
    final classification = ref.watch(classificationResultProvider(answers));
    final sawResult      = ref.watch(sawResultProvider(answers));

    final score = qState.totalScore;

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text('HASIL SCREENING'),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUserCard(user),
            const SizedBox(height: 20),
            _buildScoreCard(context, score),
            const SizedBox(height: 20),
            _buildSawDimensionCard(sawResult),
            const SizedBox(height: 20),
            _buildClassificationCard(classification),
            const SizedBox(height: 20),
            _buildRecommendationCard(score, sawResult, classification),
            const SizedBox(height: 30),
            _buildActionButton(context, ref, score, user, answers, classification),
          ],
        ),
      ),
    );
  }

  // ── Kartu pengguna ────────────────────────────────────────────────────────
  Widget _buildUserCard(dynamic user) {
    return Card(
      color: surfaceBrown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Halo, ${user?.name ?? "Pengguna"}!',
              style: const TextStyle(
                color: creamHighlight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Usia: ${user?.age ?? '-'} tahun',
              style: TextStyle(
                color: creamHighlight.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Kartu skor total ──────────────────────────────────────────────────────
  Widget _buildScoreCard(BuildContext context, int score) {
    final category      = _scoreCategory(score);
    final categoryColor = _scoreCategoryColor(score);
    final tooltipText   = _scoreRangeTooltip(score);

    return Card(
      color: deepDarkBrown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'SKOR TOTAL',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),

            // Skor dengan tooltip range saat di-tap / hover
            Tooltip(
              message: tooltipText,
              preferBelow: false,
              decoration: BoxDecoration(
                color: deepDarkBrown.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: categoryColor.withOpacity(0.6)),
              ),
              textStyle: TextStyle(
                color: creamHighlight,
                fontSize: 12,
                height: 1.6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: creamHighlight,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      ' / 30',
                      style: TextStyle(
                        color: creamHighlight.withOpacity(0.55),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.info_outline,
                      color: creamHighlight.withOpacity(0.45),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Range keterangan di bawah skor
            Text(
              score >= 20
                  ? 'Rentang: 20–30'
                  : score >= 10
                      ? 'Rentang: 10–19'
                      : 'Rentang: 0–9',
              style: TextStyle(
                color: categoryColor.withOpacity(0.8),
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 8),

            // Badge kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: categoryColor),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: categoryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Skala range visual
            _buildScoreScale(score),
          ],
        ),
      ),
    );
  }

  /// Bar skala visual: Rendah | Sedang | Tinggi
  Widget _buildScoreScale(int score) {
    return Column(
      children: [
        Row(
          children: [
            _scaleSegment('0–9\nRendah',   const Color(0xFF2E7D32), score < 10),
            const SizedBox(width: 3),
            _scaleSegment('10–19\nSedang', const Color(0xFFE65100), score >= 10 && score < 20),
            const SizedBox(width: 3),
            _scaleSegment('20–30\nTinggi', const Color(0xFFC62828), score >= 20),
          ],
        ),
      ],
    );
  }

  Widget _scaleSegment(String label, Color color, bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: active ? color : color.withOpacity(0.3),
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : color.withOpacity(0.6),
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ── Kartu dimensi SAW ─────────────────────────────────────────────────────
  Widget _buildSawDimensionCard(SawResult saw) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: primaryBrown, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Analisis Dimensi (Metode SAW)',
                  style: TextStyle(
                    color: deepDarkBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Simple Additive Weighting — bobot Stres 35%, Kecemasan 35%, Kualitas Tidur 30%',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const Divider(height: 20),
            _buildDimensionRow(
              icon: Icons.bolt,
              label: 'Tingkat Stres',
              percent: saw.stressPercent,
              level: saw.stressLevel,
              color: _levelColor(saw.stressLevel),
            ),
            const SizedBox(height: 14),
            _buildDimensionRow(
              icon: Icons.psychology,
              label: 'Tingkat Kecemasan',
              percent: saw.anxietyPercent,
              level: saw.anxietyLevel,
              color: _levelColor(saw.anxietyLevel),
            ),
            const SizedBox(height: 14),
            _buildDimensionRow(
              icon: Icons.bedtime,
              label: 'Gangguan Kualitas Tidur',
              percent: saw.sleepQualityPercent,
              level: saw.sleepLevel,
              color: _levelColor(saw.sleepLevel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionRow({
    required IconData icon,
    required String label,
    required double percent,
    required String level,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: deepDarkBrown,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                _levelLabel(level),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              child: Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Kartu klasifikasi Naive Bayes ─────────────────────────────────────────
  Widget _buildClassificationCard(ClassificationResult result) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.scatter_plot_outlined, color: primaryBrown, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Klasifikasi Naive Bayes',
                  style: TextStyle(
                    color: deepDarkBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _getColor(result.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getColor(result.category)),
              ),
              child: Text(
                result.displayCategory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getColor(result.category),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: _buildProbChart(result.allProbabilities),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(result.probability * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProbChart(Map<String, double> probs) {
    final categories = ['rendah', 'sedang', 'tinggi'];
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  categories[value.toInt()].capitalize(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: categories.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: probs[entry.value] ?? 0.0,
                color: _getColor(entry.value),
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Kartu rekomendasi ─────────────────────────────────────────────────────
  Widget _buildRecommendationCard(
    int score,
    SawResult saw,
    ClassificationResult nb,
  ) {
    final recs = _buildRecommendations(score, saw, nb);
    final headerColor = _scoreCategoryColor(score);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: primaryBrown, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Rekomendasi untuk Kamu',
                  style: TextStyle(
                    color: deepDarkBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Berdasarkan hasil skor total & analisis dimensi',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const Divider(height: 20),
            ...recs.map((rec) => _buildRecItem(rec, headerColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecItem(_RecItem rec, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rec.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(rec.icon, size: 16, color: rec.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: TextStyle(
                    color: deepDarkBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rec.body,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun daftar rekomendasi berdasarkan skor total, SAW, dan Naive Bayes.
  List<_RecItem> _buildRecommendations(
    int score,
    SawResult saw,
    ClassificationResult nb,
  ) {
    final recs = <_RecItem>[];

    // ── 1. Rekomendasi utama berdasarkan skor total ──────────────────────
    if (score >= 20) {
      recs.add(_RecItem(
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFFC62828),
        title: 'Konsultasikan ke Profesional',
        body:
            'Skor kamu berada di rentang tinggi (20–30). Sangat disarankan untuk segera berbicara dengan psikolog atau konselor kesehatan mental.',
      ));
    } else if (score >= 10) {
      recs.add(_RecItem(
        icon: Icons.self_improvement,
        color: const Color(0xFFE65100),
        title: 'Perhatikan Kondisi Mental Kamu',
        body:
            'Skor kamu berada di rentang sedang (10–19). Mulailah menjaga keseimbangan aktivitas dan istirahat, serta terbuka untuk berbicara dengan orang terpercaya.',
      ));
    } else {
      recs.add(_RecItem(
        icon: Icons.check_circle_outline,
        color: const Color(0xFF2E7D32),
        title: 'Kondisi Kamu Baik',
        body:
            'Skor kamu berada di rentang rendah (0–9). Pertahankan kebiasaan positif, tetap aktif secara sosial, dan jaga rutinitas sehat.',
      ));
    }

    // ── 2. Rekomendasi dimensi Stres ─────────────────────────────────────
    if (saw.stressLevel == 'tinggi') {
      recs.add(_RecItem(
        icon: Icons.bolt,
        color: const Color(0xFFC62828),
        title: 'Kelola Stres Secara Aktif',
        body:
            'Tingkat stres kamu tergolong tinggi (${saw.stressPercent.toStringAsFixed(0)}%). Coba teknik relaksasi seperti pernapasan dalam (4-7-8), meditasi singkat 10 menit, atau olahraga ringan setiap hari.',
      ));
    } else if (saw.stressLevel == 'sedang') {
      recs.add(_RecItem(
        icon: Icons.bolt,
        color: const Color(0xFFE65100),
        title: 'Perhatikan Pemicu Stres',
        body:
            'Stres kamu di level sedang (${saw.stressPercent.toStringAsFixed(0)}%). Identifikasi pemicunya dan luangkan waktu untuk hobi atau aktivitas yang menyenangkan.',
      ));
    }

    // ── 3. Rekomendasi dimensi Kecemasan ─────────────────────────────────
    if (saw.anxietyLevel == 'tinggi') {
      recs.add(_RecItem(
        icon: Icons.psychology,
        color: const Color(0xFFC62828),
        title: 'Atasi Kecemasan dengan Bantuan',
        body:
            'Kecemasan kamu cukup tinggi (${saw.anxietyPercent.toStringAsFixed(0)}%). Pertimbangkan konsultasi dengan psikolog. Teknik grounding 5-4-3-2-1 juga dapat membantu saat kecemasan memuncak.',
      ));
    } else if (saw.anxietyLevel == 'sedang') {
      recs.add(_RecItem(
        icon: Icons.psychology,
        color: const Color(0xFFE65100),
        title: 'Kelola Kekhawatiran Kamu',
        body:
            'Kecemasan di level sedang (${saw.anxietyPercent.toStringAsFixed(0)}%). Coba journaling harian atau berbagi cerita dengan teman dekat untuk meringankan beban pikiran.',
      ));
    }

    // ── 4. Rekomendasi dimensi Kualitas Tidur ────────────────────────────
    if (saw.sleepLevel == 'tinggi') {
      recs.add(_RecItem(
        icon: Icons.bedtime,
        color: const Color(0xFFC62828),
        title: 'Perbaiki Pola Tidur Segera',
        body:
            'Gangguan tidur kamu tergolong tinggi (${saw.sleepQualityPercent.toStringAsFixed(0)}%). Tetapkan jam tidur dan bangun yang konsisten, matikan layar 1 jam sebelum tidur, dan hindari kafein setelah pukul 15.00.',
      ));
    } else if (saw.sleepLevel == 'sedang') {
      recs.add(_RecItem(
        icon: Icons.bedtime,
        color: const Color(0xFFE65100),
        title: 'Optimalkan Kualitas Tidur',
        body:
            'Kualitas tidur kamu kurang optimal (${saw.sleepQualityPercent.toStringAsFixed(0)}%). Ciptakan rutinitas tidur yang nyaman: redupkan lampu, hindari scrolling media sosial, dan coba dengarkan musik relaksasi.',
      ));
    }

    // ── 5. Catatan tambahan jika Naive Bayes tinggi tapi skor sedang ─────
    if (nb.category == 'tinggi' && score < 20) {
      recs.add(_RecItem(
        icon: Icons.warning_amber_outlined,
        color: const Color(0xFFE65100),
        title: 'Perhatian dari Analisis Lanjutan',
        body:
            'Model Naive Bayes mendeteksi pola jawaban yang mengarah ke risiko tinggi meskipun skor totalmu sedang. Pertimbangkan untuk mengisi ulang kuesioner dengan lebih teliti atau berkonsultasi lebih lanjut.',
      ));
    }

    return recs;
  }

  // ── Tombol aksi ───────────────────────────────────────────────────────────
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    int score,
    dynamic user,
    List<int> answers,
    ClassificationResult result,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBrown,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          final history = ScreeningHistory(
            score: score,
            name: user?.name ?? 'Anonim',
            age: user?.age ?? 0,
            timestamp: DateTime.now(),
            answers: answers,
            category: result.category,
            probability: result.probability,
            allProbabilities: result.allProbabilities,
          );

          try {
            await ref.read(saveHistoryProvider)(history);
          } catch (e) {
            debugPrint('Save error: $e');
          }

          ref.read(questionnaireProvider.notifier).resetAnswers();
          ref.read(answersProvider.notifier).state = [];

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        child: const Text(
          'KEMBALI KE BERANDA',
          style: TextStyle(
            color: creamHighlight,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ── Helper warna & label ──────────────────────────────────────────────────

  Color _getColor(String category) {
    if (category == 'rendah') return const Color(0xFF2E7D32);
    if (category == 'sedang') return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'rendah': return const Color(0xFF2E7D32);
      case 'sedang': return const Color(0xFFE65100);
      case 'tinggi': return const Color(0xFFC62828);
      default:       return Colors.grey;
    }
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'rendah': return 'Rendah';
      case 'sedang': return 'Sedang';
      case 'tinggi': return 'Tinggi';
      default:       return '-';
    }
  }
}

// ── Model item rekomendasi ────────────────────────────────────────────────────
class _RecItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _RecItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

// ── Extension helper ──────────────────────────────────────────────────────────
extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
