import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import '../protocol/request/form1_sync_time.dart';
import '../protocol/request/form19_request_system_settings.dart';
import '../protocol/request/form21_update_system_settings.dart';

class SystemSettingsScreen extends StatefulWidget {
  final TcpService tcp;

  const SystemSettingsScreen({super.key, required this.tcp});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  DateTime? lastSystemTimeSent;
  Timer? _timer;

  late TextEditingController maxLoadController;
  late TextEditingController speedController;
  late TextEditingController manualSpeedController;
  late TextEditingController cyclesController;
  late TextEditingController durationController;
  late TextEditingController bendAngleController;
  late TextEditingController expAngleController;
  late TextEditingController activeBendAssistAngleController;
  late TextEditingController activeExpAssistAngleController;
  late TextEditingController activeBendLoadController;
  late TextEditingController activeExpLoadController;

  bool stopByCycles = true;
  bool stopByTime = false;
  bool _initializedFromState = false;

  @override
  void initState() {
    super.initState();

    maxLoadController = TextEditingController();
    speedController = TextEditingController();
    manualSpeedController = TextEditingController();
    cyclesController = TextEditingController();
    durationController = TextEditingController();
    bendAngleController = TextEditingController();
    expAngleController = TextEditingController();
    activeBendAssistAngleController = TextEditingController();
    activeExpAssistAngleController = TextEditingController();
    activeBendLoadController = TextEditingController();
    activeExpLoadController = TextEditingController();

    _fillFromState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tcp.sendForm(Form19RequestSystemSettings());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    maxLoadController.dispose();
    speedController.dispose();
    manualSpeedController.dispose();
    cyclesController.dispose();
    durationController.dispose();
    bendAngleController.dispose();
    expAngleController.dispose();
    activeBendAssistAngleController.dispose();
    activeExpAssistAngleController.dispose();
    activeBendLoadController.dispose();
    activeExpLoadController.dispose();
    super.dispose();
  }

  void _fillFromState() {
    if (_initializedFromState) return;

    maxLoadController.text = (stmState.maxLoad ?? 20).toString();
    speedController.text = (stmState.speed ?? 30).toString();
    manualSpeedController.text = (stmState.manualSpeed ?? 100).toString();
    cyclesController.text = (stmState.cycles ?? 3).toString();
    durationController.text = (stmState.durationMin ?? 5).toString();
    bendAngleController.text = (stmState.bendAngle ?? -10).toString();
    expAngleController.text = (stmState.expAngle ?? 120).toString();
    activeBendAssistAngleController.text =
        (stmState.activeBendAssistAngle ?? 10).toString();
    activeExpAssistAngleController.text =
        (stmState.activeExpAssistAngle ?? 80).toString();
    activeBendLoadController.text =
        (stmState.activeBendLoad ?? -3).toString();
    activeExpLoadController.text =
        (stmState.activeExpLoad ?? 3).toString();

    stopByCycles = stmState.stopByCycles;
    stopByTime = stmState.stopByTime;

    _initializedFromState = true;
  }

  int _parseInt(TextEditingController controller, int fallback) {
    return int.tryParse(controller.text) ?? fallback;
  }

  void _syncTime() {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    widget.tcp.sendForm(Form1SyncTime(nowSeconds));
    setState(() {
      lastSystemTimeSent = DateTime.now();
    });
  }

  void _save() {
    final maxLoad = _parseInt(maxLoadController, 20).clamp(0, 1000);
    final speed = _parseInt(speedController, 30).clamp(0, 100);
    final manualSpeed = _parseInt(manualSpeedController, 100).clamp(0, 100);
    final cycles = _parseInt(cyclesController, 3).clamp(0, 10000);
    final durationMin = _parseInt(durationController, 5).clamp(0, 10000);
    final bendAngle = _parseInt(bendAngleController, -10).clamp(-180, 180);
    final expAngle = _parseInt(expAngleController, 120).clamp(-180, 180);
    final activeBendAssistAngle =
    _parseInt(activeBendAssistAngleController, 10).clamp(-180, 180);
    final activeExpAssistAngle =
    _parseInt(activeExpAssistAngleController, 80).clamp(-180, 180);
    final activeBendLoad =
    _parseInt(activeBendLoadController, -3).clamp(-1000, 1000);
    final activeExpLoad =
    _parseInt(activeExpLoadController, 3).clamp(-1000, 1000);

    stmState.updateFromForm20(
      maxLoad: maxLoad,
      speed: speed,
      cycles: cycles,
      durationMin: durationMin,
      stopByCycles: stopByCycles,
      stopByTime: stopByTime,
      bendAngle: bendAngle,
      expAngle: expAngle,
      status: stmState.status ?? 0,
    );

    widget.tcp.sendForm(
      Form21UpdateSystemSettings(
        maxLoad: maxLoad,
        speed: speed,
        cycles: cycles,
        durationMin: durationMin,
        stopByCycles: stopByCycles,
        stopByTime: stopByTime,
        bendAngle: bendAngle,
        expAngle: expAngle,
      ),
    );

    Navigator.pop(context);
  }

  String _formatDt(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    bool allowNegative = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            allowNegative
                ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixText: suffix,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final systemNow = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: stmState,
            builder: (context, _) {
              if (!_initializedFromState && stmState.maxLoad != null) {
                _fillFromState();
              }

              return SingleChildScrollView(
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
                            'Настройки устройства',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Время',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text('Системное время:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDt(systemNow),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Время STM:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDt(stmState.time),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _syncTime,
                        icon: const Icon(Icons.sync),
                        label: const Text('Синхронизировать время'),
                      ),
                    ),
                    if (lastSystemTimeSent != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Последняя синхронизация: ${_formatDt(lastSystemTimeSent)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],

                    const SizedBox(height: 32),

                    _numberField(
                      label: 'Максимальная нагрузка',
                      controller: maxLoadController,
                      suffix: 'кг',
                    ),
                    const SizedBox(height: 24),

                    _numberField(
                      label: 'Скорость пассивного режима',
                      controller: speedController,
                      suffix: '%',
                    ),
                    const SizedBox(height: 24),

                    _numberField(
                      label: 'Количество циклов',
                      controller: cyclesController,
                    ),
                    const SizedBox(height: 24),

                    _numberField(
                      label: 'Длительность',
                      controller: durationController,
                      suffix: 'мин',
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Остановка по циклам'),
                      value: stopByCycles,
                      onChanged: (v) => setState(() => stopByCycles = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Остановка по времени'),
                      value: stopByTime,
                      onChanged: (v) => setState(() => stopByTime = v),
                    ),

                    const SizedBox(height: 16),

                    _numberField(
                      label: 'Угол сгибания',
                      controller: bendAngleController,
                      suffix: '°',
                      allowNegative: true,
                    ),
                    const SizedBox(height: 24),

                    _numberField(
                      label: 'Угол разгибания',
                      controller: expAngleController,
                      suffix: '°',
                      allowNegative: true,
                    ),
                    const SizedBox(height: 24),

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
              );
            },
          ),
        ),
      ),
    );
  }
}