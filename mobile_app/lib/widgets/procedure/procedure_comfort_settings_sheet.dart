import 'package:flutter/material.dart';

import '../../protocol/form36_passive_comfort_settings.dart';
import '../../protocol/form38_active_comfort_settings.dart';
import '../../services/tcp_service.dart';
import '../../states/stm_state.dart';

enum ProcedureComfortSheetMode {
  active,
  passive,
}

class ProcedureComfortSettingsSheet extends StatefulWidget {
  final ProcedureComfortSheetMode mode;
  final TcpService tcp;

  const ProcedureComfortSettingsSheet({
    super.key,
    required this.tcp,
    required this.mode,
  });

  const ProcedureComfortSettingsSheet.active({super.key, required this.tcp})
      : mode = ProcedureComfortSheetMode.active;

  const ProcedureComfortSettingsSheet.passive({super.key, required this.tcp})
      : mode = ProcedureComfortSheetMode.passive;

  @override
  State<ProcedureComfortSettingsSheet> createState() =>
      _ProcedureComfortSettingsSheetState();
}

class _ProcedureComfortSettingsSheetState
    extends State<ProcedureComfortSettingsSheet> {
  late final TextEditingController _stepController;
  late final TextEditingController _bendController;
  late final TextEditingController _expController;

  late int step;
  late int bendDeviation;
  late int expDeviation;

  @override
  void initState() {
    super.initState();

    switch (widget.mode) {
      case ProcedureComfortSheetMode.active:
        step = stmState.activeComfortStep;
        bendDeviation = stmState.activeComfortBendDeviation;
        expDeviation = stmState.activeComfortExpDeviation;
        break;
      case ProcedureComfortSheetMode.passive:
        step = stmState.passiveComfortStep;
        bendDeviation = stmState.passiveComfortBendDeviation;
        expDeviation = stmState.passiveComfortExpDeviation;
        break;
    }

    _stepController = TextEditingController(text: step.toString());
    _bendController = TextEditingController(text: bendDeviation.toString());
    _expController = TextEditingController(text: expDeviation.toString());
  }

  @override
  void dispose() {
    _stepController.dispose();
    _bendController.dispose();
    _expController.dispose();
    super.dispose();
  }

  void _save() {
    final parsedStep = int.tryParse(_stepController.text.trim());
    final parsedBend = int.tryParse(_bendController.text.trim());
    final parsedExp = int.tryParse(_expController.text.trim());

    if (parsedStep == null || parsedBend == null || parsedExp == null) {
      return;
    }

    step = parsedStep;
    bendDeviation = parsedBend;
    expDeviation = parsedExp;

    switch (widget.mode) {
      case ProcedureComfortSheetMode.active:
        widget.tcp.sendForm(
          Form38ActiveComfortSettings(
            step: step,
            bendDeviation: bendDeviation,
            expDeviation: expDeviation,
          ),
        );
        stmState.updateFromForm38(
          comfortStep: step,
          comfortBendDeviation: bendDeviation,
          comfortExpDeviation: expDeviation,
        );
        break;

      case ProcedureComfortSheetMode.passive:
        widget.tcp.sendForm(
          Form36PassiveComfortSettings(
            step: step,
            bendDeviation: bendDeviation,
            expDeviation: expDeviation,
          ),
        );
        stmState.updateFromForm36(
          comfortStep: step,
          comfortBendDeviation: bendDeviation,
          comfortExpDeviation: expDeviation,
        );
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
            const Text(
              'Настройки комфорта',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Шаг',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bendController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Отклонение сгибания',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Отклонение разгибания',
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