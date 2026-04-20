import '../global/config.dart';

final AppAssets asset = AppAssets.instance;

class HomeBar extends ConsumerWidget {
  const HomeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(itemIndexProvider);
    final instance = APPCOMMONS.instance;
    final screens = [HomePage(), HistoryPage(), Settings(), ProfilePage()];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        useLegacyColorScheme: false,
        unselectedLabelStyle: GoogleFonts.montserrat(
          color: context.colorScheme.inversePrimary,
          fontSize: 14.5.sp,
          fontWeight: .w500,
        ),
        // unselectedItemColor:context.colorScheme.onPrimary ,
        selectedLabelStyle: GoogleFonts.montserrat(
          color: context.colorScheme.primary,
          fontSize: 14.5.sp,
          fontWeight: .w500,
        ),
        currentIndex: selectedIndex,
        type: .fixed,
        selectedIconTheme: IconThemeData(color: context.colorScheme.primary),
        selectedItemColor: context.colorScheme.primary,
        unselectedIconTheme: IconThemeData(
          color: context.colorScheme.onSurface,
        ),
        onTap: ref.read(itemIndexProvider.notifier).onToggle,
        items: instance.homeItems.map((s) {
          return BottomNavigationBarItem(
            icon: SvgPicture.asset(
              s['ico'] as String,
              fit: .cover,
              height: 26.22.h,
              colorFilter: ColorFilter.mode(
                context.colorScheme.primary,
                .srcATop,
              ),
            ),
            label: s['lab'] as String,
          );
        }).toList(),
      ),
      body: IndexedStack(index: selectedIndex, children: screens),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: .all(24.r),
            child: Column(
              crossAxisAlignment: .center,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: .center,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceAround,
                          children: [
                            Text(
                              'ClearSkin AI',
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: .bold,
                                color: context.colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.favorite,
                              color: context.colorScheme.primary,
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),
                        Align(
                          child: Text(
                            context.locale.healthCompainion,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: .w700,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 32.h),
                Container(
                  padding: .all(24.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        context.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: .circular(24.r),
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      SvgPicture.asset(
                        asset.camera,
                        fit: .cover,
                        height: 36.h,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.onPrimary,
                          .srcATop,
                        ),
                      ),
                      // 16.0.heightBox,
                      SizedBox(height: 16.h),
                      Text(
                        'Start Skin Analysis',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 8.0.heightBox,
                      SizedBox(height: 8.h),
                      Text(
                        context.locale.detectPic,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                      // 20.0.heightBox,
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () =>
                            NavigatorExt(context).push(const ScanPage()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colorScheme.onPrimary,
                          foregroundColor: context.colorScheme.primary,
                          padding: .symmetric(horizontal: 32.w, vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            const Icon(Icons.add_a_photo),
                            // 8.0.widthBox,
                            SizedBox(width: 8.w),
                            Text(
                              context.locale.scan,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _QuickActionCard(
                //         icon: Icons.history,
                //         title: 'History',
                //         description: 'View past scans',
                //         color: context.colorScheme.secondary,
                //         onTap: () => context.push(const HistoryPage()),
                //       ),
                //     ),
                //     16.0.widthBox,
                //     Expanded(
                //       child: _QuickActionCard(
                //         icon: Icons.article_outlined,
                //         title: 'Learn',
                //         description: 'Disease info',
                //         color: context.colorScheme.tertiary,
                //         onTap: () => context.push(LearnScreen()),
                //       ),
                //     ),
                //   ],
                // ),

                // 32.0.heightBox,
                Text(
                  context.locale.features,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16.h),
                _FeatureItem(
                  icon: Icons.speed,
                  title: context.locale.instantAnalysis,
                  description: context.locale.getResults,
                  color: context.colorScheme.primary,
                ),
                SizedBox(height: 12.h),
                _FeatureItem(
                  icon: Icons.verified_user_outlined,
                  title: context.locale.accuDet,
                  description: context.locale.advancedMl,
                  color: context.colorScheme.secondary,
                ),

                SizedBox(height: 12.h),
                _FeatureItem(
                  icon: Icons.medical_services_outlined,
                  title: context.locale.treatGuide,
                  description: context.locale.receiveTreat,
                  color: context.colorScheme.tertiary,
                ),

                SizedBox(height: 32.h),
                Container(
                  padding: .all(20.r),
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: .circular(16.r),
                    border: Border.all(
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
                        size: 28.r,
                      ),
                      // 16.widthBox,
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          context.locale.infoApp,
                          style: context.textTheme.bodySmall?.copyWith(
                            height: 1.4.h,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
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

// class _QuickActionCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final Color color;
//   final VoidCallback onTap;

//   const _QuickActionCard({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: .circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           borderRadius: .circular(16),
//           border: Border.all(color: color.withValues(alpha: 0.3)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: color, size: 32),
//             12.heightBox,
//             Text(
//               title,
//               style: context.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             4.heightBox,
//             Text(
//               description,
//               style: context.textTheme.bodySmall?.copyWith(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.onSurface.withValues(alpha: 0.6),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: .all(12.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: .circular(12.r),
          ),
          child: Icon(icon, color: color, size: 24.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w600,
                ),
              ),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
