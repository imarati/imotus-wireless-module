import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../protocol/request/form4_set_target_angle.dart';
import '../protocol/request/form5_manual_cmd.dart';
import '../protocol/request/form11_request_manual_settings.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import '../widgets/control_ui/control_action_button.dart';
import '../widgets/control_ui/control_angle_track.dart';
import '../widgets/control_ui/control_header.dart';
import '../widgets/control_ui/control_hold_button.dart';
import '../widgets/control_ui/control_info_box.dart';
import '../widgets/control_ui/control_load_scale.dart';
import 'manual_settings_screen.dart';

class ManualControlScreen extends StatefulWidget {
  final TcpService tcp;

  const ManualControlScreen({super.key, required this.tcp});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  int angle = 0;
  int weight = 0;
  int targetAngle = 0;
  int maxWeight = 0;
  int speed = 0;
  late TextEditingController targetController;

  @override
  void initState() {
    super.initState();
    targetController = TextEditingController(text: '0');

    widget.tcp.sendForm(Form11RequestManualSettings());

    _syncFromState();
    stmState.addListener(_onStmStateChanged);
  }

  void _syncFromState() {
    angle = stmState.angle ?? 0;
    weight = stmState.load ?? 0;
    maxWeight = stmState.maxLoad ?? 0;
    speed = stmState.manualSpeed ?? 0;
  }

  void _onStmStateChanged() {
    if (!mounted) return;
    setState(_syncFromState);
  }

  @override
  void dispose() {
    targetController.dispose();
    stmState.removeListener(_onStmStateChanged);
    super.dispose();
  }

  void _updateTargetAngle() {
    final newValue = int.tryParse(targetController.text) ?? 0;
    setState(() => targetAngle = newValue.clamp(0, 120));
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
              title: 'Ручной режим',
              onBack: () => Navigator.pop(context),
              onSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManualSettingsScreen(
                      maxWeight: maxWeight,
                      speed: speed,
                      onMaxWeightChanged: (v) {
                        setState(() => maxWeight = v);
                      },
                      onSpeedChanged: (v) {
                        setState(() => speed = v);
                      },
                      tcp: widget.tcp,
                    ),
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
                            child: TextField(
                              controller: targetController,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              onChanged: (_) => _updateTargetAngle(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ControlActionButton(
                          icon: Icons.play_arrow,
                          onTap: () {
                            widget.tcp
                                .sendForm(Form4SetTargetAngle(targetAngle));
                          },
                        ),
                        const SizedBox(width: 12),
                        ControlActionButton(
                          icon: Icons.stop,
                          onTap: () {
                            widget.tcp.sendForm(Form5ManualCmd(0));
                          },
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.square_foot,
                                          size: 80,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          angle.toString(),
                                          style: const TextStyle(
                                            fontSize: 44,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            ControlHoldButton(
                                              icon: Icons.remove,
                                              onStart: () {
                                                widget.tcp
                                                    .sendForm(Form5ManualCmd(2));
                                              },
                                              onStop: () {
                                                widget.tcp
                                                    .sendForm(Form5ManualCmd(0));
                                              },
                                            ),
                                            const SizedBox(width: 24),
                                            ControlHoldButton(
                                              icon: Icons.add,
                                              onStart: () {
                                                widget.tcp
                                                    .sendForm(Form5ManualCmd(1));
                                              },
                                              onStop: () {
                                                widget.tcp
                                                    .sendForm(Form5ManualCmd(0));
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ControlLoadScale(
                                    currentLoad: weight.abs().toDouble(),
                                    bottomLabel: '${weight.abs()} кг',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ControlAngleTrack(
                            currentAngle: angle.toDouble(),
                          )
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