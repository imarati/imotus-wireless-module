import 'dart:typed_data';

class Form12PassiveSettings {
  final int cycles; // u16
  final int durationMin; // u16
  final bool stopByCycles; // u8
  final bool stopByTime; // u8
  final int speed; // u16
  final int maxLoad; // u16
  final int bendAngle; // i16
  final int expAngle; // i16
  final int status; // u8

  const Form12PassiveSettings({
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.speed,
    required this.maxLoad,
    required this.bendAngle,
    required this.expAngle,
    required this.status,
  });

  static const int payloadLength = 15;

  factory Form12PassiveSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form12 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form12PassiveSettings(
      cycles: bd.getUint16(0, Endian.little),
      durationMin: bd.getUint16(2, Endian.little),
      stopByCycles: bd.getUint8(4) != 0,
      stopByTime: bd.getUint8(5) != 0,
      speed: bd.getUint16(6, Endian.little),
      maxLoad: bd.getUint16(8, Endian.little),
      bendAngle: bd.getInt16(10, Endian.little),
      expAngle: bd.getInt16(12, Endian.little),
      status: bd.getUint8(14),
    );
  }
}