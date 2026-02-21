import 'package:flutter/material.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashboardLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: padding, child: child);
  }
}
