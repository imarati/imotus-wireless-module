import 'dart:typed_data';
import '../abstract/form.dart';

class Form6UpdateManualSettings extends Form {
  @override
  int get formId => 6;

  final int maxLoad; // u16
  final int manualSpeed; // u16

  Form6UpdateManualSettings({
    required this.maxLoad,
    required this.manualSpeed,
  });

  @override
  Uint8List encodePayload() {
    final b = ByteData(4);
    b.setUint16(0, maxLoad, Endian.little);
    b.setUint16(2, manualSpeed, Endian.little);
    return b.buffer.asUint8List();
  }
}