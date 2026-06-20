import 'dart:typed_data';
import 'abstract/form.dart';

class Form34PassiveCooldownSettings extends Form {
  @override
  int get formId => 34;

  final int step; // u16

  Form34PassiveCooldownSettings({
    required this.step,
  });

  static const int payloadLength = 2;

  factory Form34PassiveCooldownSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form35PassiveCooldownSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form34PassiveCooldownSettings(
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