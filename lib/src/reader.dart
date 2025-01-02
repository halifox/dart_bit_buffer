import 'package:bit_buffer/bit_buffer.dart';

class BitBufferReader {
  int _position = 0;
  final BitBuffer _buffer;

  BitBufferReader(this._buffer);

  void skip(int offset) {
    _position += offset;
  }

  void seekTo(int position) {
    _position = position;
  }

  bool getBool() {
    return getBit() != 0;
  }

  int getBit() {
    int value = _buffer.getBit(_position);
    _position += 1;
    return value;
  }

  int getInt({
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    int number = getUnsignedInt(binaryDigits: binaryDigits, order: order);
    int isNegative = (number >> (binaryDigits - 1)) & 1;
    if (isNegative != 0) {
      int mask = (1 << (binaryDigits - 1)) - 1;
      number = -1 * (~(number - 1) & mask);
    }
    return number;
  }

  int getUnsignedInt({
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    int value = 0;
    for (int i = 0; i < binaryDigits; i++) {
      int position = _position + binaryDigits - 1 - i;
      if (order == BitOrder.MSBFirst) {
        position = _position + i;
      }
      value |= (_buffer.getBit(position) << (binaryDigits - 1 - i));
    }
    _position += binaryDigits;
    return value;
  }
}
