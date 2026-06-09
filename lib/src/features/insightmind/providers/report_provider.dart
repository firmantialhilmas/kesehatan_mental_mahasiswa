import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

import '../domain/entities/screening_history.dart';
import '../domain/usecases/report_generator.dart';

final reportGeneratorProvider = Provider<ReportGenerator>(
  (ref) => ReportGenerator(),
);

Future<void> generateAndShowPdf({
  required WidgetRef ref,
  required String username,
  required List<ScreeningHistory> history,
  required BuildContext context,
}) async {
  try {
    // GENERATE FILE PDF
    final file = await ReportGenerator.generateReport(
      username: username,
      history: history,
    );

    // ===== WEB =====
    if (kIsWeb) {
      final pdfBytes = await file.readAsBytes();

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'InsightMind_Report.pdf',
      );
    } else {
      // ===== ANDROID / IOS =====
      await OpenFile.open(file.path);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF berhasil dibuat'),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generate PDF: $e'),
        ),
      );
    }
  }
}