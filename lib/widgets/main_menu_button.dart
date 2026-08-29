import 'package:flutter/material.dart';

import '../services/user_session.dart';

class MainMenuButton extends StatelessWidget {
  const MainMenuButton({super.key});

  void goToMainMenu(BuildContext context) {
    final user = UserSession.currentUser;

    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    if (user.role == 'BusinessOwner') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/owner-home',
        (route) => false,
      );
      return;
    }

    if (user.role == 'Customer') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/customer-home',
        (route) => false,
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => goToMainMenu(context),
      icon: const Icon(Icons.home_rounded),
      tooltip: 'Ana Menü',
    );
  }
}