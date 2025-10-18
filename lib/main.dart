import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_examen/modules/home/home_page.dart';
import 'firebase_options.dart';
import 'shared/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppExamen());
}

class AppExamen extends StatelessWidget {
  const AppExamen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Examen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
