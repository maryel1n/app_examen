import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'modules/login/login_page.dart';
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
      home: const LoginPage(),
    );
  }
}

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Examen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Bienvenida/o 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Firebase inicializado. En el siguiente paso crearemos el Login.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            ElevatedButton(onPressed: () {}, child: const Text('Continuar')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () {}, child: const Text('Más tarde')),
          ],
        ),
      ),
    );
  }
}
