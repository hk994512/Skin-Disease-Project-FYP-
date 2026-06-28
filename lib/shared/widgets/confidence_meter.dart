import 'package:clearskin_ai/core/config.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence;
  final String riskLevel;
  final double size;

  const ConfidenceMeter({
    super.key,
    required this.confidence,
    required this.riskLevel,
    this.size = 120,
  });

  Color _getConfidenceColor(BuildContext context) {
    // ✅ Medical UI rule: Color reflects disease risk, NOT AI certainty.
    // A 99% confident Melanoma diagnosis should be RED (Critical), not GREEN.
    switch (riskLevel) {
      case 'Critical':
        return context.colorScheme.error; // Red
      case 'High':
        return context.colorScheme.tertiary; // Orange/Red
      case 'Medium':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF4CAF50); // Green
    }
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.w,
          height: size.h,
          child: Stack(
            alignment: Alignment.center,
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
