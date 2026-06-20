import 'dart:typed_data';
import 'abstract/form.dart';

class Form39PassiveFunctions extends Form {
  @override
  int get formId => 39;

  final bool extendBendEnabled; // u8
  final bool extendExpEnabled;  // u8
  final int extendRepeats;      // u16

  Form39PassiveFunctions({
    required this.extendBendEnabled,
    required this.extendExpEnabled,
    required this.extendRepeats,
  });

  static const int payloadLength = 4;

  factory Form39PassiveFunctions.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form39PassiveFunctions payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form39PassiveFunctions(
      extendBendEnabled: bd.getUint8(0) != 0,
      extendExpEnabled: bd.getUint8(1) != 0,
      extendRepeats: bd.getUint16(2, Endian.little),
    );
  }

  @override
  Uint8List encodePayload() {
    final b = ByteData(payloadLength);
    b.setUint8(0, extendBendEnabled ? 1 : 0);
    b.setUint8(1, extendExpEnabled ? 1 : 0);
    b.setUint16(2, extendRepeats, Endian.little);
    return b.buffer.asUint8List();
  }
}