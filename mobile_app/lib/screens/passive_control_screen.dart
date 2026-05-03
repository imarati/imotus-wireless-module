import 'package:flutter/material.dart';

import '../protocol/request/form9_passive_cmd.dart';
import '../protocol/request/form14_request_passive_settings.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import '../widgets/control_ui/control_action_button.dart';
import '../widgets/control_ui/control_angle_track.dart';
import '../widgets/control_ui/control_header.dart';
import '../widgets/control_ui/control_info_box.dart';
import '../widgets/control_ui/control_load_scale.dart';
import 'passive_settings_screen.dart';

class PassiveControlScreen extends StatefulWidget {
  final TcpService tcp;

  const PassiveControlScreen({super.key, required this.tcp});

  @override
  State<PassiveControlScreen> createState() => _PassiveControlScreenState();
}

class _PassiveControlScreenState extends State<PassiveControlScreen> {
  double angle = 0;
  double weight = 0;
  int bendAngle = -10;
  int expAngle = 120;
  int elapsedSeconds = 0;
  int doneCycles = 0;

  bool passiveRunning = false;

  @override
  void initState() {
    super.initState();
    widget.tcp.sendForm(Form14RequestPassiveSettings());
    _syncFromState();
    stmState.addListener(_onStateChanged);
  }

  void _syncFromState() {
    angle = (stmState.angle ?? 0).toDouble();
    weight = (stmState.load ?? 0).toDouble();
    bendAngle = stmState.bendAngle ?? -10;
    expAngle = stmState.expAngle ?? 120;
    elapsedSeconds = stmState.elapsedSeconds ?? 0;
    doneCycles = stmState.doneCycles ?? 0;
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
    if (passiveRunning) {
      widget.tcp.sendForm(Form9PassiveCmd(2));
      setState(() => passiveRunning = false);
    } else {
      widget.tcp.sendForm(Form9PassiveCmd(1));
      setState(() => passiveRunning = true);
    }
  }

  void _stop() {
    widget.tcp.sendForm(Form9PassiveCmd(0));
    setState(() => passiveRunning = false);
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
              title: 'Пассивный режим',
              onBack: () => Navigator.pop(context),
              onSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PassiveSettingsScreen(tcp: widget.tcp),
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
                          icon:
                          passiveRunning ? Icons.pause : Icons.play_arrow,
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
                                          angle.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontSize: 44,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ControlLoadScale(
                                    currentLoad: weight.abs(),
                                    bottomLabel:
                                    '${weight.abs().toStringAsFixed(0)} кг',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ControlAngleTrack(
                            currentAngle: angle,
                            marks: [
                              ControlAngleMark(
                                value: bendAngle.toDouble(),
                                icon: Icons.south_west,
                                dark: true,
                              ),
                              ControlAngleMark(
                                value: expAngle.toDouble(),
                                icon: Icons.north_east,
                                dark: true,
                              ),
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