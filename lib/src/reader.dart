import 'package:bit_buffer/bit_buffer.dart';

class BitBufferReader {
  /// 当前读取位置，以比特为单位。
  int _position = 0;

  int get postion => _position;

  /// 关联的 `BitBuffer` 对象，用于从中读取比特。
  final BitBuffer _buffer;

  /// 构造函数，初始化 `BitBufferReader` 并与指定的 `BitBuffer` 关联。
  BitBufferReader(this._buffer);

  int get remainingSize => _buffer.bitCount - _position;

  /// 跳过指定数量的比特，更新当前读取位置。
  ///
  /// ### 参数:
  /// - `offset`: 要跳过的比特数量。
  ///
  /// ### 功能:
  /// - 将当前读取位置移动 `offset` 个比特。可以用于跳过不需要处理的比特数据。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferReader reader = buffer.reader();
  /// reader.skip(3); // 跳过 3 个比特。
  /// ```
  void skip(int offset) {
    _position += offset;
  }

  /// 将读取位置移动到指定位置。
  ///
  /// ### 参数:
  /// - `position`: 目标位置，读取位置将被更新为该值。
  ///
  /// ### 功能:
  /// - 更新当前读取位置为指定的 `position`。
  /// - 如果新位置超出了当前缓冲区的大小，调用此方法后可以手动调整缓冲区以适应新的位置。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferReader reader = buffer.reader();
  /// reader.seekTo(10); // 将读取位置移动到第 10 位。
  /// ```
  void seekTo(int position) {
    _position = position;
  }

  /// 从当前读取位置获取一个布尔值（true 或 false）。
  ///
  /// ### 功能:
  /// - 调用 `getBit()` 获取当前比特值，并根据比特值返回对应的布尔值。
  ///
  /// ### 注意:
  /// - 每次调用后，读取位置会更新到下一个比特。
  /// - 适用于从比特流中读取布尔值（即 `true` 或 `false`）。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferReader reader = buffer.reader();
  /// bool value = reader.getBool(); // 获取布尔值。
  /// ```
  bool getBool() {
    return getBit() != 0;
  }

  /// 从当前读取位置获取一个比特值，并更新读取位置。
  ///
  /// ### 功能:
  /// - 读取当前 `_position` 位置的比特值。
  /// - 每次调用后，自动将 `_position` 向后移动一位，以便读取下一个比特。
  ///
  /// ### 注意:
  /// - 调用此方法后，读取位置会更新，指向下一个比特。
  /// - 如果需要逐个读取比特流中的所有比特，可以多次调用此方法。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferReader reader = buffer.reader();
  /// int bit = reader.getBit(); // 获取当前比特值，并更新位置。
  /// ```
  int getBit() {
    int value = _buffer.getBit(_position); // 从当前读取位置获取比特值。
    _position += 1; // 更新读取位置。
    return value;
  }

  /// 从缓冲区读取指定数量的有符号整数，按给定的顺序解析每个位。
  ///
  /// ### 参数:
  /// - `binaryDigits`: 要读取的比特数（默认 64 位）。
  /// - `order`: 比特读取的顺序，默认为 `BitOrder.MSBFirst`（从高位到低位读取）。
  ///
  /// ### 功能:
  /// - 从当前读取位置开始，按给定的顺序读取指定数量的比特。
  /// - 根据符号位判断整数是否为负数，并进行补码转换。
  /// - 更新 `_position` 到读取后的新位置。
  ///
  /// ### 注意:
  /// - 如果使用 `BitOrder.MSBFirst`，则从高位到低位读取比特；如果使用 `BitOrder.LSBFirst`，则从低位到高位读取比特。
  /// - 该方法适用于读取有符号整数。如果需要读取无符号整数，请使用 `getUnsignedInt` 方法。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferReader reader = buffer.reader();
  /// int value = reader.getInt(binaryDigits: 16, order: BitOrder.MSBFirst);
  /// ```
  int getInt({
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    int value = _buffer.getInt(_position, binaryDigits: binaryDigits, order: order);
    _position += binaryDigits; // 更新读取位置。
    return value;
  }

  /// 从 `BitBuffer` 中读取一个有符号大整数，按照指定的位数和位序进行解码。
  ///
  /// ### 参数:
  /// - `binaryDigits` (可选): 使用的二进制位数。
  ///   - 默认值: 128 位。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 按位从缓冲区读取有符号大整数。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 调用此方法后，读取位置 `_position` 会自动更新。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putBigInt(BigInt.from(-123456), binaryDigits: 128);
  /// BigInt value = writer.getBigInt(binaryDigits: 128);
  /// print(value); // 输出: -123456
  /// ```
  BigInt getBigInt({
    int binaryDigits = 128,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    BigInt value = _buffer.getBigInt(_position, binaryDigits: binaryDigits, order: order);
    _position += binaryDigits; // 更新读取位置。
    return value;
  }

  /// 从缓冲区读取指定数量的无符号整数，按给定的顺序解析每个位。
  ///
  /// ### 参数:
  /// - `binaryDigits`: 要读取的比特数（默认 64 位）。
  /// - `order`: 比特读取的顺序，默认为 `BitOrder.MSBFirst`（从高位到低位读取）。
  ///
  /// ### 功能:
  /// - 从当前读取位置开始，按给定的顺序读取指定数量的无符号整数。
  /// - 将读取到的比特值依次拼接，形成一个无符号整数。
  /// - 更新 `_position` 到读取后的新位置。
  ///
  /// ### 注意:
  /// - 如果使用 `BitOrder.MSBFirst`，则从高位到低位读取比特；如果使用 `BitOrder.LSBFirst`，则从低位到高位读取比特。
  /// - 该方法适用于读取无符号整数。如果需要读取有符号整数，请使用 `getInt` 方法。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferReader reader = buffer.reader();
  /// int value = reader.getUnsignedInt(binaryDigits: 16, order: BitOrder.LSBFirst);
  /// ```
  int getUnsignedInt({
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    int value = _buffer.getUnsignedInt(_position, binaryDigits: binaryDigits, order: order);
    _position += binaryDigits; // 更新读取位置。
    return value;
  }

  /// 从 `BitBuffer` 中读取一个无符号大整数，按照指定的位数和位序进行解码。
  ///
  /// ### 参数:
  /// - `binaryDigits` (可选): 使用的二进制位数。
  ///   - 默认值: 128 位。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 按位从缓冲区读取无符号大整数。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 调用此方法后，读取位置 `_position` 会自动更新。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putUnsignedBigInt(BigInt.from(123456), binaryDigits: 128);
  /// BigInt value = writer.getUnsignedBigInt(binaryDigits: 128);
  /// print(value); // 输出: 123456
  /// ```
  BigInt getUnsignedBigInt({
    int binaryDigits = 128,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    BigInt value = _buffer.getUnsignedBigInt(_position, binaryDigits: binaryDigits, order: order);
    _position += binaryDigits; // 更新读取位置。
    return value;
  }
}
