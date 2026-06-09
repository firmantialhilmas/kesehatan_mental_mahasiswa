// lib/src/features/insightmind/providers/screening_status_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/screening_status_storage.dart';

/// Provider untuk status: apakah user sudah menyelesaikan screening?
/// State: true = sudah screening, false = belum
final screeningStatusProvider = StateNotifierProvider<ScreeningStatusNotifier, bool>((ref) {
  return ScreeningStatusNotifier();
});

class ScreeningStatusNotifier extends StateNotifier<bool> {
  final _storage = ScreeningStatusStorage();

  ScreeningStatusNotifier() : super(false) {
    _loadStatus(); // Load status saat provider diinisialisasi
  }

  /// Load status dari local storage
  Future<void> _loadStatus() async {
    final hasCompleted = await _storage.hasCompletedScreening();
    state = hasCompleted;
  }

  /// Set status: user sudah menyelesaikan screening
  Future<void> markAsCompleted() async {
    await _storage.saveCompleted(true);
    state = true;
  }

  /// Reset status: untuk screening baru
  Future<void> resetStatus() async {
    await _storage.saveCompleted(false);
    state = false;
  }

  /// Cek apakah sudah screening (untuk validasi cepat)
  bool get isCompleted => state;
}