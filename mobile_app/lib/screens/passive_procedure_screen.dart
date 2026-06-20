import 'package:flutter/material.dart';

import '../protocol/form30_passive_procedures.dart';
import '../protocol/request/form31_request_passive_procedures.dart';
import '../protocol/request/form33_request_passive_warmup_settings.dart';
import '../protocol/request/form35_request_passive_cooldown_settings.dart';
import '../protocol/request/form37_request_passive_comfort_settings.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import '../widgets/procedure/procedure_comfort_settings_sheet.dart';
import '../widgets/procedure/procedure_row.dart';
import '../widgets/procedure/procedure_step_settings_sheet.dart';

class PassiveProcedureScreen extends StatefulWidget {
  final tcp;
  const PassiveProcedureScreen({super.key, required this.tcp});

  @override
  State<PassiveProcedureScreen> createState() =>
      _PassiveProcedureScreenState();
}

class _PassiveProcedureScreenState extends State<PassiveProcedureScreen> {
  late bool warmupEnabled;
  late bool cooldownEnabled;
  late bool comfortEnabled;

  Future<void> _initRequests() async {
    final forms = [
      Form33RequestPassiveWarmupSettings(),
      Form35RequestPassiveCooldownSettings(),
      Form37RequestPassiveComfortSettings(),
      Form31RequestPassiveProcedures(),
    ];

    for (final form in forms) {
      widget.tcp.sendForm(form);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _syncFromState();
  }

  @override
  void initState() {
    super.initState();

    _syncFromState();
    _initRequests();
  }

  void _syncFromState() {
    warmupEnabled = stmState.passiveWarmupEnabled;
    cooldownEnabled = stmState.passiveCooldownEnabled;
    comfortEnabled = stmState.passiveComfortEnabled;
  }

  void _onWarmupChanged(bool value) {
    setState(() {
      warmupEnabled = value;
      if (value) {
        cooldownEnabled = false;
      }
    });
  }

  void _onCooldownChanged(bool value) {
    setState(() {
      cooldownEnabled = value;
      if (value) {
        warmupEnabled = false;
      }
    });
  }

  void _onComfortChanged(bool value) {
    setState(() {
      comfortEnabled = value;
    });
  }

  void _openWarmupSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProcedureStepSettingsSheet.passiveWarmup(tcp: widget.tcp),
    );
  }

  void _openCooldownSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProcedureStepSettingsSheet.passiveCooldown(tcp: widget.tcp),
    );
  }

  void _openComfortSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProcedureComfortSettingsSheet.passive(tcp: widget.tcp),
    );
  }

  void _save() {
    widget.tcp.sendForm(
      Form30PassiveProcedures(
        warmupEnabled: warmupEnabled,
        cooldownEnabled: cooldownEnabled,
        comfortEnabled: comfortEnabled,
      ),
    );

    stmState.updateFromForm30(
      warmupEnabled: warmupEnabled,
      cooldownEnabled: cooldownEnabled,
      comfortEnabled: comfortEnabled,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Процедуры — Пассивный режим',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProcedureRow(
                      label: 'Разогрев',
                      value: warmupEnabled,
                      onChanged: _onWarmupChanged,
                      onSettingsTap: _openWarmupSettings,
                    ),
                    ProcedureRow(
                      label: 'Охлаждение',
                      value: cooldownEnabled,
                      onChanged: _onCooldownChanged,
                      onSettingsTap: _openCooldownSettings,
                    ),
                    ProcedureRow(
                      label: 'Комфорт',
                      value: comfortEnabled,
                      onChanged: _onComfortChanged,
                      onSettingsTap: _openComfortSettings,
                    ),
                    const Spacer(),
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
          ],
        ),
      ),
    );
  }
}