import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import '../protocol/abstract/form.dart';
import '../protocol/form39_passive_functions.dart';
import '../protocol/form6_manual_settings.dart';
import '../protocol/form8_passive_settings.dart';
import '../protocol/form13_active_settings.dart';
import '../protocol/form17_system_settings.dart';
import '../protocol/form18_patient_info.dart';
import '../protocol/form19_session_datetime.dart';
import '../protocol/form23_active_procedures.dart';
import '../protocol/form24_active_warmup_settings.dart';
import '../protocol/form27_active_cooldown_settings.dart';
import '../protocol/form30_passive_procedures.dart';
import '../protocol/form32_passive_warmup_settings.dart';
import '../protocol/form34_passive_cooldown_settings.dart';
import '../protocol/form36_passive_comfort_settings.dart';
import '../protocol/form38_active_comfort_settings.dart';
import '../protocol/response/form2_status.dart';
import '../protocol/response/form3_initial_state.dart';
import '../protocol/response/form10_passive_training_status.dart';
import '../protocol/response/form20_active_training_status.dart';
import '../states/stm_state.dart';

class TcpService {
  Socket? _socket;

  bool get isConnected => _socket != null;

  void Function(Object error)? onDisconnect;

  Future<void> connect(String ip, int port) async {
    _socket?.destroy();
    _socket = await Socket.connect(
      ip,
      port,
      timeout: const Duration(seconds: 5),
    );
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

          final rxHex = buffer
              .sublist(0, frameLen)
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join(' ');

          if (formId != 2) {
            developer.log('RX CRC $calc');
            developer.log('RX FORM $formId: $rxHex');
          }

          if (calc == crc) {
            _routeIncoming(formId, payload);
          } else {
            developer.log(
              'RX CRC ERROR formId=$formId len=$len calc=$calc recv=$crc',
            );
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
            dateTime: f2.dateTime,
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

      case 6:
        if (payload.length >= Form6ManualSettings.payloadLength) {
          final f6 = Form6ManualSettings.fromPayload(payload);
          stmState.updateFromForm6(
            maxLoad: f6.maxLoad,
            manualSpeed: f6.manualSpeed,
          );
        }
        break;

      case 8:
        if (payload.length >= Form8PassiveSettings.payloadLength) {
          final f8 = Form8PassiveSettings.fromPayload(payload);
          stmState.updateFromForm8(
            cycles: f8.cycles,
            durationMin: f8.durationMin,
            stopByCycles: f8.stopByCycles,
            stopByTime: f8.stopByTime,
            speed: f8.speed,
            maxLoad: f8.maxLoad,
            bendAngle: f8.bendAngle,
            expAngle: f8.expAngle,
          );
        }
        break;

      case 10:
        if (payload.length >= Form10PassiveTrainingStatus.payloadLength) {
          final f10 = Form10PassiveTrainingStatus.fromPayload(payload);
          stmState.updateFromForm10(
            elapsedSeconds: f10.elapsedSeconds,
            doneCycles: f10.doneCycles,
            status: f10.status,
          );
        }
        break;

      case 13:
        if (payload.length >= Form13ActiveSettings.payloadLength) {
          final f13 = Form13ActiveSettings.fromPayload(payload);
          stmState.updateFromForm13(
            cycles: f13.cycles,
            durationMin: f13.durationMin,
            stopByCycles: f13.stopByCycles,
            stopByTime: f13.stopByTime,
            speed: f13.speed,
            maxLoad: f13.maxLoad,
            bendAngle: f13.bendAngle,
            expAngle: f13.expAngle,
            bendAssistAngle: f13.bendAssistAngle,
            expAssistAngle: f13.expAssistAngle,
            bendLoad: f13.bendLoad,
            expLoad: f13.expLoad,
          );
        }
        break;

      case 17:
        if (payload.length >= Form17SystemSettings.payloadLength) {
          final f17 = Form17SystemSettings.fromPayload(payload);
          stmState.updateFromForm17(
            speed: f17.speed,
            bendPauseSec: f17.bendPauseSec,
            expPauseSec: f17.expPauseSec,
            pauseOnBend: f17.pauseOnBend,
            pauseOnExp: f17.pauseOnExp,
            cycles: f17.cycles,
            durationMin: f17.durationMin,
            stopByCycles: f17.stopByCycles,
            stopByTime: f17.stopByTime,
            maxLoad: f17.maxLoad,
            bendMaxLoad: f17.bendMaxLoad,
            expMaxLoad: f17.expMaxLoad,
            reverseOnLoad: f17.reverseOnLoad,
            stopOnLoad: f17.stopOnLoad,
          );
        }
        break;

      case 18:
        if (payload.length >= Form18PatientInfo.payloadLength) {
          final rawHex = payload
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join(' ');
          developer.log('RX18 RAW PAYLOAD: $rawHex');

          final f18 = Form18PatientInfo.fromPayload(payload);
          stmState.updateFromForm18(
            surname: f18.surname,
            name: f18.name,
            patronymic: f18.patronymic,
            patientId: f18.patientId,
          );
        }
        break;

      case 19:
        if (payload.length >= Form19SessionDateTime.payloadLength) {
          final f19 = Form19SessionDateTime.fromPayload(payload);
          stmState.updateFromForm19(
            sessionDate: f19.sessionDate,
            sessionTime: TimeOfDayData(
              hour: f19.hour,
              minute: f19.minute,
              second: f19.second,
            ),
          );
        }
        break;

      case 20:
        if (payload.length >= Form20ActiveTrainingStatus.payloadLength) {
          final f20 = Form20ActiveTrainingStatus.fromPayload(payload);
          stmState.updateFromForm20(
            elapsedSeconds: f20.elapsedSeconds,
            doneCycles: f20.doneCycles,
            status: f20.status,
          );
        }
        break;

      case 23:
        if (payload.length >= Form23ActiveProcedures.payloadLength) {
          final f23 = Form23ActiveProcedures.fromPayload(payload);
          stmState.updateFromForm23(
            warmupEnabled: f23.warmupEnabled,
            cooldownEnabled: f23.cooldownEnabled,
            comfortEnabled: f23.comfortEnabled,
          );
        }
        break;

      case 24:
        if (payload.length >= Form24ActiveWarmupSettings.payloadLength) {
          final f24 = Form24ActiveWarmupSettings.fromPayload(payload);
          stmState.updateFromForm24(
            warmupStep: f24.step,
          );
        }
        break;

      case 27:
        if (payload.length >= Form27ActiveCooldownSettings.payloadLength) {
          final f27 = Form27ActiveCooldownSettings.fromPayload(payload);
          stmState.updateFromForm27(
            cooldownStep: f27.step,
          );
        }
        break;

      case 30:
        if (payload.length >= Form30PassiveProcedures.payloadLength) {
          final f30 = Form30PassiveProcedures.fromPayload(payload);
          stmState.updateFromForm30(
            warmupEnabled: f30.warmupEnabled,
            cooldownEnabled: f30.cooldownEnabled,
            comfortEnabled: f30.comfortEnabled,
          );
        }
        break;

      case 32:
        if (payload.length >= Form32PassiveWarmupSettings.payloadLength) {
          final f32 = Form32PassiveWarmupSettings.fromPayload(payload);
          stmState.updateFromForm32(
            warmupStep: f32.step,
          );
        }
        break;

      case 34:
        if (payload.length >= Form34PassiveCooldownSettings.payloadLength) {
          final f34 = Form34PassiveCooldownSettings.fromPayload(payload);
          stmState.updateFromForm34(
            cooldownStep: f34.step,
          );
        }
        break;

      case 36:
        if (payload.length >= Form36PassiveComfortSettings.payloadLength) {
          final f36 = Form36PassiveComfortSettings.fromPayload(payload);
          stmState.updateFromForm36(
            comfortStep: f36.step,
            comfortBendDeviation: f36.bendDeviation,
            comfortExpDeviation: f36.expDeviation,
          );
        }
        break;

      case 38:
        if (payload.length >= Form38ActiveComfortSettings.payloadLength) {
          final f38 = Form38ActiveComfortSettings.fromPayload(payload);
          stmState.updateFromForm38(
            comfortStep: f38.step,
            comfortBendDeviation: f38.bendDeviation,
            comfortExpDeviation: f38.expDeviation,
          );
        }
        break;

      case 39:
        if (payload.length == Form39PassiveFunctions.payloadLength) {
          final f39 = Form39PassiveFunctions.fromPayload(payload);
          stmState.updatePassiveFunctions(
            extendBendEnabled: f39.extendBendEnabled,
            extendExpEnabled: f39.extendExpEnabled,
            extendRepeats: f39.extendRepeats,
          );
        }
        break;

      default:
        developer.log(
          'RX UNKNOWN FORM: formId=$formId payloadLen=${payload.length}',
        );
        break;
    }
  }

  void sendForm(Form form) {
    if (_socket == null) {
      developer.log('TX SKIPPED: socket is not connected, formId=${form.formId}');
      return;
    }

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
    developer.log('TX FORM CRC: $crc');
    developer.log('TX FORM ${form.formId}: $hex');

    _socket!.add(bytes);
  }

  void dispose() {
    _socket?.close();
    _socket = null;
  }
}