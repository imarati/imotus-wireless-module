import 'dart:typed_data';

import '../abstract/form.dart';

class Form19RequestSystemSettings extends Form {
  @override
  int get formId => 19;

  @override
  Uint8List encodePayload() => Uint8List(0);
}