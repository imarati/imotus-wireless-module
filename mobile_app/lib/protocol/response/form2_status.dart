import 'dart:typed_data';

class Form2Status {
  final DateTime dateTime;
  final int angle; // i16
  final int load;  // i16
  final int status; // u8

  const Form2Status({
    required this.dateTime,
    required this.angle,
    required this.load,
    required this.status,
  });

  static const int payloadLength = 12;

  factory Form2Status.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form2 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    final year   = bd.getUint16(0, Endian.little);
    final month  = bd.getUint8(2);
    final day    = bd.getUint8(3);
    final hour   = bd.getUint8(4);
    final minute = bd.getUint8(5);
    final second = bd.getUint8(6);

    return Form2Status(
      dateTime: DateTime(year, month, day, hour, minute, second),
      angle:    bd.getInt16(7, Endian.little),
      load:     bd.getInt16(9, Endian.little),
      status:   bd.getUint8(11),
    );
  }
}