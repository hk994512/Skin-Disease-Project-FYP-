import '../global/config.dart';

class TreatmentCard extends StatelessWidget {
  final String treatment;
  final int index;

  const TreatmentCard({
    super.key,
    required this.treatment,
    required this.index,
  });

  IconData _getIconForIndex(int index) {
    const icons = [
      Icons.medication_outlined,
      Icons.healing_outlined,
      Icons.spa_outlined,
      Icons.local_hospital_outlined,
      Icons.health_and_safety_outlined,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .only(bottom: 12.h),
      padding: .all(16.r),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: .circular(16.r),
        border: .all(color: context.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: .all(10.r),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: .circular(12.r),
            ),
            child: Icon(
              _getIconForIndex(index),
              color: context.colorScheme.primary,
              size: 24.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              treatment,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.4.h),
            ),
          ),
        ],
      ),
    );
  }
}
