import 'package:flutter/material.dart';

class ControlActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const ControlActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}