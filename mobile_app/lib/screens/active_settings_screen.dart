import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../protocol/request/form15_update_active_settings.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';

class ActiveSettingsScreen extends StatefulWidget {
  final TcpService tcp;

  const ActiveSettingsScreen({super.key, required this.tcp});

  @override
  State<ActiveSettingsScreen> createState() => _ActiveSettingsScreenState();
}

class _ActiveSettingsScreenState extends State<ActiveSettingsScreen> {
  late TextEditingController cyclesController;
  late TextEditingController durationController;
  late TextEditingController speedController;
  late TextEditingController maxLoadController;

  late TextEditingController bendAngleController;
  late TextEditingController expAngleController;

  late TextEditingController bendAssistAngleController;
  late TextEditingController expAssistAngleController;

  late TextEditingController bendLoadController;
  late TextEditingController expLoadController;

  bool stopByCycles = true;
  bool stopByTime = false;

  @override
  void initState() {
    super.initState();

    cyclesController = TextEditingController(
      text: (stmState.cycles ?? 3).toString(),
    );
    durationController = TextEditingController(
      text: (stmState.durationMin ?? 5).toString(),
    );
    speedController = TextEditingController(
      text: (stmState.speed ?? 30).toString(),
    );
    maxLoadController = TextEditingController(
      text: (stmState.maxLoad ?? 8).toString(),
    );

    bendAngleController = TextEditingController(
      text: (stmState.bendAngle ?? -10).toString(),
    );
    expAngleController = TextEditingController(
      text: (stmState.expAngle ?? 120).toString(),
    );

    bendAssistAngleController = TextEditingController(
      text: (stmState.activeBendAssistAngle ?? 10).toString(),
    );
    expAssistAngleController = TextEditingController(
      text: (stmState.activeExpAssistAngle ?? 80).toString(),
    );

    bendLoadController = TextEditingController(
      text: (stmState.activeBendLoad ?? -3).toString(),
    );
    expLoadController = TextEditingController(
      text: (stmState.activeExpLoad ?? 3).toString(),
    );

    stopByCycles = stmState.stopByCycles;
    stopByTime = stmState.stopByTime;
  }

  @override
  void dispose() {
    cyclesController.dispose();
    durationController.dispose();
    speedController.dispose();
    maxLoadController.dispose();

    bendAngleController.dispose();
    expAngleController.dispose();

    bendAssistAngleController.dispose();
    expAssistAngleController.dispose();

    bendLoadController.dispose();
    expLoadController.dispose();

    super.dispose();
  }

  int _parseInt(TextEditingController controller, int fallback) {
    return int.tryParse(controller.text) ?? fallback;
  }

  void _save() {
    final cycles = _parseInt(cyclesController, 3).clamp(0, 10000);
    final durationMin = _parseInt(durationController, 5).clamp(0, 10000);
    final speed = _parseInt(speedController, 30).clamp(0, 100);
    final maxLoad = _parseInt(maxLoadController, 8).clamp(0, 1000);

    final bendAngle = _parseInt(bendAngleController, -10).clamp(-180, 180);
    final expAngle = _parseInt(expAngleController, 120).clamp(-180, 180);

    final bendAssistAngle =
    _parseInt(bendAssistAngleController, 10).clamp(-180, 180);
    final expAssistAngle =
    _parseInt(expAssistAngleController, 80).clamp(-180, 180);

    final bendLoad = _parseInt(bendLoadController, -3).clamp(-1000, 1000);
    final expLoad = _parseInt(expLoadController, 3).clamp(-1000, 1000);

    stmState.updateFromForm17(
      cycles: cycles,
      durationMin: durationMin,
      stopByCycles: stopByCycles,
      stopByTime: stopByTime,
      speed: speed,
      maxLoad: maxLoad,
      bendAngle: bendAngle,
      expAngle: expAngle,
      bendAssistAngle: bendAssistAngle,
      expAssistAngle: expAssistAngle,
      bendLoad: bendLoad,
      expLoad: expLoad,
      status: stmState.status ?? 0,
    );

    widget.tcp.sendForm(
      Form15UpdateActiveSettings(
        cycles: cycles,
        durationMin: durationMin,
        stopByCycles: stopByCycles,
        stopByTime: stopByTime,
        speed: speed,
        maxLoad: maxLoad,
        bendAngle: bendAngle,
        expAngle: expAngle,
        bendAssistAngle: bendAssistAngle,
        expAssistAngle: expAssistAngle,
        bendLoad: bendLoad,
        expLoad: expLoad,
      ),
    );

    Navigator.pop(context);
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    bool allowNegative = false,
    IconData? icon,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            allowNegative
                ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixText: suffix,
          ),
        ),
      ],
    );
  }

  Widget _rangeFields({
    required String title,
    required TextEditingController fromController,
    required TextEditingController toController,
    required String fromLabel,
    required String toLabel,
    required String suffix,
    bool allowNegative = false,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: fromController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  allowNegative
                      ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                      : FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  labelText: fromLabel,
                  suffixText: suffix,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: toController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  allowNegative
                      ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                      : FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  labelText: toLabel,
                  suffixText: suffix,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
                        'Настройки активного режима',
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

                _numberField(
                  label: 'Количество циклов',
                  controller: cyclesController,
                  icon: Icons.repeat,
                ),
                const SizedBox(height: 24),

                _numberField(
                  label: 'Длительность тренировки',
                  controller: durationController,
                  suffix: 'мин',
                  icon: Icons.timer_outlined,
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Остановить при достижении заданного количества циклов',
                  ),
                  value: stopByCycles,
                  onChanged: (v) => setState(() => stopByCycles = v),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Остановить при окончании времени тренировки',
                  ),
                  value: stopByTime,
                  onChanged: (v) => setState(() => stopByTime = v),
                ),

                const SizedBox(height: 16),

                _numberField(
                  label: 'Скорость',
                  controller: speedController,
                  suffix: '%',
                  icon: Icons.speed,
                ),
                const SizedBox(height: 24),

                _numberField(
                  label: 'Максимальная нагрузка',
                  controller: maxLoadController,
                  suffix: 'кг',
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 24),

                _rangeFields(
                  title: 'Диапазон угла',
                  fromController: bendAngleController,
                  toController: expAngleController,
                  fromLabel: 'Сгибание',
                  toLabel: 'Разгибание',
                  suffix: '°',
                  allowNegative: true,
                ),
                const SizedBox(height: 24),

                _rangeFields(
                  title: 'Диапазон углов помощи',
                  fromController: bendAssistAngleController,
                  toController: expAssistAngleController,
                  fromLabel: 'Сгибание',
                  toLabel: 'Разгибание',
                  suffix: '°',
                  allowNegative: true,
                ),
                const SizedBox(height: 24),

                _rangeFields(
                  title: 'Диапазон нагрузки',
                  fromController: bendLoadController,
                  toController: expLoadController,
                  fromLabel: 'Сгибание',
                  toLabel: 'Разгибание',
                  suffix: 'кг',
                  allowNegative: true,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
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