import 'dart:typed_data';

class Form11ManualSettings {
  final int maxLoad; // u16
  final int manualSpeed; // u16
  final int status; // u8

  const Form11ManualSettings({
    required this.maxLoad,
    required this.manualSpeed,
    required this.status,
  });

  static const int payloadLength = 5;

  factory Form11ManualSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form11 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form11ManualSettings(
      maxLoad: bd.getUint16(0, Endian.little),
      manualSpeed: bd.getUint16(2, Endian.little),
      status: bd.getUint8(4),
    );
  }
}