import 'dart:typed_data';

class Form17ActiveSettings {
  final int cycles; // u16
  final int durationMin; // u16
  final bool stopByCycles; // u8
  final bool stopByTime; // u8
  final int speed; // u16
  final int maxLoad; // u16

  final int bendAngle; // i16
  final int expAngle; // i16

  final int bendAssistAngle; // i16
  final int expAssistAngle; // i16

  final int bendLoad; // i16
  final int expLoad; // i16

  final int status; // u8

  const Form17ActiveSettings({
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
    required this.status,
  });

  static const int payloadLength = 23;

  factory Form17ActiveSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form17 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form17ActiveSettings(
      cycles: bd.getUint16(0, Endian.little),
      durationMin: bd.getUint16(2, Endian.little),
      stopByCycles: bd.getUint8(4) != 0,
      stopByTime: bd.getUint8(5) != 0,
      speed: bd.getUint16(6, Endian.little),
      maxLoad: bd.getUint16(8, Endian.little),

      bendAngle: bd.getInt16(10, Endian.little),
      expAngle: bd.getInt16(12, Endian.little),

      bendAssistAngle: bd.getInt16(14, Endian.little),
      expAssistAngle: bd.getInt16(16, Endian.little),

      bendLoad: bd.getInt16(18, Endian.little),
      expLoad: bd.getInt16(20, Endian.little),

      status: bd.getUint8(22),
    );
  }
}