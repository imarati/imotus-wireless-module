import 'dart:typed_data';
import 'abstract/form.dart';

class Form27ActiveCooldownSettings extends Form {
  @override
  int get formId => 27;

  final int step; // u16

  Form27ActiveCooldownSettings({
    required this.step,
  });

  static const int payloadLength = 2;

  factory Form27ActiveCooldownSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form31ActiveCooldownSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form27ActiveCooldownSettings(
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