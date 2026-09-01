import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/owner_home_screen.dart';
import 'admin/screens/admin_login_screen.dart';
import 'admin/screens/admin_dashboard_screen.dart';
import 'admin/services/admin_session.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdminSession.restore();
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
        '/admin-panel/login': (context) => AdminSession.isAuthenticated
            ? const AdminDashboardScreen()
            : const AdminLoginScreen(),
        '/admin-panel': (context) => AdminSession.isAuthenticated
            ? const AdminDashboardScreen()
            : const AdminLoginScreen(),
      },
      onGenerateRoute: (settings) {
        const prefix = '/admin-panel/';
        final name = settings.name;
        if (name != null && name.startsWith(prefix)) {
          final module = name.substring(prefix.length);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => AdminSession.isAuthenticated
                ? AdminDashboardScreen(initialPath: module)
                : const AdminLoginScreen(),
          );
        }
        return null;
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
