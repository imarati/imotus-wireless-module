import 'dart:typed_data';
import '../abstract/form.dart';

class Form9PassiveCmd extends Form {
  @override
  int get formId => 9;

  final int cmd;

  Form9PassiveCmd(this.cmd);

  @override
  Uint8List encodePayload() {
    return Uint8List.fromList([cmd & 0xFF]);
  }
}