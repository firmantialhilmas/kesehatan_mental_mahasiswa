import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final int age;
  
  @HiveField(2)
  final String? profilePicturePath;
  
  const User({
    required this.name, 
    required this.age,
    this.profilePicturePath,
  });

  User copyWith({
    String? name,
    int? age,
    String? profilePicturePath,
    bool clearProfilePicture = false,
  }) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
      profilePicturePath: clearProfilePicture ? null : (profilePicturePath ?? this.profilePicturePath),
    );
  }
}