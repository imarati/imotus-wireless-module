import 'dart:typed_data';
import '../abstract/form.dart';

class Form9PassiveCmd extends Form {
  @override
  int get formId => 9;

  /// 0 = STOP, 1 = START/CONTINUE, 2 = PAUSE
  final int cmd;

  Form9PassiveCmd(this.cmd);

  @override
  Uint8List encodePayload() {
    return Uint8List.fromList([cmd & 0xFF]);
  }
}