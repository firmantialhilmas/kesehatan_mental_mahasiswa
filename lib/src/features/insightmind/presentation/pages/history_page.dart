// lib/src/features/insightmind/presentation/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/history_provider.dart';
import '../../domain/entities/screening_history.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color deepDarkBrown = Color(0xFF2D1B14);
    const Color primaryBrown = Color(0xFF634832);
    const Color accentPink = Color(0xFFE07A5F);
    const Color creamHighlight = Color(0xFFF4F1DE);

    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        title: const Text('RIWAYAT ANALISIS'),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        centerTitle: true,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (histories) {
          if (histories.isEmpty) return _buildEmptyState(deepDarkBrown, creamHighlight);
          // ✅ FIXED: timestamp sorting
          histories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: histories.length,
                  itemBuilder: (context, index) => _buildHistoryCard(histories[index], deepDarkBrown, primaryBrown, accentPink, creamHighlight),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: creamHighlight, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
                child: ElevatedButton.icon(
                  onPressed: () => _showClearConfirmation(context, ref, deepDarkBrown, creamHighlight),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('BERSIHKAN RIWAYAT'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 48, color: Colors.red.shade400), const SizedBox(height: 16), Text('Error: $error', style: const TextStyle(color: Colors.red))])),
      ),
    );
  }

  Widget _buildEmptyState(Color deepDarkBrown, Color creamHighlight) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 80, color: deepDarkBrown.withOpacity(0.2)), const SizedBox(height: 16), Text('Belum ada riwayat analisis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: deepDarkBrown.withOpacity(0.6))), const SizedBox(height: 8), Text('Lakukan screening untuk melihat riwayat', style: TextStyle(fontSize: 13, color: deepDarkBrown.withOpacity(0.4)), textAlign: TextAlign.center)]));
  }

  Widget _buildHistoryCard(ScreeningHistory history, Color deepDarkBrown, Color primaryBrown, Color accentPink, Color creamHighlight) {
    String riskLevel; Color riskColor;
    if (history.score <= 10) { riskLevel = 'Sehat Mental'; riskColor = Colors.green; }
    else if (history.score <= 20) { riskLevel = 'Ringan'; riskColor = Colors.orange; }
    else { riskLevel = 'Perlu Perhatian'; riskColor = Colors.red; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: deepDarkBrown.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd MMM yyyy, HH:mm').format(history.timestamp), style: TextStyle(fontSize: 12, color: deepDarkBrown.withOpacity(0.6), fontWeight: FontWeight.w500)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: riskColor)), child: Text(riskLevel, style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryBrown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.analytics_outlined, color: primaryBrown, size: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Skor Total', style: TextStyle(fontSize: 11, color: deepDarkBrown.withOpacity(0.6))), Text('${history.score} / 30', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepDarkBrown))])),
              if (history.name.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: accentPink.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(history.name, style: TextStyle(fontSize: 11, color: accentPink, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref, Color deepDarkBrown, Color creamHighlight) {
    showDialog(context: context, builder: (dialogContext) => AlertDialog(backgroundColor: creamHighlight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Text('Bersihkan Riwayat?'), content: const Text('Semua riwayat analisis akan dihapus permanen.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')), ElevatedButton(onPressed: () { ref.read(clearHistoryProvider)(); Navigator.pop(dialogContext); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat berhasil dibersihkan'), backgroundColor: Colors.green)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white), child: const Text('Hapus'))]));
  }
}