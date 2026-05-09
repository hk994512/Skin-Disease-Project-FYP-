import '../../global/config.dart';

class TermsOfServiceDialog extends StatelessWidget {
  final VoidCallback onClose;

  TermsOfServiceDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.gavel,
            color: Theme.of(context).colorScheme.primaryContainer,
            size: 26.r,
          ),
          const SizedBox(width: 10),
          const Text(
            'Terms of Service',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                child: Text(
                  'By using this app, you agree to the following terms. '
                  'Please read them carefully.',
                  style: TextStyle(
                    fontSize: 13.r,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              _buildSection(
                context,
                icon: Icons.check_circle_outline,
                title: '1. Acceptance of Terms',
                content:
                    'By downloading or using this app, you agree to these terms. '
                    'If you do not agree, please do not use the app.',
              ),

              _buildSection(
                context,
                icon: Icons.medical_services_outlined,
                title: '2. Not Medical Advice',
                content:
                    'This app provides AI-based skin condition predictions for informational purposes only. '
                    'It is NOT a substitute for professional medical advice. '
                    'Always consult a licensed dermatologist for diagnosis and treatment.',
              ),

              _buildSection(
                context,
                icon: Icons.person_outline,
                title: '3. User Responsibilities',
                content:
                    'You are responsible for the images you submit. '
                    'Do not upload images of other people without their consent. '
                    'Misuse of the app for harmful or illegal purposes is strictly prohibited.',
              ),

              _buildSection(
                context,
                icon: Icons.block,
                title: '4. Limitation of Liability',
                content:
                    'We are not liable for any decisions made based on the app\'s predictions. '
                    'The app is provided "as is" without warranties of any kind.',
              ),

              _buildSection(
                context,
                icon: Icons.update,
                title: '5. Changes to Terms',
                content:
                    'We may update these terms at any time. '
                    'Continued use of the app means you accept the updated terms.',
              ),

              SizedBox(height: 8.h),
              Text(
                'Last updated: May 2026',
                style: TextStyle(
                  fontSize: 11.r,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(borderRadius: .circular(8.r)),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  _bodystyledBox(
    double? fontSize,
    BuildContext context, {
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: fontSize?.r,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(content, style: _bodystyledBox(12.5, context)),
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------
/// HOW TO USE IN SETTINGS
/// -----------------------------------------------
///
/// ListTile(
///   leading: Icon(Icons.gavel, color: Colors.green.shade700),
///   title: Text('Terms of Service'),
///   trailing: Icon(Icons.arrow_forward_ios, size: 16),
///   onTap: () {

///   },
/// ),
