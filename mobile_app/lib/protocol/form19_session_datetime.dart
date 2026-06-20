import 'dart:typed_data';
import 'abstract/form.dart';

class Form19SessionDateTime extends Form {
  @override
  int get formId => 19;

  final DateTime sessionDate;
  final int hour;
  final int minute;
  final int second;

  Form19SessionDateTime({
    required this.sessionDate,
    required this.hour,
    required this.minute,
    required this.second,
  });

  static const int payloadLength = 7;

  factory Form19SessionDateTime.fromPayload(Uint8List payload) {
    if (payload.length < payloadLength) {
      throw ArgumentError(
        'Form23SessionDateTime payload too short: ${payload.length}, expected $payloadLength',
      );
    }

    final bd = ByteData.sublistView(payload);

    final year = bd.getUint16(0, Endian.little);
    final month = bd.getUint8(2);
    final day = bd.getUint8(3);
    final hour = bd.getUint8(4);
    final minute = bd.getUint8(5);
    final second = bd.getUint8(6);

    return Form19SessionDateTime(
      sessionDate: DateTime(year, month, day),
      hour: hour,
      minute: minute,
      second: second,
    );
  }

  @override
  Uint8List encodePayload() {
    final bytes = Uint8List(payloadLength);
    final bd = bytes.buffer.asByteData();

    bd.setUint16(0, sessionDate.year, Endian.little);
    bd.setUint8(2, sessionDate.month);
    bd.setUint8(3, sessionDate.day);
    bd.setUint8(4, hour);
    bd.setUint8(5, minute);
    bd.setUint8(6, second);

    return bytes;
  }
}