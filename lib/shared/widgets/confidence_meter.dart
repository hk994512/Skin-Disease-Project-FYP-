import 'package:clearskin_ai/core/config.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;
  final double size;

  const ConfidenceMeter({super.key, required this.confidence, this.size = 120});

  Color _getConfidenceColor(BuildContext context) {
    if (confidence >= 0.80) return context.colorScheme.secondary;
    if (confidence >= 0.60) return const Color(0xFFFF9800);
    return context.colorScheme.tertiary;
  }

  String get _getConfidenceLabel {
    if (confidence >= 0.80) return 'High';
    if (confidence >= 0.60) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toInt();
    final color = _getConfidenceColor(context);

    return Column(
      mainAxisSize: .min,
      children: [
        SizedBox(
          width: size.w,
          height: size.h,
          child: Stack(
            alignment: .center,
            children: [
              SizedBox(
                width: size.w,
                height: size.h,
                child: CircularProgressIndicator(
                  value: confidence,
                  strokeWidth: 8.w,
                  backgroundColor: context.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    _getConfidenceLabel,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        8.heightBox,
        Text(
          'Confidence Level',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
