import 'dart:typed_data';
import '../abstract/form.dart';

class Form7RequestInit extends Form {
  @override
  int get formId => 7;

  @override
  Uint8List encodePayload() => Uint8List(0);
}