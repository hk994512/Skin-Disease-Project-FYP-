import 'package:clearskin_ai/core/config.dart';

class DiseaseDetailPage extends StatefulWidget {
  final String diseaseName;

  const DiseaseDetailPage({super.key, required this.diseaseName});

  @override
  State<DiseaseDetailPage> createState() => _DiseaseDetailPageState();
}

class _DiseaseDetailPageState extends State<DiseaseDetailPage> {
  final _diseaseService = DiseaseInfoService.instance;
  DiseaseInfo? _diseaseInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiseaseInfo();
  }

  Future<void> _loadDiseaseInfo() async {
    setState(() => _isLoading = true);
    final info = await _diseaseService.getDiseaseInfo(widget.diseaseName);
    setState(() {
      _diseaseInfo = info;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Information'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.colorScheme.primary,
              ),
            )
          : _diseaseInfo == null
          ? Center(
              child: Padding(
                padding: .all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80.r,
                      color: context.colorScheme.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Information Not Available',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'We couldn\'t find detailed information for this condition.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: .center,
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: .all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: .all(20.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colorScheme.primary,
                              context.colorScheme.primary.withValues(
                                alpha: 0.7,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: .circular(20.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medical_information,
                              color: context.colorScheme.onPrimary,
                              size: 40.r,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              _diseaseInfo!.name,
                              style: context.textTheme.headlineSmall?.copyWith(
                                color: context.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _InfoSection(
                        title: 'Overview',
                        icon: Icons.description_outlined,
                        color: context.colorScheme.primary,
                        child: Text(
                          _diseaseInfo!.description,
                          style: context.textTheme.bodyMedium?.copyWith(
                            height: 1.5.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _InfoSection(
                        title: 'Symptoms',
                        icon: Icons.healing_outlined,
                        color: context.colorScheme.secondary,
                        child: Column(
                          children: _diseaseInfo!.symptoms
                              .map((symptom) => _ListItem(text: symptom))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _InfoSection(
                        title: 'Causes',
                        icon: Icons.psychology_outlined,
                        color: context.colorScheme.tertiary,
                        child: Column(
                          children: _diseaseInfo!.causes
                              .map((cause) => _ListItem(text: cause))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _InfoSection(
                        title: 'Treatments',
                        icon: Icons.medication_outlined,
                        color: context.colorScheme.primary,
                        child: Column(
                          children: _diseaseInfo!.treatments
                              .map((treatment) => _ListItem(text: treatment))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _InfoSection(
                        title: 'Prevention',
                        icon: Icons.shield_outlined,
                        color: context.colorScheme.secondary,
                        child: Column(
                          children: _diseaseInfo!.prevention
                              .map((tip) => _ListItem(text: tip))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        padding: .all(16.r),
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: .circular(12.r),
                          border: .all(
                            color: context.colorScheme.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: context.colorScheme.secondary,
                              size: 24.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Always consult with a healthcare professional for accurate diagnosis and personalized treatment plans.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  height: 1.4.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(width: 8.w),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        12.heightBox,
        child,
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final String text;

  const _ListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: .only(top: 6.h),
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: .circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
