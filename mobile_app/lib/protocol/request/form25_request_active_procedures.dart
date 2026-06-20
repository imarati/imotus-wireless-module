import 'dart:typed_data';
import '../abstract/form.dart';

class Form25RequestActiveProcedures extends Form {
  @override
  int get formId => 25;

  @override
  Uint8List encodePayload() => Uint8List(0);
}