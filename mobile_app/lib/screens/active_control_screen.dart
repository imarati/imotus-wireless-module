import 'package:flutter/material.dart';
import 'package:mobile_app/protocol/request/form14_active_cmd.dart';
import 'package:mobile_app/protocol/request/form15_request_active_settings.dart';
import 'package:mobile_app/protocol/request/form16_request_system_settings.dart';
import 'package:mobile_app/protocol/request/form25_request_active_procedures.dart';
import 'package:mobile_app/protocol/request/form26_request_active_warmup_settings.dart';
import 'package:mobile_app/protocol/request/form28_request_active_cooldown_settings.dart';
import 'package:mobile_app/protocol/request/form29_request_active_comfort_settings.dart';

import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import '../widgets/control_ui/control_action_button.dart';
import '../widgets/control_ui/control_angle_track.dart';
import '../widgets/control_ui/control_header.dart';
import '../widgets/control_ui/control_info_box.dart';
import '../widgets/control_ui/control_load_scale.dart';
import 'active_procedure_screen.dart';
import 'active_settings_screen.dart';

class ActiveControlScreen extends StatefulWidget {
  final TcpService tcp;

  const ActiveControlScreen({super.key, required this.tcp});

  @override
  State<ActiveControlScreen> createState() => _ActiveControlScreenState();
}

class _ActiveControlScreenState extends State<ActiveControlScreen> {
  double currentAngle = 0;
  double currentLoad = 0;
  int elapsedSeconds = 0;
  int doneCycles = 0;

  bool running = false;

  int bendAngle = 0;
  int bendAssistAngle = 10;
  int expAssistAngle = 80;
  int expAngle = 100;

  double bendLoad = 3;
  double expLoad = 10;

  @override
  void initState() {
    super.initState();
    _syncFromState();
    stmState.addListener(_onStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tcp.sendForm(Form15RequestActiveSettings());
    });
  }

  void _syncFromState() {
    currentAngle = (stmState.angle ?? 0).toDouble();
    currentLoad = (stmState.load ?? 0).toDouble();

    elapsedSeconds = stmState.activeElapsedSeconds ?? 0;
    doneCycles = stmState.activeDoneCycles ?? 0;

    bendAngle = stmState.bendAngle ?? 0;
    bendAssistAngle = stmState.activeBendAssistAngle ?? 10;
    expAssistAngle = stmState.activeExpAssistAngle ?? 80;
    expAngle = stmState.expAngle ?? 100;

    bendLoad = (stmState.activeBendLoad ?? -3).toDouble();
    expLoad = (stmState.activeExpLoad ?? 3).toDouble();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(_syncFromState);
  }

  @override
  void dispose() {
    stmState.removeListener(_onStateChanged);
    super.dispose();
  }

  String _formatTime(int totalSec) {
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _toggleRunPause() {
    if (running) {
      widget.tcp.sendForm(Form14ActiveCmd(Form14ActiveCmd.pause));
      setState(() => running = false);
    } else {
      widget.tcp.sendForm(Form14ActiveCmd(Form14ActiveCmd.start));
      setState(() => running = true);
    }
  }

  void _stop() {
    widget.tcp.sendForm(Form14ActiveCmd(Form14ActiveCmd.stop));
    setState(() => running = false);
  }

  void _openProcedures() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveProcedureScreen(tcp: widget.tcp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            ControlHeader(
              title: 'Активный режим',
              onBack: () => Navigator.pop(context),
              onProcedures: _openProcedures,
              onSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveSettingsScreen(tcp: widget.tcp),
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ControlInfoBox(
                            child: Text(
                              '$doneCycles',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ControlInfoBox(
                            child: Text(
                              _formatTime(elapsedSeconds),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ControlActionButton(
                          icon: running ? Icons.pause : Icons.play_arrow,
                          onTap: _toggleRunPause,
                        ),
                        const SizedBox(width: 12),
                        ControlActionButton(
                          icon: Icons.stop,
                          onTap: _stop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF1FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.square_foot,
                                          size: 80,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          currentAngle.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontSize: 44,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ControlLoadScale(
                                    currentLoad: currentLoad.abs(),
                                    bottomLabel: '${currentLoad.abs().toStringAsFixed(0)} кг',
                                    markerAValue: bendLoad,
                                    markerAIcon:  Icons.south_west,
                                    markerALabel: bendLoad.toStringAsFixed(0),
                                    markerBValue: expLoad,
                                    markerBIcon:  Icons.north_east,
                                    markerBLabel: expLoad.toStringAsFixed(0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ControlAngleTrack(
                            currentAngle: currentAngle,
                            marks: [
                              ControlAngleMark(
                                  value: bendAngle.toDouble(),
                                  icon: Icons.south_west,
                                  dark: true),
                              ControlAngleMark(
                                  value: bendAssistAngle.toDouble(),
                                  icon: Icons.south_west),
                              ControlAngleMark(
                                  value: expAssistAngle.toDouble(),
                                  icon: Icons.north_east),
                              ControlAngleMark(
                                  value: expAngle.toDouble(),
                                  icon: Icons.north_east,
                                  dark: true),
                            ],
                          ),
                        ],
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