import 'dart:typed_data';
import 'abstract/form.dart';

class Form30PassiveProcedures extends Form {
  @override
  int get formId => 30;

  final bool warmupEnabled;   // u8
  final bool cooldownEnabled; // u8
  final bool comfortEnabled;  // u8

  Form30PassiveProcedures({
    required this.warmupEnabled,
    required this.cooldownEnabled,
    required this.comfortEnabled,
  });

  static const int payloadLength = 3;

  factory Form30PassiveProcedures.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form33PassiveProcedures payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    return Form30PassiveProcedures(
      warmupEnabled: bd.getUint8(0) != 0,
      cooldownEnabled: bd.getUint8(1) != 0,
      comfortEnabled: bd.getUint8(2) != 0,
    );
  }

  @override
  Uint8List encodePayload() {
    final b = ByteData(payloadLength);
    b.setUint8(0, warmupEnabled ? 1 : 0);
    b.setUint8(1, cooldownEnabled ? 1 : 0);
    b.setUint8(2, comfortEnabled ? 1 : 0);
    return b.buffer.asUint8List();
  }
}