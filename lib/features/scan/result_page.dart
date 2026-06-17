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

  Future<void> _savePdf() async {
    setState(() => _isSavingPdf = true);
    try {
      await PdfReportService.instance.generateAndOpen(widget.scanResult);
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
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                            size: 60.r,
                          ),
                        ),
                ),

                SizedBox(height: 32.h),
                Center(child: ConfidenceMeter(confidence: s.confidence)),
                SizedBox(height: 32.h),

                // ── Detected condition card ─────────────────────────
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          context.colorScheme.primary.withValues(alpha: 0.3),
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
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
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

                // ── Description ────────────────────────────────────
                _sectionTitle(context, 'Description'),
                SizedBox(height: 8.h),
                Text(
                  s.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color:
                        context.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Appearance ─────────────────────────────────────
                if (s.appearance.isNotEmpty) ...[
                  _sectionTitle(context, '👁️ Appearance'),
                  SizedBox(height: 8.h),
                  Text(
                    s.appearance,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── Causes ─────────────────────────────────────────
                if (s.causes.isNotEmpty) ...[
                  _sectionTitle(context, '🔬 Causes'),
                  SizedBox(height: 8.h),
                  Text(
                    s.causes,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── Symptoms ───────────────────────────────────────
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

                // ── Treatments ─────────────────────────────────────
                _sectionTitle(context, 'Recommended Treatments'),
                SizedBox(height: 12.h),
                ...s.treatments.asMap().entries.map(
                      (entry) => TreatmentCard(
                        treatment: entry.value,
                        index: entry.key,
                      ),
                    ),

                SizedBox(height: 20.h),

                // ── Prevention ─────────────────────────────────────
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

                // ── When to see a doctor ───────────────────────────
                if (s.whenToSeeDoctor.isNotEmpty) ...[
                  _sectionTitle(context, '🏥 When to See a Doctor'),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: context.colorScheme.errorContainer
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            context.colorScheme.error.withValues(alpha: 0.3),
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

                // ── Prognosis ──────────────────────────────────────
                if (s.prognosis.isNotEmpty) ...[
                  _sectionTitle(context, '📈 Prognosis'),
                  SizedBox(height: 8.h),
                  Text(
                    s.prognosis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── Affected population ────────────────────────────
                if (s.affectedPopulation.isNotEmpty) ...[
                  _sectionTitle(context, '👥 Affected Population'),
                  SizedBox(height: 8.h),
                  Text(
                    s.affectedPopulation,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── All predictions bar chart ───────────────────────
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
                                    : context.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
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
                                backgroundColor: context
                                    .colorScheme.surfaceContainerHighest,
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

                // ── Learn more ─────────────────────────────────────
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

                // ── Save PDF ───────────────────────────────────────
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

                // ── Disclaimer ─────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: context.colorScheme.errorContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                          context.colorScheme.error.withValues(alpha: 0.3),
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
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
        title,
        style: context.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}
