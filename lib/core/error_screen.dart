import '/core/config.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(text: 'Error Screen'),
      body: Center(
        child: Text('Error Screen! Nothing to show\n. Try Again later'),
      ),
    );
  }
}
