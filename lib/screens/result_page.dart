import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../global/config.dart';

class ResultPage extends StatefulWidget {
  final ScanResult scanResult;
  const ResultPage({super.key, required this.scanResult});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSavingPdf = false;
  bool _pdfSaved = false;

  Color _riskColor(BuildContext context) {
    switch (widget.scanResult.riskLevel) {
      case 'Critical':
        return context.colorScheme.error;
      case 'High':
        return context.colorScheme.tertiary;
      case 'Medium':
        return const Color(0xFFFF9800);
      default:
        return context.colorScheme.secondary;
    }
  }

  Future<void> _savePdf() async {
    setState(() => _isSavingPdf = true);
    try {
      final path = await _generatePdf();
      await OpenFile.open(path);
      if (!mounted) return;
      setState(() => _pdfSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF saved to Downloads'),
          backgroundColor: context.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: context.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingPdf = false);
    }
  }

  Future<String> _generatePdf() async {
    final s = widget.scanResult;
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM dd, yyyy  hh:mm a').format(now);
    final fileName =
        'ClearSkin_${s.diseaseName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';

    pw.MemoryImage? pdfImage;
    final imgFile = File(s.imagePath);
    if (await imgFile.exists()) {
      pdfImage = pw.MemoryImage(await imgFile.readAsBytes());
    }

    const green = PdfColor.fromInt(0xFF2D6A4F);
    const grey = PdfColor.fromInt(0xFF757575);
    const lightBg = PdfColor.fromInt(0xFFF5F5F5);

    PdfColor riskPdf() {
      switch (s.riskLevel) {
        case 'Critical':
          return const PdfColor.fromInt(0xFFAA0000);
        case 'High':
          return const PdfColor.fromInt(0xFFFF4444);
        case 'Medium':
          return const PdfColor.fromInt(0xFFFF9800);
        default:
          return green;
      }
    }

    final rc = riskPdf();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
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
                    color: green,
                  ),
                ),
                pw.Text(
                  'Skin Analysis Report',
                  style: pw.TextStyle(fontSize: 11, color: grey),
                ),
              ],
            ),
            pw.Text(dateStr, style: pw.TextStyle(fontSize: 9, color: grey)),
            pw.Divider(color: green, thickness: 1.5),
            pw.SizedBox(height: 4),
          ],
        ),
        footer: (ctx) => pw.Column(
          children: [
            pw.Divider(color: grey, thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'ClearSkin AI — For educational use only',
                  style: pw.TextStyle(fontSize: 8, color: grey),
                ),
                pw.Text(
                  'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: pw.TextStyle(fontSize: 8, color: grey),
                ),
              ],
            ),
          ],
        ),
        build: (ctx) => [
          // Summary box
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
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
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
                        style: pw.TextStyle(fontSize: 10, color: grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // All predictions
          _pdfSection('All Class Probabilities', green),
          pw.SizedBox(height: 6),
          ...s.allPredictions.map((p) {
            final isTop =
                p['code'] == s.diseaseName.toLowerCase().replaceAll(' ', '_');
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
                        color: isTop ? green : grey,
                        fontWeight: isTop
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
                            color: lightBg,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                        pw.Container(
                          height: 8,
                          width: 150 * prob.clamp(0.0, 1.0),
                          decoration: pw.BoxDecoration(
                            color: isTop ? green : grey,
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
                        fontWeight: isTop
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
          // Disease detail
          _pdfSection('Disease Information', green),
          pw.SizedBox(height: 6),
          if (s.alsoKnownAs.isNotEmpty)
            pw.Text(
              'Also known as: ${s.alsoKnownAs}',
              style: pw.TextStyle(
                fontSize: 9,
                color: grey,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          pw.SizedBox(height: 8),
          _pdfBlock('Description', s.description, grey),
          _pdfBlock('Appearance', s.appearance, grey),
          _pdfBlock('Causes', s.causes, grey),
          _pdfListBlock('Symptoms', s.symptoms, grey),
          _pdfListBlock('Treatment Options', s.treatments, grey),
          _pdfListBlock('Prevention', s.prevention, grey),
          _pdfBlock('When to See a Doctor', s.whenToSeeDoctor, grey),
          _pdfBlock('Prognosis', s.prognosis, grey),
          _pdfBlock('Affected Population', s.affectedPopulation, grey),
          pw.SizedBox(height: 20),

          // Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'DISCLAIMER: This report is generated by an AI model for educational purposes only. It is NOT a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified dermatologist.',
              style: pw.TextStyle(fontSize: 8, color: grey),
            ),
          ),
        ],
      ),
    );

    final dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _pdfSection(String title, PdfColor color) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: pw.BoxDecoration(
      color: color,
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

  pw.Widget _pdfBlock(String title, String content, PdfColor grey) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              content,
              style: pw.TextStyle(fontSize: 9, color: grey, lineSpacing: 2),
            ),
          ],
        ),
      );

  pw.Widget _pdfListBlock(String title, List<String> items, PdfColor grey) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            ...items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '• ',
                      style: pw.TextStyle(fontSize: 9, color: grey),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        item,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: grey,
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

  @override
  Widget build(BuildContext context) {
    final s = widget.scanResult;
    final loc = context.locale;
    final rc = _riskColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.anaRes),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.go('/homeScreen'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scanned image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: File(s.imagePath).existsSync()
                      ? Image.file(
                          File(s.imagePath),
                          height: 200.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200.h,
                          color: context.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                            size: 60.r,
                          ),
                        ),
                ),

                SizedBox(height: 32.h),
                Center(child: ConfidenceMeter(confidence: s.confidence)),
                SizedBox(height: 32.h),

                // Detected condition card
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medical_information_outlined,
                            color: context.colorScheme.primary,
                            size: 28.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Detected Condition',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: rc,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.riskLevel,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        s.diseaseName,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (s.alsoKnownAs.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Also known as: ${s.alsoKnownAs}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Text(
                        s.advice,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: rc,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Description
                _sectionTitle(context, 'Description'),
                SizedBox(height: 8.h),
                Text(
                  s.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 20.h),

                // Appearance
                if (s.appearance.isNotEmpty) ...[
                  _sectionTitle(context, '👁️ Appearance'),
                  SizedBox(height: 8.h),
                  Text(
                    s.appearance,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Causes
                if (s.causes.isNotEmpty) ...[
                  _sectionTitle(context, '🔬 Causes'),
                  SizedBox(height: 8.h),
                  Text(
                    s.causes,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Symptoms
                _sectionTitle(context, 'Common Symptoms'),
                SizedBox(height: 12.h),
                ...s.symptoms.map(
                  (symptom) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 6.h),
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            symptom,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Treatments
                _sectionTitle(context, 'Recommended Treatments'),
                SizedBox(height: 12.h),
                ...s.treatments.asMap().entries.map(
                  (entry) =>
                      TreatmentCard(treatment: entry.value, index: entry.key),
                ),

                SizedBox(height: 20.h),

                // Prevention
                if (s.prevention.isNotEmpty) ...[
                  _sectionTitle(context, '🛡️ Prevention'),
                  SizedBox(height: 12.h),
                  ...s.prevention.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: context.colorScheme.secondary,
                            size: 16.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              item,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // When to see doctor
                if (s.whenToSeeDoctor.isNotEmpty) ...[
                  _sectionTitle(context, '🏥 When to See a Doctor'),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: context.colorScheme.errorContainer.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      s.whenToSeeDoctor,
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Prognosis
                if (s.prognosis.isNotEmpty) ...[
                  _sectionTitle(context, '📈 Prognosis'),
                  SizedBox(height: 8.h),
                  Text(
                    s.prognosis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Affected population
                if (s.affectedPopulation.isNotEmpty) ...[
                  _sectionTitle(context, '👥 Affected Population'),
                  SizedBox(height: 8.h),
                  Text(
                    s.affectedPopulation,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // All predictions bar chart
                if (s.allPredictions.isNotEmpty) ...[
                  _sectionTitle(context, 'All Class Probabilities'),
                  SizedBox(height: 12.h),
                  ...s.allPredictions.map((p) {
                    final prob = (p['probability'] as num).toDouble();
                    final isTop = p['name'] == s.diseaseName;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130.w,
                            child: Text(
                              p['name'] as String,
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: isTop
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isTop
                                    ? context.colorScheme.primary
                                    : context.colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: prob,
                                backgroundColor:
                                    context.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(
                                  isTop
                                      ? context.colorScheme.primary
                                      : context.colorScheme.onSurface
                                            .withValues(alpha: 0.3),
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 42.w,
                            child: Text(
                              '${(prob * 100).toStringAsFixed(1)}%',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: isTop
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                ],

                // Learn more button
                OutlinedButton.icon(
                  onPressed: () => GoRouterHelper(
                    context,
                  ).pushNamed('scanResult', extra: s.diseaseName),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Learn More About This Condition'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colorScheme.primary,
                    side: BorderSide(color: context.colorScheme.primary),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Save PDF button
                ElevatedButton.icon(
                  onPressed: _isSavingPdf ? null : _savePdf,
                  icon: _isSavingPdf
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          _pdfSaved
                              ? Icons.check_circle_outline
                              : Icons.picture_as_pdf,
                          size: 20.r,
                        ),
                  label: Text(
                    _isSavingPdf
                        ? 'Saving...'
                        : _pdfSaved
                        ? 'Saved! Open Again'
                        : 'Save Result as PDF',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pdfSaved
                        ? context.colorScheme.secondary
                        : context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Disclaimer
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: context.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: context.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: context.colorScheme.error,
                        size: 24.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'This is an AI-generated result. Please consult a dermatologist for professional diagnosis and treatment.',
                          style: context.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
  );
}
