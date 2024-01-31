import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:irrigation/screens/get_started.dart';
import 'package:irrigation/screens/home_page.dart';
import 'package:irrigation/utils/shared.dart';
import 'package:irrigation/utils/theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
          ChangeNotifierProvider(
            create: (context) => SharedValue(),
            child: const RajeshIot(),
          ),
    ),
  );
}

class RajeshIot extends StatelessWidget {
  const RajeshIot({super.key});

  @override
  Widget build(BuildContext context) {
    AppTheme.init(context);
    return MaterialApp(
      title: 'Smart Irrigation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.materialTheme,
      home: const GetStarted()
    );
  }
}