import 'dart:typed_data';

class Form20SystemSettings {
  final int maxLoad; // u16
  final int speed; // u16
  final int cycles; // u16
  final int durationMin; // u16

  final bool stopByCycles; // u8
  final bool stopByTime; // u8

  final int bendAngle; // i16
  final int expAngle; // i16

  final int status; // u8

  const Form20SystemSettings({
    required this.maxLoad,
    required this.speed,
    required this.cycles,
    required this.durationMin,
    required this.stopByCycles,
    required this.stopByTime,
    required this.bendAngle,
    required this.expAngle,
    required this.status,
  });

  static const int payloadLength = 25;

  factory Form20SystemSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form20 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form20SystemSettings(
      maxLoad: bd.getUint16(0, Endian.little),
      speed: bd.getUint16(2, Endian.little),
      cycles: bd.getUint16(6, Endian.little),
      durationMin: bd.getUint16(8, Endian.little),

      stopByCycles: bd.getUint8(10) != 0,
      stopByTime: bd.getUint8(11) != 0,

      bendAngle: bd.getInt16(12, Endian.little),
      expAngle: bd.getInt16(14, Endian.little),

      status: bd.getUint8(24),
    );
  }
}