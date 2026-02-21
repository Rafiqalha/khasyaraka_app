import 'package:flutter/material.dart';

class RealisticFireIcon extends StatelessWidget {
  final double size;
  final bool isActive;

  const RealisticFireIcon({super.key, this.size = 28, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/training/fire.png',
      width: size,
      height: size,
      color: isActive ? null : Colors.grey,
      colorBlendMode: isActive ? null : BlendMode.srcIn,
    );
  }
}
