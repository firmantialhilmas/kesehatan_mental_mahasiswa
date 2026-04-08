import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../providers/sensors_provider.dart';
import '../../providers/ppg_provider.dart';

class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  XFile? _capturedImage;

  // ===== TAMBAHAN ANALISIS =====
  double? _stressScore;
  String? _mentalStatus;
  // ============================

  // Variabel Tema
  final Color _deepDarkBrown = const Color(0xFF2D1B14);
  final Color _primaryBrown = const Color(0xFF634832);
  final Color _accentPink = const Color(0xFFE07A5F);
  final Color _creamHighlight = const Color(0xFFF4F1DE);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  // FOTO
  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      setState(() => _capturedImage = image);
    } catch (_) {}
  }

  // ===== FUNGSI ANALISIS MENTAL =====
  void _analyzeMental(double ppgVar, double accelVar) {
    final score = (ppgVar * 0.6) + (accelVar * 0.4);

    String status;
    if (score < 0.2) {
      status = 'Tenang';
    } else if (score < 0.5) {
      status = 'Cemas Ringan';
    } else {
      status = 'Stres';
    }

    setState(() {
      _stressScore = score;
      _mentalStatus = status;
    });
  }
  // =================================

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ppg = ref.watch(ppgProvider);
    final accel = ref.watch(accelFeatureProvider);

    return Scaffold(
      backgroundColor: _creamHighlight,
      appBar: AppBar(
        title: const Text('Sensor & Biometrik'),
        backgroundColor: _deepDarkBrown,
        foregroundColor: _creamHighlight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CAMERA
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _deepDarkBrown, width: 3),
              ),
              clipBehavior: Clip.hardEdge,
              child: _controller != null &&
                      _controller!.value.isInitialized
                  ? CameraPreview(_controller!)
                  : const Center(child: CircularProgressIndicator()),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
            onPressed: _capturePhoto,
            style: FilledButton.styleFrom(
              backgroundColor: _accentPink,
              foregroundColor: _creamHighlight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text(
              'Ambil Foto',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),


            if (_capturedImage != null) ...[
              const SizedBox(height: 16),
              Image.file(File(_capturedImage!.path), height: 200),
            ],

            const SizedBox(height: 24),

            // PPG
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(ppg.capturing ? 'PPG Aktif' : 'PPG Siap'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDataTile(
                            'Mean', ppg.mean.toStringAsFixed(4)),
                        _buildDataTile(
                            'Variance', ppg.variance.toStringAsFixed(4)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
  onPressed: () {
    if (ppg.capturing) {
      ref.read(ppgProvider.notifier).stopCapture();

      _analyzeMental(
        ppg.variance,
        accel.asData?.value.variance ?? 0.0,
      );
    } else {
      ref.read(ppgProvider.notifier).startCapture();
    }
  },
  style: FilledButton.styleFrom(
    backgroundColor:
        ppg.capturing ? _deepDarkBrown : _accentPink,
    foregroundColor: _creamHighlight,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: Text(
    ppg.capturing ? 'Stop PPG' : 'Mulai PPG',
    style: const TextStyle(fontWeight: FontWeight.w600),
  ),
),

                  ],
                ),
              ),
            ),

            // ===== HASIL ANALISIS =====
            if (_stressScore != null && _mentalStatus != null) ...[
              const SizedBox(height: 16),
              Card(
                color: _primaryBrown,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Hasil Analisis Mental',
                          style: TextStyle(
                              color: _creamHighlight,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_mentalStatus!,
                          style: TextStyle(
                              fontSize: 22,
                              color: _accentPink,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'Skor Stres: ${( _stressScore! * 100 ).toStringAsFixed(1)}%',
                        style: TextStyle(color: _creamHighlight),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // ==========================

            const SizedBox(height: 16),

            // ACCEL
            Card(
              color: _deepDarkBrown,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: accel.when(
                  data: (f) => Column(
                    children: [
                      _buildAccelRow(
                          'Mean', f.mean.toStringAsFixed(4)),
                      _buildAccelRow(
                          'Variance', f.variance.toStringAsFixed(4)),
                    ],
                  ),
                  loading: () =>
                      const LinearProgressIndicator(),
                  error: (_, __) =>
                      const Text('Error accelerometer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTile(String title, String value) {
    return Column(
      children: [
        Text(title),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAccelRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(color: _creamHighlight.withOpacity(0.8))),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
