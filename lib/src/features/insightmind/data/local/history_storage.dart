// lib/src/features/insightmind/data/local/history_storage.dart
import 'package:hive/hive.dart';
import '../../domain/entities/screening_history.dart';

class HistoryStorage {
  static const String boxName = 'screening_history';

  Future<Box<ScreeningHistory>> _getBox() async {
    return await Hive.openBox<ScreeningHistory>(boxName);
  }

  Future<void> saveHistory(ScreeningHistory history) async {
    final box = await _getBox();
    await box.add(history);
  }

  Future<List<ScreeningHistory>> getAllHistory() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> clearHistory() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<ScreeningHistory?> getLatestHistory() async {
    final histories = await getAllHistory();
    if (histories.isEmpty) return null;
    histories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return histories.first;
  }

  Future<bool> hasHistory() async {
    final box = await _getBox();
    return box.isNotEmpty;
  }

  Future<int> getHistoryCount() async {
    final box = await _getBox();
    return box.length;
  }
}