// lib/src/features/insightmind/providers/sensors_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class AccelFeatures {
  final double mean;
  final double variance;

  const AccelFeatures({required this.mean, required this.variance});
}

final accelFeatureProvider = StreamProvider<AccelFeatures>((ref) async* {
  final buffer = <double>[];
  const windowSize = 50;

  await for (final event in accelerometerEvents) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    buffer.add(magnitude);
    if (buffer.length > windowSize) buffer.removeAt(0);

    if (buffer.length == windowSize) {
      final mean = buffer.reduce((a, b) => a + b) / windowSize;
      final variance = buffer.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / windowSize;
      yield AccelFeatures(mean: mean, variance: variance);
    }
  }
});