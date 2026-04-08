// lib/src/features/insightmind/domain/usecases/report_generator.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/screening_history.dart'; // Pastikan path benar

class ReportGenerator {
  Future<Uint8List> generateReport({
    required String username,
    required List<ScreeningHistory> history,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text('InsightMind Mental Health Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('Nama Pengguna: $username'),
          pw.Text('Tanggal Laporan: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}'),
          pw.SizedBox(height: 30),
          pw.Text('Riwayat Screening',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Tanggal', 'Skor', 'Risiko'],
            data: history.map((h) => [
                  DateFormat('dd/MM/yyyy').format(h.date),
                  h.score.toString(),
                  h.riskLevel,
                ]).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Catatan: Laporan ini bersifat edukatif dan bukan diagnosis medis resmi.',
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic), // BENAR: pw.FontStyle.italic
          ),
        ],
      ),
    );

    return pdf.save();
  }
}