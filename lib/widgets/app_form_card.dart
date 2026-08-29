import 'package:flutter/material.dart';

class AppFormCard extends StatelessWidget {
  final Widget child;

  const AppFormCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(18),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}