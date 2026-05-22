import 'package:flutter/material.dart';

import '../protocol/request/form6_update_manual_settings.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';

class ManualSettingsScreen extends StatefulWidget {
  final int maxWeight;
  final int speed; // fallback, если пока нет manualSpeed в stmState
  final void Function(int) onMaxWeightChanged;
  final void Function(int) onSpeedChanged;
  final TcpService tcp;

  const ManualSettingsScreen({
    super.key,
    required this.maxWeight,
    required this.speed,
    required this.onMaxWeightChanged,
    required this.onSpeedChanged,
    required this.tcp,
  });

  @override
  State createState() => _ManualSettingsScreenState();
}

class _ManualSettingsScreenState extends State<ManualSettingsScreen> {
  late TextEditingController maxWeightController;
  late TextEditingController speedController;

  @override
  void initState() {
    super.initState();

    final initialMax =
    (stmState.maxLoad != null ? stmState.maxLoad! : widget.maxWeight);
    final initialManualSpeed =
    (stmState.manualSpeed != null ? stmState.manualSpeed! : widget.speed);

    maxWeightController = TextEditingController(
      text: initialMax.toStringAsFixed(0),
    );
    speedController = TextEditingController(
      text: initialManualSpeed.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    maxWeightController.dispose();
    speedController.dispose();
    super.dispose();
  }

  void _saveAndSend() {
    final maxW = int.tryParse(maxWeightController.text) ?? widget.maxWeight;
    final spdRaw = int.tryParse(speedController.text) ?? widget.speed;
    final manualSpd = spdRaw.clamp(0, 100);

    widget.onMaxWeightChanged(maxW);
    widget.onSpeedChanged(manualSpd);

    // Отправляем Form 6 с manualSpeed
    widget.tcp.sendForm(
      Form6UpdateManualSettings(
        maxLoad: maxW,
        manualSpeed: manualSpd,
      ),
    );

    // Локально обновляем состояние (до прихода Form 11 от STM)
    stmState.maxLoad = maxW;
    stmState.manualSpeed = manualSpd;
    stmState.notifyListeners();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Настройки ручного режима',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  'Максимальная нагрузка (кг)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: maxWeightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Скорость (%)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: speedController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.speed),
                    suffixText: '%',
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveAndSend,
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}