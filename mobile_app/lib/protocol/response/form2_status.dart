import 'dart:typed_data';

class Form2Status {
  final int timestamp; // u32
  final int angle; // i16
  final int load; // i16
  final int status; // u8

  const Form2Status({
    required this.timestamp,
    required this.angle,
    required this.load,
    required this.status,
  });

  static const int payloadLength = 9;

  factory Form2Status.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form2 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);
    return Form2Status(
      timestamp: bd.getUint32(0, Endian.little),
      angle: bd.getInt16(4, Endian.little),
      load: bd.getInt16(6, Endian.little),
      status: bd.getUint8(8),
    );
  }
}