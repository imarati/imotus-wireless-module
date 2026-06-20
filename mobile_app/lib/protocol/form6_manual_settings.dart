import 'dart:typed_data';
import 'abstract/form.dart';

class Form6ManualSettings extends Form {
  @override
  int get formId => 6;

  final int maxLoad; // u16
  final int manualSpeed; // u16

  Form6ManualSettings({
    required this.maxLoad,
    required this.manualSpeed,
  });

  static const int payloadLength = 4;

  factory Form6ManualSettings.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form6ManualSettings payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form6ManualSettings(
      maxLoad: bd.getUint16(0, Endian.little),
      manualSpeed: bd.getUint16(2, Endian.little),
    );
  }

  @override
  Uint8List encodePayload() {
    final b = ByteData(payloadLength);
    b.setUint16(0, maxLoad, Endian.little);
    b.setUint16(2, manualSpeed, Endian.little);
    return b.buffer.asUint8List();
  }
}