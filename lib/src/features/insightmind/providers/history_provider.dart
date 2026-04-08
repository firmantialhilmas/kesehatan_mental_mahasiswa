// lib/src/features/insightmind/providers/history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/history_storage.dart';
import '../domain/entities/screening_history.dart';
import 'user_provider.dart';

final historyStorageProvider = Provider((ref) => HistoryStorage());

final historyProvider = FutureProvider<List<ScreeningHistory>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final allHistory = await ref.read(historyStorageProvider).getAllHistory();
  return allHistory
      .where((h) => h.name == user.name && h.age == user.age)
      .toList()
      .reversed
      .toList();
});