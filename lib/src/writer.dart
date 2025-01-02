import 'package:bit_buffer/bit_buffer.dart';

class BitBufferWriter {
  /// 当前写入位置，以比特为单位。
  int _position = 0;

  /// 关联的 `BitBuffer` 对象，用于存储写入的比特。
  final BitBuffer _buffer;

  /// 构造函数，初始化 `BitBufferWriter` 并与指定的 `BitBuffer` 关联。
  BitBufferWriter(this._buffer);

  /// 跳过指定数量的比特位置。
  ///
  /// ### 参数:
  /// - `offset`: 要跳过的比特数量。可以是正数（向前跳跃）或负数（向后跳跃）。
  ///
  /// ### 功能:
  /// - 更新读取/写入位置 `_position`，通过加上 `offset` 值来跳过指定的比特位置。
  ///
  /// ### 注意:
  /// - 调用此方法后，`_position` 会根据 `offset` 更新。如果 `offset` 是负值，`_position` 会向回移动。
  /// - 此方法不会对缓冲区内容进行修改，仅更新当前位置。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.skip(5); // 跳过 5 个比特位置
  /// writer.skip(-3); // 向回跳过 3 个比特位置
  /// ```
  void skip(int offset) {
    _position += offset;
  }

  /// 将读取/写入位置移动到指定的位置，并在需要时扩展缓冲区。
  ///
  /// ### 参数:
  /// - `position`: 要设置的新位置。
  ///
  /// ### 功能:
  /// - 将内部的读取/写入位置 `_position` 更新为指定的 `position`。
  /// - 如果新的位置超出了当前缓冲区大小，则扩展缓冲区以确保位置合法。
  ///
  /// ### 注意:
  /// - 如果 `position` 超出当前缓冲区大小，方法会自动扩展缓冲区。
  /// - 调用此方法后，`_position` 会被更新为指定的 `position`。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.seekTo(10); // 将写入位置设置为 10
  /// ```
  void seekTo(int position) {
    _position = position;
    if (_position > _buffer.size) {
      _buffer.allocate(_position - _buffer.size); // 扩展缓冲区以适应新的位置。
    }
  }

  /// 如果缓冲区空间不足，自动分配足够的空间来存储指定数量的比特。
  ///
  /// ### 参数:
  /// - `bits`: 需要的比特数量。
  ///
  /// ### 功能:
  /// - 检查当前缓冲区是否有足够的空间来存储 `bits` 数量的比特。
  /// - 如果空间不足，则调用 `allocate` 方法进行扩展。
  ///
  /// ### 注意:
  /// - 该方法不会直接写入比特，只是保证在写入前缓冲区有足够的空间。
  /// - 调用此方法后，写入位置 `_position` 不会改变。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.allocateIfNeeded(10); // 确保缓冲区至少有 10 个比特的空间。
  /// ```
  void allocateIfNeeded(int bits) {
    if (_position + bits > _buffer.size) {
      _buffer.allocate(bits);
    }
  }

  /// 将一个布尔值写入 `BitBuffer` 中，布尔值会转换为比特值（0 或 1）。
  ///
  /// ### 参数:
  /// - `value`: 要写入的布尔值，`true` 会转换为 1，`false` 会转换为 0。
  ///
  /// ### 功能:
  /// - 将布尔值转换为比特值并写入缓冲区。
  /// - 调用 `putBit` 方法来写入 1 或 0。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putBool(true); // 写入 "1"
  /// writer.putBool(false); // 写入 "0"
  /// print(buffer.toString()); // 输出: "10"
  /// ```
  void putBool(bool value) {
    putBit(value ? 1 : 0);
  }

  /// 将一个比特值写入 `BitBuffer` 中。
  ///
  /// ### 参数:
  /// - `value`: 要写入的比特值，0 或 1。
  ///
  /// ### 功能:
  /// - 将一个比特（0 或 1）写入缓冲区指定的位置。
  /// - 确保缓冲区有足够的空间进行写入。
  ///
  /// ### 注意:
  /// - 如果缓冲区剩余空间不足，方法会自动扩展缓冲区。
  /// - 写入完成后，写入位置 `_position` 会自动更新。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putBit(1); // 写入 "1"
  /// writer.putBit(0); // 写入 "0"
  /// print(buffer.toString()); // 输出: "10"
  /// ```
  void putBit(int value) {
    allocateIfNeeded(1); // 确保有足够空间写入一个比特。
    _buffer.setBit(_position, value); // 设置指定位置的比特值。
    _position += 1; // 更新写入位置。
  }

  /// 将一个有符号整数写入 `BitBuffer` 中，按照指定的位数和位序进行编码。
  ///
  /// ### 参数:
  /// - `value`: 要写入的有符号整数。
  /// - `binaryDigits` (可选): 使用的二进制位数。
  ///   - 默认值: 64 位。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 将整数值写入缓冲区，并根据 `binaryDigits` 指定的位数进行编码。
  /// - 对负数进行补码处理，确保能够正确地表示负数。
  ///
  /// ### 处理:
  /// - 如果整数为负数，先将其转换为补码格式。
  /// - 然后调用 `putUnsignedInt` 方法将其作为无符号整数写入。
  ///
  /// ### 注意:
  /// - 如果缓冲区剩余空间不足，方法会自动扩展缓冲区。
  /// - 负数值会被转换为补码格式。
  /// - 调用此方法后，写入位置 `_position` 会自动更新。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putInt(5, binaryDigits: 8); // 写入 "00000101"
  /// writer.putInt(-5, binaryDigits: 8); // 写入补码 "-5" 对应的 "11111011"
  /// print(buffer.toString()); // 输出: "0000010111111011"
  /// ```
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

  /// 写入一个无符号整数到 `BitBuffer` 中，按照指定的位数和位序进行编码。
  ///
  /// ### 参数:
  /// - `value`: 要写入的无符号整数。
  /// - `binaryDigits` (可选): 使用的二进制位数。
  ///   - 默认值: 64 位。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 按位将整数值写入缓冲区。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 如果缓冲区剩余空间不足，方法会自动扩展缓冲区。
  /// - 如果 `binaryDigits` 大于实际整数的位数，整数高位将补零。
  /// - 调用此方法后，写入位置 `_position` 会自动更新。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putUnsignedInt(5, binaryDigits: 4); // 写入 "0101"
  /// writer.putUnsignedInt(3, binaryDigits: 3, order: BitOrder.LSBFirst); // 写入 "011"
  /// print(buffer.toString()); // 输出: "0101011"
  /// ```
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
