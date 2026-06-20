import 'dart:typed_data';
import 'abstract/form.dart';

class Form24ActiveWarmupSettings extends Form {
  @override
  int get formId => 24;

  final int step; // u16

  Form24ActiveWarmupSettings({
    required this.step,
  });

  static const int payloadLength = 2;

  factory Form24ActiveWarmupSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form30ActiveWarmupSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form24ActiveWarmupSettings(
      step: bd.getUint16(0, Endian.little),
    );
  }

  @override
  Uint8List encodePayload() {
    final b = ByteData(payloadLength);
    b.setUint16(0, step, Endian.little);
    return b.buffer.asUint8List();
  }
}