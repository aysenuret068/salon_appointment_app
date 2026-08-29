import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/owner_home_screen.dart';

import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SalonAppointmentApp());
}

class SalonAppointmentApp extends StatelessWidget {
  const SalonAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon Randevu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Uygulama ilk açıldığında giriş ekranı
      home: const LoginScreen(),

      // Uygulama içindeki ana sayfa yolları
      routes: {
        '/login': (context) => const LoginScreen(),
        '/customer-home': (context) => const CustomerHomeScreen(),
        '/owner-home': (context) => const OwnerHomeScreen(),
      },

      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}