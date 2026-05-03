import 'dart:typed_data';
import '../abstract/form.dart';

class Form16ActiveCmd extends Form {
  @override
  int get formId => 16;

  static const int stop = 0;
  static const int start = 1;
  static const int pause = 2;

  final int cmd; // 0=STOP, 1=START, 2=PAUSE

  Form16ActiveCmd(this.cmd);

  @override
  Uint8List encodePayload() {
    return Uint8List.fromList([cmd]);
  }
}