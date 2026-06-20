import 'dart:typed_data';
import 'abstract/form.dart';

class Form8PassiveSettings extends Form {
  @override
  int get formId => 8;

  final int cycles; // u16
  final int durationMin; // u16
  final bool stopByCycles; // u8
  final bool stopByTime; // u8
  final int speed; // u16
  final int maxLoad; // u16
  final int bendAngle; // i16
  final int expAngle; // i16

  Form8PassiveSettings({
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.speed,
    required this.maxLoad,
    required this.bendAngle,
    required this.expAngle,
  });

  static const int payloadLength = 14;

  factory Form8PassiveSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form8PassiveSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form8PassiveSettings(
      cycles: bd.getUint16(0, Endian.little),
      durationMin: bd.getUint16(2, Endian.little),
      stopByCycles: bd.getUint8(4) != 0,
      stopByTime: bd.getUint8(5) != 0,
      speed: bd.getUint16(6, Endian.little),
      maxLoad: bd.getUint16(8, Endian.little),
      expAngle: bd.getInt16(10, Endian.little),
      bendAngle: bd.getInt16(12, Endian.little),



    );
  }

  @override
  Uint8List encodePayload() {
    final b = ByteData(payloadLength);

    b.setUint16(0, cycles, Endian.little);
    b.setUint16(2, durationMin, Endian.little);
    b.setUint8(4, stopByCycles ? 1 : 0);
    b.setUint8(5, stopByTime ? 1 : 0);
    b.setUint16(6, speed, Endian.little);
    b.setUint16(8, maxLoad, Endian.little);
    b.setInt16(10, expAngle, Endian.little);
    b.setInt16(12, bendAngle, Endian.little);


    return b.buffer.asUint8List();
  }
}