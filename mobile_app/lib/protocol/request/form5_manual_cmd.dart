import 'dart:typed_data';
import '../abstract/form.dart';

class Form5ManualCmd extends Form {
  @override
  int get formId => 5;

  final int cmd; // 0 = IDLE, 1 = LEFT, 2 = RIGHT

  Form5ManualCmd(this.cmd);

  @override
  Uint8List encodePayload() {
    return Uint8List.fromList([cmd]);
  }
}