import 'dart:typed_data';

import '../abstract/form.dart';

class Form21RequestPatientInfo extends Form {
  @override
  int get formId => 21;

  @override
  Uint8List encodePayload() => Uint8List(0);
}