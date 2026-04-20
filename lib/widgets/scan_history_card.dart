import '../global/config.dart';

class ScanHistoryCard extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScanHistoryCard({
    super.key,
    required this.scan,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final percentage = (scan.confidence * 100).toInt();

    return Dismissible(
      key: Key(scan.id),
      direction: .endToStart,
      background: Container(
        alignment: .centerRight,
        padding: .only(right: 20.w),
        decoration: BoxDecoration(
          color: context.colorScheme.error,
          borderRadius: .circular(16.r),
        ),
        child: Icon(
          Icons.delete_outline,
          color: context.colorScheme.onError,
          size: 28.r,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete Scan'),
            content: const Text(
              'Are you sure you want to delete this scan result?',
            ),
            actions: [
              TextButton(
                onPressed: () => NavigatorExt(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => NavigatorExt(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      child: Card(
        elevation: 0,
        color: context.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(16.r),
          side: BorderSide(
            color: context.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: .circular(16.r),
          child: Padding(
            padding: .all(12.r),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: .circular(12),
                  child: File(scan.imagePath).existsSync()
                      ? Image.file(
                          File(scan.imagePath),
                          width: 70.w,
                          height: 70.h,
                          fit: .cover,
                        )
                      : Container(
                          width: 70.w,
                          height: 70.h,
                          color: context.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.diseaseName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: .w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        dateFormat.format(scan.createdAt),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: .symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              borderRadius: .circular(8.r),
                            ),
                            child: Text(
                              '$percentage% confidence',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
