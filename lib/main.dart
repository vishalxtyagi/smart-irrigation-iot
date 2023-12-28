import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:irrigation/screens/get_started.dart';
import 'package:irrigation/screens/licenses_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irrigation/screens/network_detection.dart';
import 'package:irrigation/utils/theme.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ).then(
        (_) => runApp(
      const RajeshIot(),
    ),
  );
}

class RajeshIot extends StatelessWidget {
  const RajeshIot({super.key});

  @override
  Widget build(BuildContext context) {
    AppTheme.init(context);
    return NeumorphicApp(
      title: 'Smart Irrigation',
      debugShowCheckedModeBanner: false,
      materialTheme: AppTheme.materialTheme,
      home: const NetworkDetection(),
    );
  }
}