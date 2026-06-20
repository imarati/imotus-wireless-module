import 'package:flutter/material.dart';

class ProcedureRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onSettingsTap;

  const ProcedureRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: onSettingsTap,
            tooltip: 'Настройки $label',
          ),
        ],
      ),
    );
  }
}