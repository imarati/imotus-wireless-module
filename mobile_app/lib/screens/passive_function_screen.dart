import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../protocol/form39_passive_functions.dart';
import '../protocol/request/form40_request_passive_functions.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import '../widgets/procedure/procedure_row.dart';

class PassiveFunctionScreen extends StatefulWidget {
  final TcpService tcp;

  const PassiveFunctionScreen({super.key, required this.tcp});

  @override
  State<PassiveFunctionScreen> createState() => _PassiveFunctionScreenState();
}

class _PassiveFunctionScreenState extends State<PassiveFunctionScreen> {
  late bool extendBendEnabled;
  late bool extendExpEnabled;
  late TextEditingController repeatsController;

  @override
  void initState() {
    super.initState();
    widget.tcp.sendForm(Form40RequestPassiveFunctions());

    _syncFromState();
  }

  void _syncFromState() {
    extendBendEnabled = stmState.passiveExtendBendEnabled;
    extendExpEnabled = stmState.passiveExtendExpEnabled;
    repeatsController = TextEditingController(
      text: stmState.passiveExtendRepeats.toString(),
    );
  }

  @override
  void dispose() {
    repeatsController.dispose();
    super.dispose();
  }

  void _save() {
    final repeats = int.tryParse(repeatsController.text.trim());
    if (repeats == null || repeats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректное количество повторов'),
        ),
      );
      return;
    }

    widget.tcp.sendForm(
      Form39PassiveFunctions(
        extendBendEnabled: extendBendEnabled,
        extendExpEnabled: extendExpEnabled,
        extendRepeats: repeats,
      ),
    );

    stmState.updatePassiveFunctions(
      extendBendEnabled: extendBendEnabled,
      extendExpEnabled: extendExpEnabled,
      extendRepeats: repeats,
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
                      'Функции — Пассивный режим',
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
                      label: 'Удлинение сгибания',
                      value: extendBendEnabled,
                      onChanged: (v) => setState(() => extendBendEnabled = v),
                      onSettingsTap: () {},
                    ),
                    ProcedureRow(
                      label: 'Удлинение вытяжения',
                      value: extendExpEnabled,
                      onChanged: (v) => setState(() => extendExpEnabled = v),
                      onSettingsTap: () {},
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Количество повторов',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: repeatsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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