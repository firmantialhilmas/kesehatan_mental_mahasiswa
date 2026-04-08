// lib/src/features/insightmind/domain/entities/screening_history.dart
import 'package:hive/hive.dart';

part 'screening_history.g.dart'; // Pastikan nama file sama

@HiveType(typeId: 0)
class ScreeningHistory extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final String riskLevel;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final int age;

  ScreeningHistory({
    required this.date,
    required this.score,
    required this.riskLevel,
    required this.name,
    required this.age,
  });
}