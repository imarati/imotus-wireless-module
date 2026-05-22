import 'package:flutter/material.dart';

class ControlHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onSettings;

  const ControlHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: onSettings == null
                ? const SizedBox()
                : IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: onSettings,
            ),
          ),
        ],
      ),
    );
  }
}