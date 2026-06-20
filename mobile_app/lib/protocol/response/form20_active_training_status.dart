import 'dart:typed_data';

class Form20ActiveTrainingStatus {
  final int elapsedSeconds; // u16
  final int doneCycles; // u16
  final int status; // u8

  const Form20ActiveTrainingStatus({
    required this.elapsedSeconds,
    required this.doneCycles,
    required this.status,
  });

  static const int formId = 20;
  static const int payloadLength = 5;

  factory Form20ActiveTrainingStatus.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form24 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form20ActiveTrainingStatus(
      elapsedSeconds: bd.getUint16(0, Endian.little),
      doneCycles: bd.getUint16(2, Endian.little),
      status: bd.getUint8(4),
    );
  }
}