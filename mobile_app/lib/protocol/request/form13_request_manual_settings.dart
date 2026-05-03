import 'dart:typed_data';
import '../abstract/form.dart';

class Form13RequestManualSettings extends Form {
  @override
  int get formId => 13;

  @override
  Uint8List encodePayload() => Uint8List(0);
}