// lib/src/features/insightmind/data/local/screening_status_storage.dart
import 'package:hive/hive.dart';

class ScreeningStatusStorage {
  static const String boxName = 'screening_status';
  static const String keyCompleted = 'has_completed';

  Future<Box> _getBox() async {
    return await Hive.openBox(boxName);
  }

  /// Simpan status: sudah/belum screening
  Future<void> saveCompleted(bool completed) async {
    final box = await _getBox();
    await box.put(keyCompleted, completed);
  }

  /// Load status dari storage
  Future<bool> hasCompletedScreening() async {
    final box = await _getBox();
    return box.get(keyCompleted, defaultValue: false) as bool;
  }

  /// Clear status (untuk logout/reset)
  Future<void> clearStatus() async {
    final box = await _getBox();
    await box.delete(keyCompleted);
  }
}