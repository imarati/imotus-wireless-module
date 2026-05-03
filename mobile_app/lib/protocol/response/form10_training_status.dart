import 'dart:typed_data';

class Form10TrainingStatus {
  final int elapsedSeconds; // u16
  final int doneCycles; // u16
  final int status; // u8

  Form10TrainingStatus({
    required this.elapsedSeconds,
    required this.doneCycles,
    required this.status,
  });

  static const int payloadLength = 5;

  factory Form10TrainingStatus.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form10 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);
    return Form10TrainingStatus(
      elapsedSeconds: bd.getInt16(0, Endian.little),
      doneCycles: bd.getUint16(2, Endian.little),
      status: bd.getUint8(4),
    );
  }
}