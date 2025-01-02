import 'package:bit_buffer/bit_buffer.dart';

class BitBufferWriter {
  /// 当前写入位置，以比特为单位。
  int _position = 0;

  /// 关联的 `BitBuffer` 对象，用于存储写入的比特。
  final BitBuffer _buffer;

  /// 构造函数，初始化 `BitBufferWriter` 并与指定的 `BitBuffer` 关联。
  BitBufferWriter(this._buffer);

  /// 跳过指定数量的比特，更新当前写入位置。
  void skip(int offset) {
    _position += offset;
  }

  /// 将写入位置移动到指定位置，如果超出缓冲区大小，则扩展缓冲区。
  void seekTo(int position) {
    _position = position;
    if (_position > _buffer.size) {
      _buffer.allocate(_position - _buffer.size); // 扩展缓冲区以适应新的位置。
    }
  }

  /// 如果当前写入位置不足以写入指定的比特数，则扩展缓冲区。
  void allocateIfNeeded(int bits) {
    if (_position + bits > _buffer.size) {
      _buffer.allocate(bits);
    }
  }

  /// 写入一个布尔值，将其转换为比特值（1 表示 true，0 表示 false）。
  void putBool(bool value) {
    putBit(value ? 1 : 0);
  }

  /// 写入一个比特值（0 或 1）。
  void putBit(int value) {
    allocateIfNeeded(1); // 确保有足够空间写入一个比特。
    _buffer.setBit(_position, value); // 设置指定位置的比特值。
    _position += 1; // 更新写入位置。
  }

  /// 写入一个有符号整数值。
  ///
  /// - [value]: 要写入的整数值。
  /// - [binaryDigits]: 使用的二进制位数，默认为 64。
  /// - [order]: 指定比特写入顺序（从最高有效位或最低有效位开始）。
  void putInt(
    int value, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    if (value.isNegative) {
      // 处理负数值，转换为补码形式。
      int mask = (1 << binaryDigits) - 1;
      value = ~(-value); // 取反。
      value += 1; // 加 1 形成补码。
      value &= mask; // 保留指定位数。
    }
    putUnsignedInt(value, binaryDigits: binaryDigits, order: order);
  }

  /// 写入一个无符号整数值。
  ///
  /// - [value]: 要写入的无符号整数值。
  /// - [binaryDigits]: 使用的二进制位数，默认为 64。
  /// - [order]: 指定比特写入顺序（从最高有效位或最低有效位开始）。
  void putUnsignedInt(
    int value, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    allocateIfNeeded(binaryDigits); // 确保有足够空间写入指定位数的整数。
    for (int i = 0; i < binaryDigits; i++) {
      // 提取当前位的值。
      int bit = (value >> i) & 1;

      // 根据顺序确定实际写入位置。
      int index = _position + i;
      if (order == BitOrder.MSBFirst) {
        index = _position + binaryDigits - 1 - i;
      }

      // 写入比特值到指定位置。
      _buffer.setBit(index, bit);
    }
    _position += binaryDigits; // 更新写入位置。
  }
}
