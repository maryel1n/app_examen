import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_examen/modules/home/home_page.dart';

void main() {
  testWidgets('Home smoke test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.text('APP - EXAMEN'), findsOneWidget);
  });
}
