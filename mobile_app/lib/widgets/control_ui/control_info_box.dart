import 'package:flutter/material.dart';

class ControlInfoBox extends StatelessWidget {
  final Widget child;
  final double height;

  const ControlInfoBox({
    super.key,
    required this.child,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}