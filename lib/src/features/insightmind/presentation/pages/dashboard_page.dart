import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../../providers/history_provider.dart';
import '../../providers/user_provider.dart';
import '../../domain/entities/screening_history.dart';
import '../../domain/usecases/report_generator.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color deepDarkBrown = Color(0xFF2D1B14);
    const Color primaryBrown = Color(0xFF634832);
    const Color accentPink = Color(0xFFE07A5F);
    const Color creamHighlight = Color(0xFFF4F1DE);

    final historyAsync = ref.watch(historyListProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text('DASHBOARD ANALITIK'),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        centerTitle: true,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (histories) {
          if (histories.isEmpty) {
            return _buildEmptyState(deepDarkBrown);
          }

          // Urutkan berdasarkan tanggal
          histories.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(
                  histories,
                  deepDarkBrown,
                  primaryBrown,
                  accentPink,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  'Tren Skor Kesehatan Mental',
                  deepDarkBrown,
                ),

                const SizedBox(height: 16),

                _buildLineChart(
                  histories,
                  deepDarkBrown,
                  accentPink,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  'Distribusi Kategori (Naive Bayes)',
                  deepDarkBrown,
                ),

                const SizedBox(height: 16),

                _buildCategoryPieChart(
                  histories,
                  deepDarkBrown,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  '5 Screening Terakhir',
                  deepDarkBrown,
                ),

                const SizedBox(height: 16),

                _buildRecentHistory(
                  histories.reversed.take(5).toList(),
                  deepDarkBrown,
                  primaryBrown,
                ),

                const SizedBox(height: 20),

                // ===== BUTTON DOWNLOAD PDF =====
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                    onPressed: () async {
//   try {
//     final file = await ReportGenerator.generateReport(
//       username: user?.name ?? 'User',
//       history: histories,
//     );

//     await OpenFile.open(file.path);

//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'PDF berhasil dibuat',
//           ),
//         ),
//       );
//     }
//   } catch (e) {
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Gagal membuat PDF: $e',
//           ),
//         ),
//       );
//     }
//   }
// },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBrown,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     icon: const Icon(Icons.picture_as_pdf),
//                     label: const Text(
//                       'Download Hasil Screening PDF',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//          ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color deepDarkBrown) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: deepDarkBrown.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data screening',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: deepDarkBrown.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    List<ScreeningHistory> histories,
    Color deepDarkBrown,
    Color primaryBrown,
    Color accentPink,
  ) {
    final totalScreening = histories.length;

    final double avgScore = histories.isEmpty
        ? 0.0
        : histories.fold<int>(
              0,
              (sum, h) => sum + h.score,
            ) /
            totalScreening;

    final latestScore = histories.last.score;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Screening',
            '$totalScreening',
            Icons.analytics,
            primaryBrown,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            'Rata-rata Skor',
            avgScore.toStringAsFixed(1),
            Icons.trending_up,
            accentPink,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            'Skor Terakhir',
            '$latestScore',
            Icons.score,
            deepDarkBrown,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    Color deepDarkBrown,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: deepDarkBrown,
      ),
    );
  }

  Widget _buildLineChart(
    List<ScreeningHistory> histories,
    Color deepDarkBrown,
    Color accentPink,
  ) {
    final spots = histories.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.score.toDouble(),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: deepDarkBrown.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: accentPink,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(
    List<ScreeningHistory> histories,
    Color deepDarkBrown,
  ) {
    int rendah =
        histories.where((h) => h.category == 'rendah').length;

    int sedang =
        histories.where((h) => h.category == 'sedang').length;

    int tinggi =
        histories.where((h) => h.category == 'tinggi').length;

    final sections = <PieChartSectionData>[];

    if (rendah > 0) {
      sections.add(
        PieChartSectionData(
          value: rendah.toDouble(),
          title: '$rendah',
          color: Colors.green,
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (sedang > 0) {
      sections.add(
        PieChartSectionData(
          value: sedang.toDouble(),
          title: '$sedang',
          color: Colors.orange,
          radius: 50,
        ),
      );
    }

    if (tinggi > 0) {
      sections.add(
        PieChartSectionData(
          value: tinggi.toDouble(),
          title: '$tinggi',
          color: Colors.red,
          radius: 50,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildRecentHistory(
    List<ScreeningHistory> histories,
    Color deepDarkBrown,
    Color primaryBrown,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: histories.length,
        separatorBuilder: (context, index) =>
            Divider(color: deepDarkBrown.withOpacity(0.1)),
        itemBuilder: (context, index) {
          final h = histories[index];

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics,
                color: primaryBrown,
                size: 20,
              ),
            ),
            title: Text(
              'Screening #${histories.length - index}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy, HH:mm')
                  .format(h.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: deepDarkBrown.withOpacity(0.6),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: h.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: h.categoryColor,
                ),
              ),
              child: Text(
                h.displayCategory,
                style: TextStyle(
                  color: h.categoryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
