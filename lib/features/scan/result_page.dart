import 'package:clearskin_ai/core/config.dart';

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

  // ✅ NEW: Check if result has complete data
  bool _hasCompleteData() {
    final s = widget.scanResult;
    return s.description.isNotEmpty &&
        s.symptoms.isNotEmpty &&
        s.treatments.isNotEmpty &&
        s.appearance.isNotEmpty &&
        s.causes.isNotEmpty;
  }

  // ── Disease → Doctor URL mapping ────────────────────────────
  String _getDoctorUrl(String diseaseName) {
    final name = diseaseName.toLowerCase();
    if (name.contains('melanoma')) {
      return 'https://www.marham.pk/doctors/oncologist';
    } else if (name.contains('vascular')) {
      return 'https://www.marham.pk/doctors/vascular-surgeon';
    }
    // Default → dermatologist
    return 'https://www.marham.pk/doctors/dermatologist';
  }

  // ── Launch Marham doctor page ────────────────────────────────
  Future<void> _consultDoctor(String diseaseName) async {
    final url = Uri.parse(_getDoctorUrl(diseaseName));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open browser.'),
          backgroundColor: context.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _savePdf() async {
    bool permissionGranted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permissionGranted = true;
      } else {
        final status = await Permission.storage.request();
        permissionGranted = status.isGranted;
      }
    } else {
      permissionGranted = true;
    }

    if (!permissionGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Storage permission denied. Please allow it in Settings.',
          ),
          backgroundColor: context.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open Settings',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

    setState(() => _isSavingPdf = true);

    try {
      String savePath;

      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access external storage.');
        }
        savePath = directory.path;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = directory.path;
      }

      debugPrint('✅ Saving PDF to: $savePath');

      await PdfReportService.instance.generateAndOpen(widget.scanResult);

      if (!mounted) return;
      setState(() => _pdfSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ PDF saved successfully!'),
          backgroundColor: context.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stack) {
      debugPrint('❌ PDF ERROR: $e');
      debugPrint('STACK: $stack');
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

  @override
  Widget build(BuildContext context) {
    final s = widget.scanResult;
    final loc = context.locale;
    final rc = _riskColor(context);
    final hasData = _hasCompleteData();



    // ✅ Show minimal view if data is incomplete
    if (!hasData) {
      return _buildMinimalView(context, s, rc, loc);
    }

    // ✅ Show full detailed view
    return _buildDetailedView(context, s, rc, loc);
  }


  // ✅ NEW: Minimal centered view for incomplete data
  Widget _buildMinimalView(
    BuildContext context,
    ScanResult s,
    Color rc,
    dynamic loc,
  ) {
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Scanned image ───────────────────────────────────
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

                  if (s.confidence < 0.65) ...[
                    SizedBox(height: 32.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[800],
                            size: 28.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Low Confidence (${(s.confidence * 100).toInt()}%)',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'The model is not highly certain. If you scanned healthy skin without a lesion, the model is forced to make a guess. Please only scan visible lesions.',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange[900],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 32.h),

                  // ── Confidence Meter ────────────────────────────────
                  Center(
                    child: ConfidenceMeter(
                      confidence: s.confidence,
                      riskLevel: s.riskLevel,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // ── Detected Condition Card ─────────────────────────
                  Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
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
                              size: 32.r,
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
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
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
                        SizedBox(height: 16.h),
                        Text(
                          s.diseaseName,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (s.alsoKnownAs.isNotEmpty) ...[
                          SizedBox(height: 12.h),
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
                        SizedBox(height: 16.h),
                        Text(
                          s.advice,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: rc,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // ── Disclaimer ──────────────────────────────────────
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
                            'This is an AI-generated result. Please consult a '
                            'dermatologist for professional diagnosis and treatment.',
                            style: context.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Save PDF Button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDiseaseChatSheet(context, s),
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('Ask AI'),
        tooltip: 'Learn more about this disease',
      ),
    );
  }

  // ✅ ORIGINAL: Full detailed view
  Widget _buildDetailedView(
    BuildContext context,
    ScanResult s,
    Color rc,
    dynamic loc,
  ) {
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
                // ── Scanned image ───────────────────────────────────
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

                if (s.confidence < 0.65) ...[
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[800],
                          size: 28.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Low Confidence (${(s.confidence * 100).toInt()}%)',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'The model is not highly certain. If you scanned healthy skin without a lesion, the model is forced to make a guess. Please only scan visible lesions.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange[900],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 32.h),

                Center(
                  child: ConfidenceMeter(
                    confidence: s.confidence,
                    riskLevel: s.riskLevel,
                  ),
                ),
                SizedBox(height: 32.h),

                // ── Detected condition card ─────────────────────────
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

                // ── Description ─────────────────────────────────────
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

                // ── Appearance ──────────────────────────────────────
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

                // ── Causes ──────────────────────────────────────────
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

                // ── Symptoms ────────────────────────────────────────
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

                // ── Treatments ──────────────────────────────────────
                _sectionTitle(context, 'Recommended Treatments'),
                SizedBox(height: 12.h),
                ...s.treatments.asMap().entries.map(
                  (entry) =>
                      TreatmentCard(treatment: entry.value, index: entry.key),
                ),

                SizedBox(height: 20.h),

                // ── Prevention ──────────────────────────────────────
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

                // ── When to see a doctor ────────────────────────────
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

                // ── Prognosis ───────────────────────────────────────
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

                // ── Affected population ─────────────────────────────
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

                // ── All predictions bar chart ────────────────────────
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

                // ── Consult with Doctor ─────────────────────────────
                // Marham button
                ElevatedButton.icon(
                  onPressed: () => _consultDoctor(s.diseaseName),
                  icon: const Icon(Icons.local_hospital),
                  label: const Text('Find a Doctor on Marham'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50.h),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),



                SizedBox(height: 12.h),

                // ── Save PDF ────────────────────────────────────────
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

                // ── Disclaimer ──────────────────────────────────────
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
                          'This is an AI-generated result. Please consult a '
                          'dermatologist for professional diagnosis and treatment.',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDiseaseChatSheet(context, s),
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('Ask AI'),
        tooltip: 'Learn more about this disease',
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
  );
}
