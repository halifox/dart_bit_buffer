import 'package:bit_buffer/bit_buffer.dart';

class BitBufferWriter {
  int _position = 0;
  final BitBuffer _buffer;

  BitBufferWriter(this._buffer);

  void skip(int offset) {
    _position += offset;
  }

  void seekTo(int position) {
    _position = position;
    if (_position > _buffer.size) {
      _buffer.allocate(_position - _buffer.size);
    }
  }

  void allocateIfNeeded(int bits) {
    if (_position + bits > _buffer.size) {
      _buffer.allocate(bits);
    }
  }

  void putBool(bool value) {
    putBit(value ? 1 : 0);
  }

  void putBit(int value) {
    allocateIfNeeded(1);
    _buffer.setBit(_position, value);
    _position += 1;
  }

  void putInt(
    int value, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    if (value.isNegative) {
      int mask = (1 << binaryDigits) - 1;
      value = ~(-value);
      value += 1;
      value &= mask;
    }
    putUnsignedInt(value, binaryDigits: binaryDigits, order: order);
  }

  void putUnsignedInt(
    int value, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    allocateIfNeeded(binaryDigits);
    for (int i = 0; i < binaryDigits; i++) {
      int bit = (value >> i) & 1;
      int index = _position + i;
      if (order == BitOrder.MSBFirst) {
        index = _position + binaryDigits - 1 - i;
      }
      _buffer.setBit(index, bit);
    }
    _position += binaryDigits;
  }
}
