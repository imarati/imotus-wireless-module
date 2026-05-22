import 'dart:typed_data';
import '../abstract/form.dart';

class Form15UpdateActiveSettings extends Form {
  @override
  int get formId => 15;

  final int cycles; // u16
  final int durationMin; // u16
  final bool stopByCycles; // u8 -> 0/1
  final bool stopByTime; // u8 -> 0/1
  final int speed; // u16
  final int maxLoad; // u16

  final int bendAngle; // i16
  final int expAngle; // i16

  final int bendAssistAngle; // i16
  final int expAssistAngle; // i16

  final int bendLoad; // i16
  final int expLoad; // i16

  Form15UpdateActiveSettings({
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.speed,
    required this.maxLoad,
    required this.bendAngle,
    required this.expAngle,
    required this.bendAssistAngle,
    required this.expAssistAngle,
    required this.bendLoad,
    required this.expLoad,
  });

  @override
  Uint8List encodePayload() {
    final b = ByteData(22);

    b.setUint16(0, cycles, Endian.little);
    b.setUint16(2, durationMin, Endian.little);
    b.setUint8(4, stopByCycles ? 1 : 0);
    b.setUint8(5, stopByTime ? 1 : 0);
    b.setUint16(6, speed, Endian.little);
    b.setUint16(8, maxLoad, Endian.little);

    b.setInt16(10, bendAngle, Endian.little);
    b.setInt16(12, expAngle, Endian.little);

    b.setInt16(14, bendAssistAngle, Endian.little);
    b.setInt16(16, expAssistAngle, Endian.little);

    b.setInt16(18, bendLoad, Endian.little);
    b.setInt16(20, expLoad, Endian.little);

    return b.buffer.asUint8List();
  }
}