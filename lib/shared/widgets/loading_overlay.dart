import 'package:clearskin_ai/core/config.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, this.message = 'Analyzing...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorScheme.surface.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60.w,
              height: 60.h,
              child: CircularProgressIndicator(
                strokeWidth: 5.w,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colorScheme.primary,
                ),
              ),
            ),
            Text(
              message,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            // 8.heightBox,
            SizedBox(height: 8.h),
            Text(
              'Please wait...',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
