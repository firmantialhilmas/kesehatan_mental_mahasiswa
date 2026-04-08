// lib/src/features/insightmind/providers/report_provider.dart
import 'dart:io'; // Untuk HP
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import '../domain/usecases/report_generator.dart';
import '../domain/entities/screening_history.dart';

final reportGeneratorProvider = Provider((ref) => ReportGenerator());

Future<void> generateAndShowPdf({
  required WidgetRef ref,
  required String username,
  required List<ScreeningHistory> history,
  required BuildContext context,
}) async {
  try {
    final generator = ref.read(reportGeneratorProvider);
    final pdfBytes = await generator.generateReport(username: username, history: history);

    if (kIsWeb) {
      // WEB: Gunakan Printing.layoutPdf (preview di browser)
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'InsightMind_Report_$username.pdf',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF dibuka di browser!')),
      );
    } else {
      // HP (Android/iOS): Save ke file & buka
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/InsightMind_Report_$username.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal buka PDF: ${result.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF berhasil dibuka di HP!')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generate PDF: $e')),
    );
  }
}