import 'package:clearskin_ai/core/config.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = APPCOMMONS.instance;
    final isDark = context.theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? DarkModeColors.darkPrimary
        : LightModeColors.lightPrimary;
    int currentPage = ref.watch(onBoardProvider);
    final pageController = ref.read(onBoardProvider.notifier).pageController;

    return Scaffold(
      backgroundColor: context.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: .end,
                children: [
                  if (currentPage != 2)
                    TextButton(
                      onPressed: () => pageController.jumpToPage(2),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.skip,
                        style: GoogleFonts.montserrat(
                          fontSize: FontSizes.bodyLarge,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: instance.onboardingItems.length,
                onPageChanged: (int page) {
                  ref.read(onBoardProvider.notifier).nextPage(page);
                },

                itemBuilder: (context, index) {
                  return OnboardingContent(
                    item: instance.onboardingItems[index],
                    isLastPage: index == 2,
                    onGetStarted: () async {
                      await ref
                          .read(onBoardProvider.notifier)
                          .completeOnboarding();
                      if (context.mounted) context.go('/signIn');
                    },
                  );
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                instance.onboardingItems.length,
                (index) => buildPageIndicator(index, currentPage, primaryColor),
              ),
            ),
            SizedBox(height: 32.h),

            // Navigation buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  if (currentPage > 0)
                    ElevatedButton(
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            context.theme.colorScheme.primaryContainer,
                        foregroundColor:
                            context.theme.colorScheme.onPrimaryContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 14.h,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios, size: 16),
                          SizedBox(width: 8.0.w),
                          Text(
                            context.locale.back,
                            style: GoogleFonts.montserrat(
                              fontSize: FontSizes.bodyLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(width: 100.w),

                  // Next button or hidden space
                  if (currentPage < 2)
                    ElevatedButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark
                            ? DarkModeColors.darkOnPrimary
                            : LightModeColors.lightOnPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 14.h,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            context.locale.next,
                            style: GoogleFonts.montserrat(
                              fontSize: FontSizes.bodyLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    )
                  else
                    SizedBox(width: 100.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageIndicator(int index, int currentPage, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: currentPage == index ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: currentPage == index
            ? primaryColor
            : primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;
  final bool isLastPage;
  final VoidCallback onGetStarted;

  const OnboardingContent({
    required this.item,
    required this.isLastPage,
    required this.onGetStarted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.platformBrightness == Brightness.dark;
    final primaryColor = isDark
        ? DarkModeColors.darkPrimary
        : LightModeColors.lightPrimary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation
          Expanded(
            flex: 6,
            child: Center(
              child: Lottie.asset(
                item.lottieAsset,
                width: double.infinity,
                height: 300.h,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.headlineMedium?.copyWith(
              color: context.theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodyLarge?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),

          // Get Started button (only on last page)
          if (isLastPage)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark
                      ? DarkModeColors.darkOnPrimary
                      : LightModeColors.lightOnPrimary,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
                  elevation: 0,
                ),
                child: Text(
                  context.locale.started,
                  style: GoogleFonts.montserrat(
                    fontSize: FontSizes.titleMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            SizedBox(height: 56.h),
        ],
      ),
    );
  }
}
