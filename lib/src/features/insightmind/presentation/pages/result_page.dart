// lib/src/features/insightmind/presentation/pages/result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../data/local/history_storage.dart';
import '../../domain/entities/screening_history.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'screening_page.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  static const Color deepDarkBrown = Color(0xFF2D1B14);
  static const Color primaryBrown = Color(0xFF634832);
  static const Color accentPink = Color(0xFFE07A5F);
  static const Color creamHighlight = Color(0xFFF4F1DE);
  static const Color successGreen = Color(0xFF81B29A);

  String _getPersonalMessage(String name, int age, String risk) {
    final firstName = name.split(' ').first;
    if (risk == 'Tinggi') {
      return age < 20
          ? '$firstName, segera ceritakan pada orang tua atau konselor sekolah.'
          : '$firstName, segera hubungi psikolog atau layanan kesehatan mental.';
    } else if (risk == 'Sedang') {
      return age < 25
          ? '$firstName, coba olahraga, tidur cukup, dan curhat ke teman.'
          : '$firstName, atur istirahat dan pertimbangkan konsultasi.';
    } else {
      return '$firstName, kondisimu baik! Pertahankan pola hidup sehat.';
    }
  }

  List<Map<String, dynamic>> _getActionSteps(String risk) {
    if (risk == 'Tinggi') {
      return [
        {
          'icon': Icons.phone_in_talk,
          'text': 'Hubungi layanan bantuan kesehatan mental'
        },
        {
          'icon': Icons.self_improvement,
          'text': 'Lakukan teknik pernapasan 4-7-8 sekarang'
        },
        {
          'icon': Icons.bed_rounded,
          'text': 'Prioritaskan waktu istirahat total hari ini'
        },
      ];
    } else if (risk == 'Sedang') {
      return [
        {
          'icon': Icons.directions_walk,
          'text': 'Jalan kaki ringan selama 15 menit'
        },
        {
          'icon': Icons.no_drinks,
          'text': 'Batasi asupan kafein dan gula berlebih'
        },
        {
          'icon': Icons.edit_note,
          'text': 'Tuliskan hal yang mengganggu pikiranmu'
        },
      ];
    } else {
      return [
        {'icon': Icons.auto_awesome, 'text': 'Lanjutkan kebiasaan positifmu'},
        {
          'icon': Icons.favorite_border,
          'text': 'Tuliskan 3 hal yang kamu syukuri hari ini'
        },
        {
          'icon': Icons.wb_sunny_outlined,
          'text': 'Dapatkan sinar matahari pagi esok hari'
        },
      ];
    }
  }

  void _logoutAndReset(BuildContext context, WidgetRef ref) {
    ref.read(userProvider.notifier).state = null;
    ref.read(questionnaireProvider.notifier).resetAnswers();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(questionnaireProvider);
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    final score = questionnaire.totalScore;
    final riskLevel = score >= 20
        ? 'Tinggi'
        : score >= 10
            ? 'Sedang'
            : 'Rendah';

    Future.microtask(() async {
      final history = ScreeningHistory(
        date: DateTime.now(),
        score: score,
        riskLevel: riskLevel,
        name: user.name,
        age: user.age,
      );
      await ref.read(historyStorageProvider).saveHistory(history);
      ref.invalidate(historyProvider);
    });

    final riskColor = riskLevel == 'Tinggi'
        ? Colors.redAccent
        : riskLevel == 'Sedang'
            ? Colors.orangeAccent
            : successGreen;

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text('ANALISIS HASIL',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // KARTU HASIL UTAMA
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                      color: deepDarkBrown.withOpacity(0.05), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: deepDarkBrown,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: creamHighlight),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Halo, ${user.name.split(' ').first}!',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: deepDarkBrown)),
                      const SizedBox(height: 16),
                      Icon(
                        riskLevel == 'Tinggi'
                            ? Icons.warning_amber_rounded
                            : riskLevel == 'Sedang'
                                ? Icons.info_outline_rounded
                                : Icons.check_circle_outline_rounded,
                        size: 60,
                        color: riskColor,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: riskColor, width: 2),
                        ),
                        child: Text(riskLevel.toUpperCase(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: riskColor)),
                      ),
                      const SizedBox(height: 16),
                      Text('Total Skor: $score',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: deepDarkBrown)),
                      const SizedBox(height: 12),
                      Text(_getPersonalMessage(user.name, user.age, riskLevel),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, height: 1.5, color: primaryBrown)),
                    ],
                  ),
                ),
              ),

              // SEKSI REKOMENDASI
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: deepDarkBrown.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_circle, color: accentPink),
                        SizedBox(width: 8),
                        Text('LANGKAH SELANJUTNYA',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: deepDarkBrown,
                                letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._getActionSteps(riskLevel).map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(step['icon'],
                                  size: 20,
                                  color: primaryBrown.withOpacity(0.6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(step['text'],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: primaryBrown)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              // --- FITUR BARU: EMERGENCY SUPPORT (Hanya Muncul Jika Risiko Tinggi) ---
              if (riskLevel == 'Tinggi') ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.gpp_maybe_rounded,
                              color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text("BANTUAN DARURAT",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.redAccent)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Jangan hadapi ini sendirian. Bantuan profesional tersedia untukmu sekarang.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: deepDarkBrown),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Di sini nantinya bisa ditambahkan logika url_launcher
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text("HUBUNGI HALO KEMENKES (1500-567)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.home_filled),
                      label: const Text('HOME'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: deepDarkBrown, width: 2),
                        foregroundColor: deepDarkBrown,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                            colors: [accentPink, primaryBrown]),
                      ),
                      child: FilledButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('ULANGI'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          ref
                              .read(questionnaireProvider.notifier)
                              .resetAnswers();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ScreeningPage()),
                            (route) => route.isFirst,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Hasil ini bersifat indikasi awal, bukan diagnosis klinis resmi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: deepDarkBrown.withOpacity(0.4),
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
