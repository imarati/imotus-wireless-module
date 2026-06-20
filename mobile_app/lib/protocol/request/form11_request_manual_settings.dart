import 'dart:typed_data';
import '../abstract/form.dart';

class Form11RequestManualSettings extends Form {
  @override
  int get formId => 11;

  @override
  Uint8List encodePayload() => Uint8List(0);
}