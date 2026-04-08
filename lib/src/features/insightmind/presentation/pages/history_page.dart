// lib/src/features/insightmind/presentation/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/history_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../data/local/history_storage.dart';
import 'login_page.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static const Color deepDarkBrown = Color(0xFF2D1B14);
  static const Color primaryBrown = Color(0xFF634832);
  static const Color creamHighlight = Color(0xFFF4F1DE);
  static const Color successGreen = Color(0xFF81B29A);
  static const Color dangerRed = Color(0xFFBC4749);

  void _logoutAndReset(BuildContext context, WidgetRef ref) {
    ref.read(userProvider.notifier).state = null;
    ref.read(questionnaireProvider.notifier).resetAnswers();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String _getStatusMessage(String risk) {
    if (risk == 'Tinggi') {
      return "Waktunya jeda sejenak. Jangan ragu bercerita pada ahli.";
    }
    if (risk == 'Sedang') {
      return "Kondisi Anda cukup stabil, namun perlu relaksasi lebih.";
    }
    return "Luar biasa! Pertahankan pola pikir positif Anda hari ini.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text(
          'RIWAYAT ANALISIS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logoutAndReset(context, ref),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 80,
                    color: deepDarkBrown.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat analisis',
                    style: TextStyle(
                      color: deepDarkBrown.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            children: [
              // 1. Header Greeting
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBrown, deepDarkBrown],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: deepDarkBrown.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Halo, ${user?.name ?? 'Sobat'}!",
                          style: TextStyle(
                            color: creamHighlight.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFE29578),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getStatusMessage(history[0].riskLevel),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Trend Card
              if (history.length >= 2) ...[
                Builder(
                  builder: (context) {
                    final latest = history[0].score;
                    final previous = history[1].score;
                    final isImproving = latest <= previous;
                    final diff = (latest - previous).abs();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: deepDarkBrown.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isImproving
                                ? Icons.trending_down_rounded
                                : Icons.trending_up_rounded,
                            color: isImproving ? successGreen : dangerRed,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Skor Anda ${isImproving ? "turun" : "naik"} $diff poin dari terakhir',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: primaryBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // 3. List Riwayat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (ctx, i) {
                    final h = history[i];
                    final Color riskColor = h.riskLevel == 'Tinggi'
                        ? dangerRed
                        : h.riskLevel == 'Sedang'
                            ? const Color(0xFFE29578)
                            : successGreen;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: deepDarkBrown.withOpacity(0.05),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            h.score.toString(),
                            style: TextStyle(
                              color: riskColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(
                          h.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: deepDarkBrown,
                          ),
                        ),
                        subtitle: Text(
                          h.riskLevel.toUpperCase(),
                          style: TextStyle(
                            color: riskColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        trailing: Text(
                          '${h.date.day}/${h.date.month}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: deepDarkBrown.withOpacity(0.3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryBrown),
        ),
        error: (err, _) => Center(
          child: Text('Gagal memuat data: $err'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: user != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: creamHighlight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: const Text(
                      'Hapus Riwayat?',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    content: const Text(
                      'Tindakan ini akan menghapus semua catatan secara permanen.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('BATAL'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: dangerRed,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('HAPUS SEMUA'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await ref
                      .read(historyStorageProvider)
                      .clearHistoryForUser(user.name, user.age);
                  ref.invalidate(historyProvider);
                }
              },
              backgroundColor: dangerRed,
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'BERSIHKAN RIWAYAT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
