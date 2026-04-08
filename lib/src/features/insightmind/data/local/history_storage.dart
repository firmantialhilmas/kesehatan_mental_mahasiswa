// lib/src/features/insightmind/data/local/history_storage.dart
import 'package:hive/hive.dart';
import '../../domain/entities/screening_history.dart';

class HistoryStorage {
  static const String boxName = 'screening_history';

  bool _hasSaved = false; // ⬅️ TAMBAHAN INI

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

  Future<void> clearHistoryForUser(String name, int age) async {
    final box = await _getBox();
    final toDelete =
        box.values.where((h) => h.name == name && h.age == age).toList();
    for (final h in toDelete) {
      await h.delete();
    }
  }

  Future<void> saveHistoryOnce(ScreeningHistory history) async {
    if (_hasSaved) return;
    _hasSaved = true;
    await saveHistory(history);
  }

  void resetSaveFlag() {
    _hasSaved = false;
  }
}
