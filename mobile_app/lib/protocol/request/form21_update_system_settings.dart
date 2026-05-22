import 'dart:typed_data';

import '../abstract/form.dart';

class Form21UpdateSystemSettings extends Form {
  final int maxLoad;
  final int speed;
  final int cycles;
  final int durationMin;
  final bool stopByCycles;
  final bool stopByTime;
  final int bendAngle;
  final int expAngle;

  Form21UpdateSystemSettings({
    required this.maxLoad,
    required this.speed,
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.bendAngle,
    required this.expAngle,
  });

  @override
  int get formId => 21;

  @override
  Uint8List encodePayload() {
    final bytes = ByteData(24);

    bytes.setUint16(0, maxLoad, Endian.little);
    bytes.setUint16(2, speed, Endian.little);
    bytes.setUint16(6, cycles, Endian.little);
    bytes.setUint16(8, durationMin, Endian.little);

    bytes.setUint8(10, stopByCycles ? 1 : 0);
    bytes.setUint8(11, stopByTime ? 1 : 0);

    bytes.setInt16(12, bendAngle, Endian.little);
    bytes.setInt16(14, expAngle, Endian.little);

    return bytes.buffer.asUint8List();
  }
}