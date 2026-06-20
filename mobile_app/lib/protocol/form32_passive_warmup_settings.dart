import 'dart:typed_data';
import 'abstract/form.dart';

class Form32PassiveWarmupSettings extends Form {
  @override
  int get formId => 32;

  final int step; // u16

  Form32PassiveWarmupSettings({
    required this.step,
  });

  static const int payloadLength = 2;

  factory Form32PassiveWarmupSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form34PassiveWarmupSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form32PassiveWarmupSettings(
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