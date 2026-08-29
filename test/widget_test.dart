// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salon_appointment_app/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('/login displays the normal login', (tester) async {
    await tester.pumpWidget(const SalonAppointmentApp());
    expect(find.text('Salon Randevu'), findsOneWidget);
    expect(find.text('Yetkili Personel Girişi'), findsNothing);
  });

  testWidgets('/admin-panel/login displays distinct admin login', (tester) async {
    await tester.pumpWidget(const SalonAppointmentApp());
    Navigator.of(tester.element(find.text('Salon Randevu')))
        .pushNamed('/admin-panel/login');
    await tester.pumpAndSettle();
    expect(find.text('Yetkili Personel Girişi'), findsOneWidget);
  });

  testWidgets('unauthenticated /admin-panel is guarded', (tester) async {
    await tester.pumpWidget(const SalonAppointmentApp());
    Navigator.of(tester.element(find.text('Salon Randevu')))
        .pushNamed('/admin-panel');
    await tester.pumpAndSettle();
    expect(find.text('Yetkili Personel Girişi'), findsOneWidget);
  });
}
