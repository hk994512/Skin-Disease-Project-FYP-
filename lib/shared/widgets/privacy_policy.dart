import 'package:clearskin_ai/core/config.dart';

/// Call this on app first launch using SharedPreferences to track if shown
/// Example usage:
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final prefs = await SharedPreferences.getInstance();
///   final accepted = prefs.getBool('privacy_accepted') ?? false;
///   runApp(MyApp(showPrivacy: !accepted));
/// }

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  _bodystyledBox(
    double? fontSize, {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.health_and_safety,
            color: Theme.of(context).colorScheme.primaryContainer,
            size: 28,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Privacy Policy',
              // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 20.r,
                fontWeight: .bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App intro
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'This app uses AI to analyze skin images and predict possible skin conditions. '
                  'Please read how we handle your data before proceeding.',
                  // style: TextStyle(fontSize: 13, color: Colors.black87),
                  style: _bodystyledBox(12),
                ),
              ),
              SizedBox(height: 16.h),

              _buildSection(
                icon: Icons.camera_alt,
                title: '1. Image Data Collection',
                content:
                    'When you use this app, you provide skin images for analysis. '
                    'These images are sent to our secure API server for AI-based prediction only. '
                    'We do NOT store, save, or share your skin images permanently. '
                    'Images are processed in real-time and immediately discarded after prediction.',
              ),

              _buildSection(
                icon: Icons.medical_information,
                title: '2. Health Data',
                content:
                    'Skin images are considered sensitive health/medical data. '
                    'We treat all submitted images with strict confidentiality. '
                    'Your images are never used for training our AI model without explicit consent. '
                    'We do not link your images to any personal identity.',
              ),

              _buildSection(
                icon: Icons.cloud_upload,
                title: '3. API & Server Processing',
                content:
                    'Your image is transmitted securely (HTTPS) to our prediction API. '
                    'The API uses a TFLite machine learning model to analyze the image. '
                    'Only the prediction result (disease name + confidence score) is returned to your device. '
                    'No image data is logged or stored on our servers.',
              ),

              _buildSection(
                icon: Icons.warning_amber,
                title: '4. Medical Disclaimer',
                content:
                    'This app is for informational and educational purposes ONLY. '
                    'Results are AI-generated predictions and are NOT a substitute for professional medical advice, diagnosis, or treatment. '
                    'Always consult a qualified dermatologist or healthcare provider for any skin condition concerns.',
              ),

              _buildSection(
                icon: Icons.phone_android,
                title: '5. Device Permissions',
                content:
                    'This app may request access to your camera and photo gallery to capture or select skin images. '
                    'These permissions are used solely for image selection and are not used for any other purpose.',
              ),

              _buildSection(
                icon: Icons.share,
                title: '6. Data Sharing',
                content:
                    'We do NOT sell, rent, or share your data with third parties. '
                    'We do not use any third-party analytics, advertising SDKs, or tracking tools. '
                    'Your data stays between your device and our prediction API only.',
              ),

              _buildSection(
                icon: Icons.child_care,
                title: '7. Children\'s Privacy',
                content:
                    'This app is not intended for children under 13 years of age. '
                    'We do not knowingly collect data from children. '
                    'If you are a parent or guardian and believe your child has used this app, please contact us.',
              ),

              _buildSection(
                icon: Icons.update,
                title: '8. Policy Updates',
                content:
                    'We may update this privacy policy from time to time. '
                    'You will be notified of significant changes when you open the app. '
                    'Continued use of the app after changes means you accept the updated policy.',
              ),

              _buildSection(
                icon: Icons.contact_mail,
                title: '9. Contact Us',
                content:
                    'If you have any questions about this privacy policy or how we handle your data, '
                    'please contact us at: hk994512@gmail.com',
              ),

              const SizedBox(height: 16),

              // Last updated
              Text(
                'Last updated: May 2026',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => NavigatorExt(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Colors.white,
            disabledBackgroundColor: null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSection({
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
              Icon(icon, size: 16.r, color: Theme.of(context).primaryColor),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: _bodystyledBox(13, fontWeight: .bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 22.r),
            child: Text(content, style: _bodystyledBox(12.5)),
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------
/// HOW TO SHOW THIS DIALOG IN YOUR APP
/// -----------------------------------------------
///
/// In your first screen's initState or main():
///
/// void _showPrivacyDialog(BuildContext context) {
///   showDialog(
///     context: context,
///     barrierDismissible: false, // user must accept or decline
///     builder: (context) => PrivacyPolicyDialog(
///       onAccepted: () async {
///         final prefs = await SharedPreferences.getInstance();
///         await prefs.setBool('privacy_accepted', true);
///         Navigator.of(context).pop();
///         // Navigate to home screen
///       },
///       onDeclined: () {
///         Navigator.of(context).pop();
///         // Exit app or show message
///         SystemNavigator.pop();
///       },
///     ),
///   );
/// }
