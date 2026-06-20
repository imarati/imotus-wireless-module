import 'dart:typed_data';
import 'abstract/form.dart';

class Form38ActiveComfortSettings extends Form {
  @override
  int get formId => 38;

  final int step; // u16
  final int bendDeviation; // i16
  final int expDeviation; // i16

  Form38ActiveComfortSettings({
    required this.step,
    required this.bendDeviation,
    required this.expDeviation,
  });

  static const int payloadLength = 6;

  factory Form38ActiveComfortSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form32ActiveComfortSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form38ActiveComfortSettings(
      step: bd.getUint16(0, Endian.little),
      bendDeviation: bd.getInt16(2, Endian.little),
      expDeviation: bd.getInt16(4, Endian.little),
    );
  }

  @override
  Uint8List encodePayload() {
    final b = ByteData(payloadLength);
    b.setUint16(0, step, Endian.little);
    b.setInt16(2, bendDeviation, Endian.little);
    b.setInt16(4, expDeviation, Endian.little);
    return b.buffer.asUint8List();
  }
}