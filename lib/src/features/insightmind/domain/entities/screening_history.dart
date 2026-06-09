// lib/src/features/insightmind/domain/entities/screening_history.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'screening_history.g.dart';

@HiveType(typeId: 2)
class ScreeningHistory extends Equatable {
  @HiveField(0) final int score;
  @HiveField(1) final String name;
  @HiveField(2) final int age;
  @HiveField(3) final DateTime timestamp;
  @HiveField(4) final List<int>? answers;
  
  // ✅ Field baru untuk Naive Bayes
  @HiveField(5) final String? category;
  @HiveField(6) final double? probability;
  @HiveField(7) final Map<String, double>? allProbabilities;

  const ScreeningHistory({
    required this.score,
    required this.name,
    required this.age,
    required this.timestamp,
    this.answers,
    this.category,
    this.probability,
    this.allProbabilities,
  });

  ScreeningHistory copyWith({
    int? score, String? name, int? age, DateTime? timestamp,
    List<int>? answers, String? category, double? probability, Map<String, double>? allProbabilities,
  }) {
    return ScreeningHistory(
      score: score ?? this.score, name: name ?? this.name, age: age ?? this.age,
      timestamp: timestamp ?? this.timestamp, answers: answers ?? this.answers,
      category: category ?? this.category, probability: probability ?? this.probability,
      allProbabilities: allProbabilities ?? this.allProbabilities,
    );
  }

  String get displayCategory {
    if (category == null) return 'Belum Diklasifikasi';
    switch (category) {
      case 'rendah': return 'Risiko Rendah';
      case 'sedang': return 'Risiko Sedang';
      case 'tinggi': return 'Risiko Tinggi';
      default: return 'Tidak Terklasifikasi';
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'rendah': return Colors.green;
      case 'sedang': return Colors.orange;
      case 'tinggi': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [score, name, age, timestamp, answers, category, probability, allProbabilities];
}