// lib/screens/connect_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../protocol/request/form7_request_init.dart';
import '../services/tcp_service.dart';
import '../states/stm_state.dart';
import 'mode_select_screen.dart';

class ConnectScreen extends StatefulWidget {
  final TcpService tcp;

  const ConnectScreen({super.key, required this.tcp});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  TcpService get tcp => widget.tcp;

  final TextEditingController ipCtrl =
  TextEditingController(text: '192.168.4.1');
  final TextEditingController portCtrl =
  TextEditingController(text: '4210');

  bool connecting = false;
  String? error;

  @override
  void dispose() {
    ipCtrl.dispose();
    portCtrl.dispose();
    // tcp.dispose();  // БОЛЬШЕ НЕ РВЁМ СОЕДИНЕНИЕ ПРИ УХОДЕ С ЭКРАНА
    super.dispose();
  }

  Future<void> connect() async {
    setState(() {
      connecting = true;
      error = null;
    });

    try {
      final ip = ipCtrl.text.trim();
      final port = int.parse(portCtrl.text.trim());

      await tcp.connect(ip, port);

      final ok = await _waitForForm3AndRequestState();

      if (!ok) {
        setState(() {
          error = 'Не удалось получить состояние от STM';
        });
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ModeSelectScreen(tcp: tcp),
        ),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          connecting = false;
        });
      }
    }
  }

  Future<bool> _waitForForm3AndRequestState() async {
    const timeout = Duration(seconds: 10);
    const maxAttempts = 3;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      stmState.resetForConnect();

      tcp.sendForm(Form7RequestInit());

      // Если ответ успел прийти очень быстро — проверяем сразу
      if (stmState.status != null) {
        return true;
      }

      final completer = Completer<bool>();
      late VoidCallback sub;

      sub = () {
        if (stmState.status != null) {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        }
      };

      stmState.addListener(sub);

      bool ok;
      try {
        ok = await completer.future.timeout(
          timeout,
          onTimeout: () => false,
        );
      } finally {
        stmState.removeListener(sub);
      }

      if (ok) return true;
    }

    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Подключение к устройству',
                  style: TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: ipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'IP адрес',
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: portCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Порт',
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: connecting ? null : connect,
                    child: Text(
                      connecting ? 'Подключение...' : 'Подключиться',
                    ),
                  ),
                ),

                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
