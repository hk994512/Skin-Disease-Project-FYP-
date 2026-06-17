// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/models/scan_result.dart';

/// Standalone PDF report generation service.
/// Encapsulates all `pw.*` (pdf/widgets) usage so no other file needs that import.
class PdfReportService {
  PdfReportService._();
  static final instance = PdfReportService._();

  // ─── Public API ────────────────────────────────────────────────
  Future<void> generateAndOpen(ScanResult s) async {
    final path = await _build(s);
    await OpenFile.open(path);
  }

  // ─── Colours ──────────────────────────────────────────────────
  static const _green = PdfColor.fromInt(0xFF2D6A4F);
  static const _grey = PdfColor.fromInt(0xFF757575);
  static const _lightBg = PdfColor.fromInt(0xFFF5F5F5);

  static PdfColor _riskColor(String risk) {
    switch (risk) {
      case 'Critical':
        return const PdfColor.fromInt(0xFFAA0000);
      case 'High':
        return const PdfColor.fromInt(0xFFFF4444);
      case 'Medium':
        return const PdfColor.fromInt(0xFFFF9800);
      default:
        return _green;
    }
  }

  // ─── Build document ───────────────────────────────────────────
  Future<String> _build(ScanResult s) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM dd, yyyy  hh:mm a').format(now);
    final fileName =
        'ClearSkin_${s.diseaseName.replaceAll(' ', '_')}_'
        '${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';

    pw.MemoryImage? pdfImage;
    final imgFile = File(s.imagePath);
    if (await imgFile.exists()) {
      pdfImage = pw.MemoryImage(await imgFile.readAsBytes());
    }

    final rc = _riskColor(s.riskLevel);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header:
            (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ClearSkin AI',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    pw.Text(
                      'Skin Analysis Report',
                      style: pw.TextStyle(fontSize: 11, color: _grey),
                    ),
                  ],
                ),
                pw.Text(
                  dateStr,
                  style: pw.TextStyle(fontSize: 9, color: _grey),
                ),
                pw.Divider(color: _green, thickness: 1.5),
                pw.SizedBox(height: 4),
              ],
            ),
        footer:
            (ctx) => pw.Column(
              children: [
                pw.Divider(color: _grey, thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ClearSkin AI — For educational use only',
                      style: pw.TextStyle(fontSize: 8, color: _grey),
                    ),
                    pw.Text(
                      'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                      style: pw.TextStyle(fontSize: 8, color: _grey),
                    ),
                  ],
                ),
              ],
            ),
        build:
            (ctx) => [
              // ── Summary card ─────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: rc, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (pdfImage != null) ...[
                      pw.ClipRRect(
                        horizontalRadius: 6,
                        verticalRadius: 6,
                        child: pw.Image(
                          pdfImage,
                          width: 100,
                          height: 100,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: rc,
                                  borderRadius: pw.BorderRadius.circular(20),
                                ),
                                child: pw.Text(
                                  s.riskLevel,
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Text(
                                s.confidencePercent,
                                style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                  color: rc,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            s.diseaseName,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            s.advice,
                            style: pw.TextStyle(fontSize: 10, color: _grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // ── Predictions ──────────────────────────────────
              _section('All Class Probabilities'),
              pw.SizedBox(height: 6),
              ...s.allPredictions.map((p) {
                final isTop =
                    p['code'] ==
                    s.diseaseName.toLowerCase().replaceAll(' ', '_');
                final prob = (p['probability'] as num).toDouble();
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 130,
                        child: pw.Text(
                          p['name'] as String,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: isTop ? _green : _grey,
                            fontWeight:
                                isTop
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Stack(
                          children: [
                            pw.Container(
                              height: 8,
                              decoration: pw.BoxDecoration(
                                color: _lightBg,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                            pw.Container(
                              height: 8,
                              width: 150 * prob.clamp(0.0, 1.0),
                              decoration: pw.BoxDecoration(
                                color: isTop ? _green : _grey,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.SizedBox(
                        width: 36,
                        child: pw.Text(
                          '${(prob * 100).toStringAsFixed(1)}%',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight:
                                isTop
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 20),

              // ── Disease detail ────────────────────────────────
              _section('Disease Information'),
              pw.SizedBox(height: 6),
              if (s.alsoKnownAs.isNotEmpty)
                pw.Text(
                  'Also known as: ${s.alsoKnownAs}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _grey,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              pw.SizedBox(height: 8),
              _block('Description', s.description),
              _block('Appearance', s.appearance),
              _block('Causes', s.causes),
              _listBlock('Symptoms', s.symptoms),
              _listBlock('Treatment Options', s.treatments),
              _listBlock('Prevention', s.prevention),
              _block('When to See a Doctor', s.whenToSeeDoctor),
              _block('Prognosis', s.prognosis),
              _block('Affected Population', s.affectedPopulation),
              pw.SizedBox(height: 20),

              // ── Disclaimer ────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: _lightBg,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'DISCLAIMER: This report is generated by an AI model for '
                  'educational purposes only. It is NOT a substitute for '
                  'professional medical advice, diagnosis, or treatment. '
                  'Always consult a qualified dermatologist.',
                  style: pw.TextStyle(fontSize: 8, color: _grey),
                ),
              ),
            ],
      ),
    );

    final dir =
        Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // ─── PDF helpers ──────────────────────────────────────────────
  pw.Widget _section(String title) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: pw.BoxDecoration(
      color: _green,
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
    ),
  );

  pw.Widget _block(String title, String content) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          content,
          style: pw.TextStyle(fontSize: 9, color: _grey, lineSpacing: 2),
        ),
      ],
    ),
  );

  pw.Widget _listBlock(String title, List<String> items) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: pw.TextStyle(fontSize: 9, color: _grey)),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: _grey,
                      lineSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
