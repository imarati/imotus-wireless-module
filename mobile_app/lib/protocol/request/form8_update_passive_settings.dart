import 'dart:typed_data';
import '../abstract/form.dart';

class Form8UpdatePassiveSettings extends Form {
  @override
  int get formId => 8;

  final int cycles; // u16
  final int durationMin; // u16
  final bool stopByCycles; // u8 -> 0/1
  final bool stopByTime; // u8 -> 0/1
  final int speed; // u16
  final int maxLoad; // u16
  final int bendAngle; // i16
  final int expAngle; // i16

  Form8UpdatePassiveSettings({
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.speed,
    required this.maxLoad,
    required this.bendAngle,
    required this.expAngle,
  });

  @override
  Uint8List encodePayload() {
    final b = ByteData(14);

    b.setUint16(0, cycles, Endian.little);
    b.setUint16(2, durationMin, Endian.little);
    b.setUint8(4, stopByCycles ? 1 : 0);
    b.setUint8(5, stopByTime ? 1 : 0);
    b.setUint16(6, speed, Endian.little);
    b.setUint16(8, maxLoad, Endian.little);
    b.setInt16(10, bendAngle, Endian.little);
    b.setInt16(12, expAngle, Endian.little);

    return b.buffer.asUint8List();
  }
}