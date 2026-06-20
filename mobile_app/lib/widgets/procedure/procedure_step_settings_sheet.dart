import 'package:flutter/material.dart';

import '../../protocol/form24_active_warmup_settings.dart';
import '../../protocol/form27_active_cooldown_settings.dart';
import '../../protocol/form32_passive_warmup_settings.dart';
import '../../protocol/form34_passive_cooldown_settings.dart';
import '../../services/tcp_service.dart';
import '../../states/stm_state.dart';

enum ProcedureStepSheetMode {
  activeWarmup,
  activeCooldown,
  passiveWarmup,
  passiveCooldown,
}

class ProcedureStepSettingsSheet extends StatefulWidget {
  final ProcedureStepSheetMode mode;
  final TcpService tcp;

  const ProcedureStepSettingsSheet({
    super.key,
    required this.tcp,
    required this.mode,
  });

  const ProcedureStepSettingsSheet.activeWarmup({super.key, required this.tcp,})
      : mode = ProcedureStepSheetMode.activeWarmup;

  const ProcedureStepSettingsSheet.activeCooldown({super.key, required this.tcp,})
      : mode = ProcedureStepSheetMode.activeCooldown;

  const ProcedureStepSettingsSheet.passiveWarmup({super.key, required this.tcp,})
      : mode = ProcedureStepSheetMode.passiveWarmup;

  const ProcedureStepSettingsSheet.passiveCooldown({super.key, required this.tcp})
      : mode = ProcedureStepSheetMode.passiveCooldown;

  @override
  State<ProcedureStepSettingsSheet> createState() =>
      _ProcedureStepSettingsSheetState();
}

class _ProcedureStepSettingsSheetState extends State<ProcedureStepSettingsSheet> {
  late final TextEditingController _controller;
  late int step;

  String get _title {
    switch (widget.mode) {
      case ProcedureStepSheetMode.activeWarmup:
        return 'Настройки разогрева';
      case ProcedureStepSheetMode.activeCooldown:
        return 'Настройки охлаждения';
      case ProcedureStepSheetMode.passiveWarmup:
        return 'Настройки разогрева';
      case ProcedureStepSheetMode.passiveCooldown:
        return 'Настройки охлаждения';
    }
  }

  @override
  void initState() {
    super.initState();

    switch (widget.mode) {
      case ProcedureStepSheetMode.activeWarmup:
        step = stmState.activeWarmupStep;
        break;
      case ProcedureStepSheetMode.activeCooldown:
        step = stmState.activeCooldownStep;
        break;
      case ProcedureStepSheetMode.passiveWarmup:
        step = stmState.passiveWarmupStep;
        break;
      case ProcedureStepSheetMode.passiveCooldown:
        step = stmState.passiveCooldownStep;
        break;
    }

    _controller = TextEditingController(text: step.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) return;

    step = parsed;

    switch (widget.mode) {
      case ProcedureStepSheetMode.activeWarmup:
        widget.tcp.sendForm(
          Form24ActiveWarmupSettings(step: step),
        );
        stmState.updateFromForm24(warmupStep: step);
        break;

      case ProcedureStepSheetMode.activeCooldown:
        widget.tcp.sendForm(
          Form27ActiveCooldownSettings(step: step),
        );
        stmState.updateFromForm27(cooldownStep: step);
        break;

      case ProcedureStepSheetMode.passiveWarmup:
        widget.tcp.sendForm(
          Form32PassiveWarmupSettings(step: step),
        );
        stmState.updateFromForm32(warmupStep: step);
        break;

      case ProcedureStepSheetMode.passiveCooldown:
        widget.tcp.sendForm(
          Form34PassiveCooldownSettings(step: step),
        );
        stmState.updateFromForm34(cooldownStep: step);
        break;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Шаг',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
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
    );
  }
}