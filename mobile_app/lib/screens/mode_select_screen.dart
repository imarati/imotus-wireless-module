import 'package:flutter/material.dart';

import '../services/tcp_service.dart';
import 'active_control_screen.dart';
import 'manual_control_screen.dart';
import 'passive_control_screen.dart';
import 'system_settings_screen.dart';
import 'connect_screen.dart';

class ModeSelectScreen extends StatefulWidget {
  final TcpService tcp;

  const ModeSelectScreen({super.key, required this.tcp});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  @override
  void initState() {
    super.initState();

    widget.tcp.onDisconnect = (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Соединение потеряно')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ConnectScreen(tcp: widget.tcp)),
            (route) => false,
      );
    };
  }

  @override
  void dispose() {
    widget.tcp.onDisconnect = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Выбор режима',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      widget.tcp.dispose();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectScreen(tcp: widget.tcp),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManualControlScreen(tcp: widget.tcp),
                      ),
                    );
                  },
                  child: const Text('Ручной режим'),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PassiveControlScreen(tcp: widget.tcp),
                      ),
                    );
                  },
                  child: const Text('Пассивный режим'),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveControlScreen(tcp: widget.tcp),
                      ),
                    );
                  },
                  child: const Text('Активный режим'),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SystemSettingsScreen(tcp: widget.tcp),
                      ),
                    );
                  },
                  child: const Text('Настройки устройства'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}