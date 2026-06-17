import 'package:clearskin_ai/core/config.dart';


class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _imagePicker = ImagePicker();
  final _analysisService = SkinAnalysisService.instance;
  File? _selectedImage;
  bool _isAnalyzing = false;
  final _utils = APPUTILS.instance;

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      // imageQuality: 100,
    );
    if (pickedFile != null && mounted) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      // imageQuality: 100,
    );
    if (pickedFile != null && mounted) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null || !mounted) return;

    setState(() => _isAnalyzing = true);

    try {
      // ✅ Pass context so snackbar shows which source was used
      final result = await _analysisService.analyzeSkinImage(_selectedImage!);

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      context.go('/resPage', extra: result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      _utils.appSnackBar(context, 'Analysis failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        text: context.locale.scanSkin,
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: .all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.locale.uploadCapturePic,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    8.heightBox,
                    Text(
                      context.locale.effectedAreaPic,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    if (_selectedImage != null)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: .circular(20.r),
                            child: Image.file(
                              _selectedImage!,
                              height: 300.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _selectedImage = null),
                            icon: const Icon(Icons.close),
                            label: Text(context.locale.removeImage),
                            style: TextButton.styleFrom(
                              foregroundColor: context.colorScheme.error,
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 300.h,
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: .all(
                            color: context.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                            width: 2.w,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 80.r,
                              color: context.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              context.locale.noImage,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorScheme.primary,
                              foregroundColor: context.colorScheme.onPrimary,
                              padding: .symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: .circular(16.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorScheme.secondary,
                              foregroundColor: context.colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: .circular(16.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    if (_selectedImage != null)
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.primaryContainer,
                          foregroundColor:
                              context.colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 24.r),
                            SizedBox(width: 12.w),
                            Text(
                              context.locale.analyze,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 24.h),
                    Container(
                      padding: .all(16.r),
                      decoration: BoxDecoration(
                        color: context.colorScheme.tertiaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: .circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: context.colorScheme.tertiary,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                context.locale.tips,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _TipItem(text: context.locale.goodLight),
                          _TipItem(text: context.locale.focusClearly),
                          _TipItem(text: context.locale.avoidShadows),
                          _TipItem(text: context.locale.steadyCam),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isAnalyzing)
            const LoadingOverlay(message: 'Analyzing skin condition'),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: context.colorScheme.secondary,
            size: 16,
          ),
          8.widthBox,
          Expanded(child: Text(text, style: context.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
