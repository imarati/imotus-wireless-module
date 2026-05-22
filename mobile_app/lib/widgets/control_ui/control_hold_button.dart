import 'package:flutter/material.dart';

class ControlHoldButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ControlHoldButton({
    super.key,
    required this.icon,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onStart(),
      onTapUp: (_) => onStop(),
      onTapCancel: onStop,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }
}