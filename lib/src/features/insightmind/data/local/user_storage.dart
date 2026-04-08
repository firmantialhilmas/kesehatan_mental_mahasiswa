// lib/src/features/insightmind/data/local/user_storage.dart
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

class UserStorage {
  static const String boxName = 'user_profile';

  Future<Box<User>> _getBox() async {
    return await Hive.openBox<User>(boxName);
  }

  /// Save user profile to local storage
  Future<void> saveUser(User user) async {
    final box = await _getBox();
    // Always save at key 'current_user' to maintain single user profile
    await box.put('current_user', user);
  }

  /// Load user profile from local storage
  /// Returns null if no user data exists
  Future<User?> loadUser() async {
    final box = await _getBox();
    return box.get('current_user');
  }

  /// Clear user profile from local storage
  /// Use this for permanent logout or data reset
  Future<void> clearUser() async {
    final box = await _getBox();
    await box.delete('current_user');
  }

  /// Check if user data exists in storage
  Future<bool> hasUser() async {
    final box = await _getBox();
    return box.containsKey('current_user');
  }
}
