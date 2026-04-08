// lib/src/features/insightmind/presentation/pages/screening_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../../providers/questionnaire_provider.dart';
import '../../providers/score_provider.dart';
import '../widgets/question_tile.dart';
import 'result_page.dart';

class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color deepDarkBrown = Color(0xFF2D1B14);
    const Color primaryBrown = Color(0xFF634832);
    const Color accentPink = Color(0xFFE07A5F);
    const Color creamHighlight = Color(0xFFF4F1DE);
    const Color surfaceBrown = Color(0xFF3D2B24);

    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final progressPercent =
        questions.isEmpty ? 0.0 : (qState.answers.length / questions.length);
    final progressLabel =
        '${qState.answers.length} dari ${questions.length} Pertanyaan';

    // Helper untuk pesan penyemangat (Fitur Tambahan)
    String getEncouragement(double progress) {
      if (progress == 0) return "Mari mulai mengenali diri lebih dalam.";
      if (progress < 0.5)
        return "Terima kasih sudah jujur pada dirimu sendiri.";
      if (progress < 1.0) return "Sangat bagus! Sedikit lagi selesai.";
      return "Semua pertanyaan terjawab. Siap melihat hasil?";
    }

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text(
          'SCREENING MENTAL',
          style: TextStyle(
              fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 18),
        ),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [deepDarkBrown, surfaceBrown],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressLabel,
                      style: TextStyle(
                          color: creamHighlight.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(progressPercent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: creamHighlight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 10,
                    backgroundColor: Colors.black26,
                    color: creamHighlight,
                  ),
                ),
                // --- PENAMBAHAN TEXT PENYEMANGAT ---
                const SizedBox(height: 12),
                Text(
                  getEncouragement(progressPercent),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: creamHighlight.withOpacity(0.9),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              itemCount: questions.length,
              separatorBuilder: (context, index) {
                // --- MICRO INTERACTION: SISIPKAN TIP SETIAP 5 PERTANYAAN ---
                if (index == 4) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: accentPink.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: accentPink),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Tips: Jawablah sesuai kondisi 2 minggu terakhir agar hasil akurat.",
                            style: TextStyle(
                                fontSize: 12,
                                color: primaryBrown,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final q = questions[index];
                final selected = qState.answers[q.id];

                return QuestionTile(
                  question: q,
                  selectedScore: selected,
                  onSelected: (score) {
                    ref
                        .read(questionnaireProvider.notifier)
                        .selectAnswer(questionId: q.id, score: score);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: surfaceBrown,
        foregroundColor: creamHighlight,
        elevation: 4,
        child: const Icon(Icons.restart_alt_rounded),
        onPressed: () => _showResetDialog(
            context, ref, surfaceBrown, creamHighlight, accentPink),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: creamHighlight,
          boxShadow: [
            BoxShadow(
              color: deepDarkBrown.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [primaryBrown, deepDarkBrown],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () {
              if (!qState.isComplete) {
                _showIncompleteSnackBar(context, primaryBrown);
                return;
              }
              _showSummaryDialog(context, ref, questions, qState, surfaceBrown,
                  creamHighlight, accentPink);
            },
            child: const Text(
              'ANALISIS HASIL SEKARANG',
              style: TextStyle(
                color: creamHighlight,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- METHODS TETAP SAMA ---
  void _showIncompleteSnackBar(BuildContext context, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mohon lengkapi semua pertanyaan terlebih dahulu.'),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showResetDialog(
      BuildContext context, WidgetRef ref, Color bg, Color text, Color accent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        title: Text('Reset Jawaban?', style: TextStyle(color: text)),
        content: const Text('Semua progres screening saat ini akan dihapus.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('BATAL', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              ref.read(questionnaireProvider.notifier).resetAnswers();
              ref.read(answersProvider.notifier).state = [];
              Navigator.pop(ctx);
            },
            child: Text('RESET', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(
      BuildContext context,
      WidgetRef ref,
      List<Question> questions,
      QuestionnaireState qState,
      Color bg,
      Color text,
      Color accent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Konfirmasi Jawaban',
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (context, i) {
              final q = questions[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${q.text}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text(
                      qState.getAnswerLabel(q.id),
                      style: TextStyle(
                          color: Color(0xFFF4F1DE),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    const Divider(color: Colors.white10),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('KOREKSI',
                  style: TextStyle(color: Colors.white38))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: () {
              Navigator.pop(ctx);

              final answersOrdered =
                  questions.map((q) => qState.answers[q.id]!).toList();

              // SET SEKALI SAJA
              ref.read(answersProvider.notifier).state = answersOrdered;

              // PAKSA NAVIGASI SEKALI, TIDAK BISA DOBEL
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ResultPage()),
              );
            },
            child: const Text('LANJUTKAN'),
          ),
        ],
      ),
    );
  }
}
