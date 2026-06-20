import 'package:flutter/material.dart';

class ControlHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback? onProcedures;
  final VoidCallback? onFunctions;

  const ControlHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSettings,
    this.onProcedures,
    this.onFunctions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onFunctions != null)
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.black),
              onPressed: onFunctions,
              tooltip: 'Функции',
            ),
          if (onProcedures != null)
            IconButton(
              icon: const Icon(Icons.playlist_add_check, color: Colors.black),
              onPressed: onProcedures,
              tooltip: 'Процедуры',
            ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}