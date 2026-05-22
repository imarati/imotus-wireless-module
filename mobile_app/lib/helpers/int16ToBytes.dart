import 'dart:typed_data';

Uint8List int16ToBytes(int value) {
  final bytes = Uint8List(2);
  final bd = bytes.buffer.asByteData();
  bd.setInt16(0, value, Endian.little); // little-endian
  return bytes;
}
