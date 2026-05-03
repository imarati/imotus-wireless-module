import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import '../protocol/abstract/form.dart';
import '../protocol/response/form20_system_settings.dart';
import '../protocol/response/form2_status.dart';
import '../protocol/response/form3_initial_state.dart';
import '../protocol/response/form10_training_status.dart';
import '../protocol/response/form11_manual_settings.dart';
import '../protocol/response/form12_passive_settings.dart';
import '../protocol/response/form17_active_settings.dart';
import '../states/stm_state.dart';

class TcpService {
  Socket? _socket;
  bool get isConnected => _socket != null;

  void Function(Object error)? onDisconnect;

  Future connect(String ip, int port) async {
    _socket?.destroy();
    _socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
    _startListening();
  }

  void _startListening() {
    if (_socket == null) return;

    List<int> buffer = [];

    _socket!.listen(
          (Uint8List data) {
        buffer.addAll(data);

        while (true) {
          final sofIndex = buffer.indexOf(0xAA);
          if (sofIndex < 0) {
            buffer.clear();
            break;
          }
          if (sofIndex > 0) {
            buffer = buffer.sublist(sofIndex);
          }
          if (buffer.length < 4) break;

          final formId = buffer[1];
          final len = buffer[2];
          final frameLen = 1 + 1 + 1 + len + 1;
          if (buffer.length < frameLen) break;

          final payload = Uint8List.fromList(buffer.sublist(3, 3 + len));
          final crc = buffer[3 + len];

          int calc = 0;
          calc ^= formId;
          calc ^= len;
          for (final b in payload) {
            calc ^= b;
          }

          if (calc == crc) {
            _routeIncoming(formId, payload);
          }

          buffer = buffer.sublist(frameLen);
        }
      },
      onError: (e) {
        _socket?.destroy();
        _socket = null;
        if (onDisconnect != null) onDisconnect!(e);
      },
      onDone: () {
        _socket?.destroy();
        _socket = null;
        if (onDisconnect != null) {
          onDisconnect!(SocketException('Connection closed'));
        }
      },
      cancelOnError: true,
    );
  }

  void _routeIncoming(int formId, Uint8List payload) {
    switch (formId) {
      case 2:
        if (payload.length >= Form2Status.payloadLength) {
          final f2 = Form2Status.fromPayload(payload);
          stmState.updateFromForm2(
            timestamp: f2.timestamp,
            angle: f2.angle,
            load: f2.load,
            status: f2.status,
          );
        }
        break;

      case 3:
        if (payload.length >= Form3InitialState.payloadLength) {
          final f3 = Form3InitialState.fromPayload(payload);
          stmState.updateFromForm3(
            status: f3.status,
          );
        }
        break;

      case 10:
        if (payload.length >= Form10TrainingStatus.payloadLength) {
          final f10 = Form10TrainingStatus.fromPayload(payload);
          stmState.updateFromForm10(
            elapsedSeconds: f10.elapsedSeconds,
            doneCycles: f10.doneCycles,
            status: f10.status,
          );
        }
        break;

      case 11:
        if (payload.length >= Form11ManualSettings.payloadLength) {
          final f11 = Form11ManualSettings.fromPayload(payload);
          stmState.updateFromForm11(
            maxLoad: f11.maxLoad,
            manualSpeed: f11.manualSpeed,
            status: f11.status,
          );
        }
        break;

      case 12:
        if (payload.length >= Form12PassiveSettings.payloadLength) {
          final f12 = Form12PassiveSettings.fromPayload(payload);
          stmState.updateFromForm12(
            cycles: f12.cycles,
            durationMin: f12.durationMin,
            stopByCycles: f12.stopByCycles,
            stopByTime: f12.stopByTime,
            speed: f12.speed,
            maxLoad: f12.maxLoad,
            bendAngle: f12.bendAngle,
            expAngle: f12.expAngle,
            status: f12.status,
          );
        }
        break;

      case 17:
        if (payload.length >= Form17ActiveSettings.payloadLength) {
          final f17 = Form17ActiveSettings.fromPayload(payload);
          stmState.updateFromForm17(
            cycles: f17.bendAngle == null ? f17.cycles : f17.cycles,
            durationMin: f17.durationMin,
            stopByCycles: f17.stopByCycles,
            stopByTime: f17.stopByTime,
            speed: f17.speed,
            maxLoad: f17.maxLoad,
            bendAngle: f17.bendAngle,
            expAngle: f17.expAngle,
            bendAssistAngle: f17.bendAssistAngle,
            expAssistAngle: f17.expAssistAngle,
            bendLoad: f17.bendLoad,
            expLoad: f17.expLoad,
            status: f17.status,
          );
        }
        break;

      case 20:
        if (payload.length >= Form20SystemSettings.payloadLength) {
          final f20 = Form20SystemSettings.fromPayload(payload);
          stmState.updateFromForm20(
            maxLoad: f20.maxLoad,
            speed: f20.speed,
            cycles: f20.cycles,
            durationMin: f20.durationMin,
            stopByCycles: f20.stopByCycles,
            stopByTime: f20.stopByTime,
            bendAngle: f20.bendAngle,
            expAngle: f20.expAngle,
            status: f20.status,
          );
        }
        break;

      default:
        break;
    }
  }

  void sendForm(Form form) {
    final payload = form.encodePayload();
    final length = payload.length;
    final bytes = Uint8List(4 + length);
    final b = bytes.buffer.asByteData();

    b.setUint8(0, 0xAA);
    b.setUint8(1, form.formId);
    b.setUint8(2, length);

    for (int i = 0; i < length; i++) {
      b.setUint8(3 + i, payload[i]);
    }

    int crc = 0;
    crc ^= form.formId;
    crc ^= length;
    for (int i = 0; i < length; i++) {
      crc ^= payload[i];
    }
    b.setUint8(3 + length, crc);

    final hex = bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    developer.log('TX FORM ${form.formId}: $hex');

    _socket?.add(bytes);
  }

  void dispose() {
    _socket?.close();
    _socket = null;
  }
}