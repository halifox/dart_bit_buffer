import 'package:bit_buffer/bit_buffer.dart';

class BitBufferReader {
  /// 当前读取位置，以比特为单位。
  int _position = 0;

  /// 关联的 `BitBuffer` 对象，用于从中读取比特。
  final BitBuffer _buffer;

  /// 构造函数，初始化 `BitBufferReader` 并与指定的 `BitBuffer` 关联。
  BitBufferReader(this._buffer);

  /// 跳过指定数量的比特，更新当前读取位置。
  void skip(int offset) {
    _position += offset;
  }

  /// 将读取位置移动到指定位置。
  void seekTo(int position) {
    _position = position;
  }

  /// 读取一个布尔值（true 或 false），根据比特值判断。
  bool getBool() {
    return getBit() != 0;
  }

  /// 读取一个比特值（0 或 1），并更新当前读取位置。
  int getBit() {
    int value = _buffer.getBit(_position); // 从当前读取位置获取比特值。
    _position += 1; // 更新读取位置。
    return value;
  }

  /// 读取一个有符号整数值。
  ///
  /// - [binaryDigits]: 使用的二进制位数，默认为 64。
  /// - [order]: 指定比特读取顺序（从最高有效位或最低有效位开始）。
  int getInt({
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    // 先读取无符号整数值。
    int number = getUnsignedInt(binaryDigits: binaryDigits, order: order);

    // 检查符号位，判断是否为负数。
    int isNegative = (number >> (binaryDigits - 1)) & 1;

    if (isNegative != 0) {
      // 如果是负数，转换为补码表示的有符号整数。
      int mask = (1 << (binaryDigits - 1)) - 1; // 获取有效位的掩码。
      number = -1 * (~(number - 1) & mask); // 还原负数值。
    }

    return number;
  }

  /// 读取一个无符号整数值。
  ///
  /// - [binaryDigits]: 使用的二进制位数，默认为 64。
  /// - [order]: 指定比特读取顺序（从最高有效位或最低有效位开始）。
  int getUnsignedInt({
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    int value = 0;

    // 根据指定的顺序依次读取每个位。
    for (int i = 0; i < binaryDigits; i++) {
      // 计算当前比特位置。
      int position = _position + binaryDigits - 1 - i;
      if (order == BitOrder.MSBFirst) {
        position = _position + i;
      }

      // 将读取的比特值按权重累加到结果值中。
      value |= (_buffer.getBit(position) << (binaryDigits - 1 - i));
    }

    _position += binaryDigits; // 更新读取位置。
    return value;
  }
}
