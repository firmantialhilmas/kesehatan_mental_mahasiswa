// lib/src/features/insightmind/providers/ppg_provider.dart
import 'dart:math'; // WAJIB IMPORT INI UNTUK pow()
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

class PpgFeatures {
  final double mean;
  final double variance;
  final List<double> samples;
  final bool capturing;

  const PpgFeatures({
    required this.mean,
    required this.variance,
    required this.samples,
    required this.capturing,
  });

  PpgFeatures copyWith({
    double? mean,
    double? variance,
    List<double>? samples,
    bool? capturing,
  }) {
    return PpgFeatures(
      mean: mean ?? this.mean,
      variance: variance ?? this.variance,
      samples: samples ?? this.samples,
      capturing: capturing ?? this.capturing,
    );
  }
}

class PpgNotifier extends StateNotifier<PpgFeatures> {
  PpgNotifier() : super(const PpgFeatures(mean: 0, variance: 0, samples: [], capturing: false));

  CameraController? _controller;

  Future<void> startCapture() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras.first, ResolutionPreset.low);
    await _controller!.initialize();
    await _controller!.startImageStream(_processImage);

    state = state.copyWith(capturing: true);
  }

  Future<void> stopCapture() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
    state = state.copyWith(capturing: false);
  }

  void _processImage(CameraImage image) {
    final yPlane = image.planes[0];
    final bytes = yPlane.bytes;
    final sum = bytes.reduce((a, b) => a + b);
    final luminance = sum / bytes.length;

    // Buffer 50 sample terakhir
    final newSamples = [...state.samples, luminance];
    if (newSamples.length > 50) {
      newSamples.removeRange(0, newSamples.length - 50);
    }

    // Hitung mean & variance
    final mean = newSamples.isEmpty ? 0.0 : newSamples.reduce((a, b) => a + b) / newSamples.length;

    final variance = newSamples.isEmpty
        ? 0.0
        : newSamples.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / newSamples.length;

    state = state.copyWith(mean: mean, variance: variance, samples: newSamples);
  }
}

final ppgProvider = StateNotifierProvider<PpgNotifier, PpgFeatures>((ref) => PpgNotifier());