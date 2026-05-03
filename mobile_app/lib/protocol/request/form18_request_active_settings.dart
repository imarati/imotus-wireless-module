import 'dart:typed_data';
import '../abstract/form.dart';

class Form18RequestActiveSettings extends Form {
  @override
  int get formId => 19;

  @override
  Uint8List encodePayload() {
    return Uint8List(0);
  }
}