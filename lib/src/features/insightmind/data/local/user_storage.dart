// lib/src/features/insightmind/data/local/user_storage.dart
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

class UserStorage {
  static const String boxName = 'user_profile';

  Future<Box<User>> _getBox() async {
    return await Hive.openBox<User>(boxName);
  }

  Future<void> saveUser(User user) async {
    final box = await _getBox();
    await box.put('current_user', user);
  }

  Future<User?> loadUser() async {
    final box = await _getBox();
    return box.get('current_user');
  }

  Future<void> clearUser() async {
    final box = await _getBox();
    await box.delete('current_user');
  }

  Future<bool> hasUser() async {
    final box = await _getBox();
    return box.containsKey('current_user');
  }
}