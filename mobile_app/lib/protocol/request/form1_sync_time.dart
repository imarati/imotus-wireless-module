import 'dart:typed_data';
import '../abstract/form.dart';

class Form1SyncTime extends Form {
  @override
  int get formId => 1;

  final int timestamp; // u32

  Form1SyncTime(this.timestamp);

  @override
  Uint8List encodePayload() {
    final b = ByteData(4);
    b.setUint32(0, timestamp, Endian.little);
    return b.buffer.asUint8List();
  }
}