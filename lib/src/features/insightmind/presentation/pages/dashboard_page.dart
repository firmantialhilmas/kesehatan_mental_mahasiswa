// lib/src/features/insightmind/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/history_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/report_provider.dart';
import 'biometric_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  // Palette Warna Konsisten
  static const Color deepDarkBrown = Color(0xFF2D1B14);
  static const Color primaryBrown = Color(0xFF634832);
  static const Color accentPink = Color(0xFFE07A5F);
  static const Color creamHighlight = Color(0xFFF4F1DE);
  static const Color surfaceBrown = Color(0xFF3D2B24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text(
          'DASHBOARD ANALITIK',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 18),
        ),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        elevation: 0,
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 80, color: deepDarkBrown.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data screening',
                    style: TextStyle(fontSize: 18, color: primaryBrown, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lakukan screening terlebih dahulu\nuntuk melihat tren kesehatan mental Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: primaryBrown.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          }

          final sorted = history..sort((a, b) => a.date.compareTo(b.date));
          final spots = sorted.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.score.toDouble());
          }).toList();

          final avgScore = sorted.isEmpty
              ? 0.0
              : sorted.map((e) => e.score.toDouble()).reduce((a, b) => a + b) / sorted.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CARD RINGKASAN DENGAN GRADASI
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [deepDarkBrown, surfaceBrown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: deepDarkBrown.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Halo, ${user?.name.split(' ').first ?? 'Pengguna'}!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: creamHighlight,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              title: 'Rata-rata Skor',
                              value: avgScore.toStringAsFixed(1),
                              icon: Icons.auto_graph_rounded,
                            ),
                            Container(width: 1, height: 40, color: creamHighlight.withOpacity(0.2)),
                            _buildStatCard(
                              title: 'Total Screening',
                              value: history.length.toString(),
                              icon: Icons.history_edu_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // GRAFIK TREND (Disesuaikan Warnanya)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: deepDarkBrown.withOpacity(0.05)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tren Skor Mental',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: deepDarkBrown),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: deepDarkBrown.withOpacity(0.05),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: accentPink, // Warna garis trend
                                  barWidth: 5,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [accentPink.withOpacity(0.3), accentPink.withOpacity(0.0)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // TOMBOL DOWNLOAD PDF (Gradient Modern)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(colors: [Color(0xFFD62828), Color(0xFF9B2226)]),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('DOWNLOAD LAPORAN PDF', style: TextStyle(fontWeight: FontWeight.w900)),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () async {
                      final currentHistory = await ref.read(historyProvider.future);
                      final currentUser = ref.read(userProvider);

                      if (currentUser == null || currentHistory.isEmpty) return;

                      await generateAndShowPdf(
                        ref: ref,
                        username: currentUser.name,
                        history: currentHistory,
                        context: context,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // TOMBOL BIOMETRIK (Outline Style)
                OutlinedButton.icon(
                  icon: const Icon(Icons.sensors_rounded),
                  label: const Text('SENSOR & BIOMETRIK', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: deepDarkBrown, width: 2),
                    foregroundColor: deepDarkBrown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BiometricPage()),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: primaryBrown)),
        error: (_, __) => const Center(child: Text('Error memuat data')),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: accentPink),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, color: creamHighlight.withOpacity(0.7), fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: creamHighlight)),
      ],
    );
  }
}