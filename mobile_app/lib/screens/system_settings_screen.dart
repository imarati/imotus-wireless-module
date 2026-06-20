import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/protocol/form17_system_settings.dart';
import 'package:mobile_app/screens/patient_info_screen.dart';
import 'package:mobile_app/screens/session_date_time_screen.dart';

import '../protocol/request/form16_request_system_settings.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';

class SystemSettingsScreen extends StatefulWidget {
  final TcpService tcp;

  const SystemSettingsScreen({super.key, required this.tcp});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  Timer? _timer;

  late TextEditingController speedController;

  late TextEditingController bendPauseSecController;
  late TextEditingController expPauseSecController;

  late TextEditingController cyclesController;
  late TextEditingController durationController;

  late TextEditingController maxLoadController;
  late TextEditingController bendMaxLoadController;
  late TextEditingController expMaxLoadController;

  bool pauseOnBend = false;
  bool pauseOnExp = false;

  bool reverseOnLoad = false;
  bool stopOnLoad = false;

  bool stopByCycles = true;
  bool stopByTime = false;

  bool _initializedFromState = false;

  @override
  void initState() {
    super.initState();

    speedController = TextEditingController();

    bendPauseSecController = TextEditingController();
    expPauseSecController = TextEditingController();

    cyclesController = TextEditingController();
    durationController = TextEditingController();

    maxLoadController = TextEditingController();
    bendMaxLoadController = TextEditingController();
    expMaxLoadController = TextEditingController();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    stmState.addListener(_tryInitFromState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tcp.sendForm(Form16RequestSystemSettings());
    });
  }

  @override
  void dispose() {
    stmState.removeListener(_tryInitFromState);
    _timer?.cancel();

    speedController.dispose();

    bendPauseSecController.dispose();
    expPauseSecController.dispose();

    cyclesController.dispose();
    durationController.dispose();

    maxLoadController.dispose();
    bendMaxLoadController.dispose();
    expMaxLoadController.dispose();

    super.dispose();
  }

  void _tryInitFromState() {
    if (!mounted) return;
    if (!_initializedFromState && _hasSystemSettingsFromStm) {
      _fillFromStateOnceWhenReady();
    }
  }

  void _fillFromStateOnceWhenReady() {
    if (_initializedFromState) return;
    if (!_hasSystemSettingsFromStm) return;

    speedController.text = (stmState.speed ?? 30).toString();

    bendPauseSecController.text = (stmState.bendPauseSec ?? 0).toString();
    expPauseSecController.text = (stmState.expPauseSec ?? 0).toString();

    cyclesController.text = (stmState.cycles ?? 3).toString();
    durationController.text = (stmState.durationMin ?? 5).toString();

    maxLoadController.text =
        ((stmState.maxLoad ?? 0) < 0 ? 0 : (stmState.maxLoad ?? 0)).toString();
    bendMaxLoadController.text =
        ((stmState.bendMaxLoad ?? 0) < 0 ? 0 : (stmState.bendMaxLoad ?? 0)).toString();
    expMaxLoadController.text =
        ((stmState.expMaxLoad ?? 0) < 0 ? 0 : (stmState.expMaxLoad ?? 0)).toString();

    pauseOnBend = stmState.pauseOnBend;
    pauseOnExp = stmState.pauseOnExp;

    reverseOnLoad = stmState.reverseOnLoad;
    stopOnLoad = stmState.stopOnLoad;

    stopByCycles = stmState.stopByCycles;
    stopByTime = stmState.stopByTime;

    _initializedFromState = true;

    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasSystemSettingsFromStm {
    return stmState.speed != null ||
        stmState.bendPauseSec != null ||
        stmState.expPauseSec != null ||
        stmState.maxLoad != null ||
        stmState.bendMaxLoad != null ||
        stmState.expMaxLoad != null;
  }

  int _parseInt(TextEditingController controller, int fallback) {
    return int.tryParse(controller.text) ?? fallback;
  }

  void _save() {
    final speed = _parseInt(speedController, 30).clamp(0, 100);

    final bendPauseSec =
    _parseInt(bendPauseSecController, 0).clamp(0, 10000);
    final expPauseSec =
    _parseInt(expPauseSecController, 0).clamp(0, 10000);

    final cycles = _parseInt(cyclesController, 3).clamp(0, 10000);
    final durationMin = _parseInt(durationController, 5).clamp(0, 10000);

    final maxLoad = _parseInt(maxLoadController, 20).clamp(0, 1000);
    final bendMaxLoad = _parseInt(bendMaxLoadController, 0).clamp(0, 1000);
    final expMaxLoad = _parseInt(expMaxLoadController, 0).clamp(0, 1000);

    stmState.updateFromForm17(
      speed: speed,
      bendPauseSec: bendPauseSec,
      expPauseSec: expPauseSec,
      pauseOnBend: pauseOnBend,
      pauseOnExp: pauseOnExp,
      cycles: cycles,
      durationMin: durationMin,
      stopByCycles: stopByCycles,
      stopByTime: stopByTime,
      maxLoad: maxLoad,
      bendMaxLoad: bendMaxLoad,
      expMaxLoad: expMaxLoad,
      reverseOnLoad: reverseOnLoad,
      stopOnLoad: stopOnLoad,
    );

    widget.tcp.sendForm(
      Form17SystemSettings(
        speed: speed,
        bendPauseSec: bendPauseSec,
        expPauseSec: expPauseSec,
        pauseOnBend: pauseOnBend,
        pauseOnExp: pauseOnExp,
        cycles: cycles,
        durationMin: durationMin,
        stopByCycles: stopByCycles,
        stopByTime: stopByTime,
        maxLoad: maxLoad,
        bendMaxLoad: bendMaxLoad,
        expMaxLoad: expMaxLoad,
        reverseOnLoad: reverseOnLoad,
        stopOnLoad: stopOnLoad,
      ),
    );

    Navigator.pop(context);
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: Colors.grey.shade300, thickness: 1),
    );
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: stmState,
            builder: (context, _) {
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
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.badge_outlined, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientInfoScreen(tcp: widget.tcp),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.schedule, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SessionDateTimeScreen(tcp: widget.tcp),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _sectionDivider(),

                    _numberField(
                      label: 'Скорость',
                      controller: speedController,
                      suffix: '%',
                    ),

                    _sectionDivider(),

                    _sectionTitle('Настройка паузы при сгибании и разгибании'),
                    _numberField(
                      label: 'Длительность паузы при сгибании',
                      controller: bendPauseSecController,
                      suffix: 'сек',
                    ),
                    const SizedBox(height: 24),
                    _numberField(
                      label: 'Длительность паузы при разгибании',
                      controller: expPauseSecController,
                      suffix: 'сек',
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Пауза при сгибании'),
                      value: pauseOnBend,
                      onChanged: (v) => setState(() => pauseOnBend = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Пауза при разгибании'),
                      value: pauseOnExp,
                      onChanged: (v) => setState(() => pauseOnExp = v),
                    ),

                    _sectionDivider(),

                    _sectionTitle('Настройка времени и циклов тренировки'),
                    _numberField(
                      label: 'Количество циклов',
                      controller: cyclesController,
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
                    const SizedBox(height: 8),
                    _numberField(
                      label: 'Длительность тренировки',
                      controller: durationController,
                      suffix: 'мин',
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Остановить при окончании времени тренировки',
                      ),
                      value: stopByTime,
                      onChanged: (v) => setState(() => stopByTime = v),
                    ),

                    _sectionDivider(),

                    _sectionTitle('Настройка значений нагрузки и действий при нагрузке'),
                    _numberField(
                      label: 'Предельное усилие',
                      controller: maxLoadController,
                      suffix: 'кг',
                    ),
                    const SizedBox(height: 24),
                    _numberField(
                      label: 'Предельная нагрузка при сгибании',
                      controller: bendMaxLoadController,
                      suffix: 'кг',
                      allowNegative: false,
                    ),
                    const SizedBox(height: 24),
                    _numberField(
                      label: 'Предельная нагрузка при разгибании',
                      controller: expMaxLoadController,
                      suffix: 'кг',
                      allowNegative: false,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Реверс на нагрузку'),
                      value: reverseOnLoad,
                      onChanged: (v) => setState(() => reverseOnLoad = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Остановка на нагрузку'),
                      value: stopOnLoad,
                      onChanged: (v) => setState(() => stopOnLoad = v),
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
              );
            },
          ),
        ),
      ),
    );
  }
}