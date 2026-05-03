import 'dart:typed_data';

Uint8List uint32ToBytes(int value) {
  final bytes = Uint8List(4);
  final bd = bytes.buffer.asByteData();
  bd.setUint32(0, value, Endian.little);
  return bytes;
}
