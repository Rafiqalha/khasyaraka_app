import 'package:flutter/material.dart';

class TrapezoidClipper extends CustomClipper<Path> {
  TrapezoidClipper({this.topInsetFactor = 0.14});

  final double topInsetFactor;

  @override
  Path getClip(Size size) {
    final double inset = size.width * topInsetFactor;
    return Path()
      ..moveTo(inset, 0)
      ..lineTo(size.width - inset, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
