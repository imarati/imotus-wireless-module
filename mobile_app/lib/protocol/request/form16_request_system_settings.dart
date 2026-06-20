import 'dart:typed_data';

import '../abstract/form.dart';

class Form16RequestSystemSettings extends Form {
  @override
  int get formId => 16;

  @override
  Uint8List encodePayload() => Uint8List(0);
}