import 'dart:typed_data';
import '../abstract/form.dart';

class Form4SetTargetAngle extends Form {
  @override
  int get formId => 4;

  final int targetAngle; // i16

  Form4SetTargetAngle(this.targetAngle);

  @override
  Uint8List encodePayload() {
    final b = ByteData(2);
    b.setInt16(0, targetAngle, Endian.little);
    return b.buffer.asUint8List();
  }
}