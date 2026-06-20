import 'dart:typed_data';
import '../abstract/form.dart';

class Form14ActiveCmd extends Form {
  @override
  int get formId => 14;

  static const int stop = 0;
  static const int start = 1;
  static const int pause = 2;

  final int cmd;

  Form14ActiveCmd(this.cmd);

  @override
  Uint8List encodePayload() {
    return Uint8List.fromList([cmd]);
  }
}