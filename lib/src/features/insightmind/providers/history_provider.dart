// lib/src/features/insightmind/providers/history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/history_storage.dart';
import '../domain/entities/screening_history.dart';

/// Provider untuk mengakses history storage
final historyStorageProvider = Provider<HistoryStorage>((ref) {
  return HistoryStorage();
});

/// Provider untuk mendapatkan semua history
final historyListProvider = FutureProvider<List<ScreeningHistory>>((ref) async {
  final storage = ref.watch(historyStorageProvider);
  return await storage.getAllHistory();
});

/// Provider untuk mengecek apakah ada history
final hasHistoryProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(historyStorageProvider);
  return await storage.hasHistory();
});

/// Provider untuk menyimpan history baru
final saveHistoryProvider = Provider.autoDispose((ref) {
  return (ScreeningHistory history) async {
    final storage = ref.read(historyStorageProvider);
    await storage.saveHistory(history);
    
    // Refresh history list
    ref.invalidate(historyListProvider);
    ref.invalidate(hasHistoryProvider);
  };
});

/// Provider untuk menghapus semua history
final clearHistoryProvider = Provider.autoDispose((ref) {
  return () async {
    final storage = ref.read(historyStorageProvider);
    await storage.clearHistory();
    
    // Refresh providers
    ref.invalidate(historyListProvider);
    ref.invalidate(hasHistoryProvider);
  };
});

/// Provider untuk history terakhir
final latestHistoryProvider = FutureProvider<ScreeningHistory?>((ref) async {
  final storage = ref.watch(historyStorageProvider);
  return await storage.getLatestHistory();
});

/// Provider untuk statistik (rata-rata skor)
final averageScoreProvider = FutureProvider<double?>((ref) async {
  final histories = await ref.watch(historyListProvider.future);
  if (histories.isEmpty) return null;
  
  final total = histories.fold<int>(0, (sum, h) => sum + h.score);
  return total / histories.length;
});

/// Provider untuk skor tertinggi
final highestScoreProvider = FutureProvider<int?>((ref) async {
  final histories = await ref.watch(historyListProvider.future);
  if (histories.isEmpty) return null;
  return histories.map((h) => h.score).reduce((a, b) => a > b ? a : b);
});

/// Provider untuk skor terendah
final lowestScoreProvider = FutureProvider<int?>((ref) async {
  final histories = await ref.watch(historyListProvider.future);
  if (histories.isEmpty) return null;
  return histories.map((h) => h.score).reduce((a, b) => a < b ? a : b);
});