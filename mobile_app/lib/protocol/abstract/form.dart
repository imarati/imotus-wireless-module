import 'dart:typed_data';

abstract class Form {
  int get formId;
  Uint8List encodePayload();
}
