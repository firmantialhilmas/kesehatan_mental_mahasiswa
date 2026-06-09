import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../entities/screening_history.dart';

class ReportGenerator {
  // =========================
  // CACHE FONT (BIAR CEPAT)
  // =========================
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<File> generateReport({
    required String username,
    required List<ScreeningHistory> history,
  }) async {
    final pdf = pw.Document();

    // ===== FONT (CACHE) =====
    _regularFont ??= await PdfGoogleFonts.nunitoRegular();
    _boldFont ??= await PdfGoogleFonts.nunitoBold();

    final regularFont = _regularFont!;
    final boldFont = _boldFont!;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),

        build: (context) => [
          // ===== TITLE =====
          pw.Text(
            'InsightMind - Laporan Kesehatan Mental',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 22,
            ),
          ),

          pw.SizedBox(height: 12),

          // ===== USER =====
          pw.Text(
            'Nama: $username',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 12,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            'Tanggal Cetak: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 12,
            ),
          ),

          pw.SizedBox(height: 12),

          pw.Divider(),

          pw.SizedBox(height: 12),

          // ===== SUBTITLE =====
          pw.Text(
            'Riwayat Screening & Klasifikasi',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
            ),
          ),

          pw.SizedBox(height: 10),

          // ===== TABLE =====
          pw.Table.fromTextArray(
            headers: const [
              'Tanggal',
              'Skor',
              'Kategori',
              'Confidence',
            ],

            headerStyle: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),

            cellStyle: pw.TextStyle(
              font: regularFont,
              fontSize: 11,
            ),

            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),

            cellAlignment: pw.Alignment.centerLeft,

            data: history.map((h) {
              return [
                DateFormat('dd/MM/yyyy').format(h.timestamp),
                h.score.toString(),
                h.displayCategory,
                h.probability != null
                    ? '${(h.probability! * 100).toStringAsFixed(1)}%'
                    : '-',
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          // ===== NOTE =====
          pw.Text(
            'Catatan: Laporan ini bersifat edukatif dan bukan diagnosis medis resmi.',
            style: pw.TextStyle(
              font: regularFont,
              fontStyle: pw.FontStyle.italic,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    // =========================
    // SAVE FILE
    // =========================

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/laporan_screening.pdf';
    final file = File(filePath);

    final pdfBytes = await pdf.save();

    await file.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    // =========================
    // DEBUG (AMAN)
    // =========================
    print('PDF PATH: ${file.path}');
    print('PDF EXISTS: ${await file.exists()}');
    print('PDF SIZE: ${pdfBytes.length} bytes');

    return file;
  }
}