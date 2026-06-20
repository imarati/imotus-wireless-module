import 'dart:typed_data';

import 'abstract/form.dart';

class Form17SystemSettings extends Form {
  @override
  int get formId => 17;

  final int speed;

  final int bendPauseSec;
  final int expPauseSec;

  final bool pauseOnBend;
  final bool pauseOnExp;

  final int cycles;
  final int durationMin;

  final bool stopByCycles;
  final bool stopByTime;

  final int maxLoad;
  final int bendMaxLoad;
  final int expMaxLoad;

  final bool reverseOnLoad;
  final bool stopOnLoad;

  Form17SystemSettings({
    required this.speed,
    required this.bendPauseSec,
    required this.expPauseSec,
    required this.pauseOnBend,
    required this.pauseOnExp,
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.maxLoad,
    required this.bendMaxLoad,
    required this.expMaxLoad,
    required this.reverseOnLoad,
    required this.stopOnLoad,
  });

  static const int payloadLength = 22;

  factory Form17SystemSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form17SystemSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form17SystemSettings(
      speed: bd.getUint16(0, Endian.little),
      bendPauseSec: bd.getUint16(2, Endian.little),
      expPauseSec: bd.getUint16(4, Endian.little),
      pauseOnBend: bd.getUint8(6) != 0,
      pauseOnExp: bd.getUint8(7) != 0,
      cycles: bd.getUint16(8, Endian.little),
      durationMin: bd.getUint16(10, Endian.little),
      stopByCycles: bd.getUint8(12) != 0,
      stopByTime: bd.getUint8(13) != 0,
      maxLoad: bd.getUint16(14, Endian.little),
      bendMaxLoad: bd.getInt16(16, Endian.little),
      expMaxLoad: bd.getInt16(18, Endian.little),
      reverseOnLoad: bd.getUint8(20) != 0,
      stopOnLoad: bd.getUint8(21) != 0,
    );
  }

  @override
  Uint8List encodePayload() {
    final bytes = ByteData(payloadLength);

    bytes.setUint16(0, speed, Endian.little);
    bytes.setUint16(2, bendPauseSec, Endian.little);
    bytes.setUint16(4, expPauseSec, Endian.little);
    bytes.setUint8(6, pauseOnBend ? 1 : 0);
    bytes.setUint8(7, pauseOnExp ? 1 : 0);
    bytes.setUint16(8, cycles, Endian.little);
    bytes.setUint16(10, durationMin, Endian.little);
    bytes.setUint8(12, stopByCycles ? 1 : 0);
    bytes.setUint8(13, stopByTime ? 1 : 0);
    bytes.setUint16(14, maxLoad, Endian.little);
    bytes.setInt16(16, bendMaxLoad, Endian.little);
    bytes.setInt16(18, expMaxLoad, Endian.little);
    bytes.setUint8(20, reverseOnLoad ? 1 : 0);
    bytes.setUint8(21, stopOnLoad ? 1 : 0);

    return bytes.buffer.asUint8List();
  }
}