import 'dart:typed_data';
import '../abstract/form.dart';

class Form15RequestActiveSettings extends Form {
  @override
  int get formId => 15;

  @override
  Uint8List encodePayload() {
    return Uint8List(0);
  }
}