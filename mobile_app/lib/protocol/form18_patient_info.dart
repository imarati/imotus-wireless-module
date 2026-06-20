import 'dart:typed_data';
import 'package:enough_convert/enough_convert.dart';

import 'abstract/form.dart';

class Form18PatientInfo extends Form {
  @override
  int get formId => 18;

  final String surname;
  final String name;
  final String patronymic;
  final String patientId;

  Form18PatientInfo({
    required this.surname,
    required this.name,
    required this.patronymic,
    required this.patientId,
  });

  static const int surnameLength = 20;
  static const int nameLength = 20;
  static const int patronymicLength = 20;
  static const int patientIdLength = 20;

  static const int payloadLength =
      surnameLength + nameLength + patronymicLength + patientIdLength;

  static const Koi8rCodec _koi8r = Koi8rCodec();

  factory Form18PatientInfo.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form18PatientInfo payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    int offset = 0;

    final surnameBytes = payload.sublist(offset, offset + surnameLength);
    offset += surnameLength;

    final nameBytes = payload.sublist(offset, offset + nameLength);
    offset += nameLength;

    final patronymicBytes = payload.sublist(offset, offset + patronymicLength);
    offset += patronymicLength;

    final patientIdBytes = payload.sublist(offset, offset + patientIdLength);

    return Form18PatientInfo(
      surname: _decodeFixedString(surnameBytes),
      name: _decodeFixedString(nameBytes),
      patronymic: _decodeFixedString(patronymicBytes),
      patientId: _decodeFixedString(patientIdBytes),
    );
  }

  @override
  Uint8List encodePayload() {
    final bytes = Uint8List(payloadLength);

    int offset = 0;
    _writeFixedString(bytes, offset, surnameLength, surname);
    offset += surnameLength;

    _writeFixedString(bytes, offset, nameLength, name);
    offset += nameLength;

    _writeFixedString(bytes, offset, patronymicLength, patronymic);
    offset += patronymicLength;

    _writeFixedString(bytes, offset, patientIdLength, patientId);

    return bytes;
  }

  static String _decodeFixedString(List<int> bytes) {
    final zeroIndex = bytes.indexOf(0);
    final trimmed = zeroIndex >= 0 ? bytes.sublist(0, zeroIndex) : bytes;
    return _koi8r.decode(trimmed).trim();
  }

  static void _writeFixedString(
      Uint8List target,
      int offset,
      int fieldLength,
      String value,
      ) {
    final encoded = _koi8r.encode(value.trim());

    final maxDataLength = fieldLength - 1;
    final count = encoded.length > maxDataLength ? maxDataLength : encoded.length;

    for (int i = 0; i < count; i++) {
      target[offset + i] = encoded[i];
    }

    target[offset + count] = 0;

    for (int i = count + 1; i < fieldLength; i++) {
      target[offset + i] = 0;
    }
  }
}