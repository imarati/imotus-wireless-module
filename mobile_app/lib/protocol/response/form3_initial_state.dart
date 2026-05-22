import 'dart:typed_data';

class Form3InitialState {
  final int status; // u8

  const Form3InitialState({
    required this.status,
  });

  static const int payloadLength = 1;

  factory Form3InitialState.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form3 payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form3InitialState(
      status: bd.getUint8(0),
    );
  }
}