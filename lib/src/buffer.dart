import 'dart:math';
import 'dart:typed_data';

import 'package:bit_buffer/bit_buffer.dart';

class BitBuffer {
  /// 内部字段，存储“位”的整数列表，用于模拟比特缓冲区。
  List<int> _words = [];

  /// 已经使用的比特数，表示缓冲区当前使用了多少位。
  int _size = 0;

  /// 获取当前缓冲区已使用的比特数。
  int get size => _size;

  /// 每个存储单元的位数，通过地址位数来定义，表示一个存储单元的大小。
  final int ADDRESS_BITS_PER_WORD = 6;

  /// 每个存储单元的比特数，等于 2 的 `ADDRESS_BITS_PER_WORD` 次方。
  late final int BITS_PER_WORD = 1 << ADDRESS_BITS_PER_WORD;

  /// 位索引掩码，用于快速计算某个位在存储单元中的位置。
  late final int BIT_INDEX_MASK = BITS_PER_WORD - 1;

  /// 默认构造函数，初始化 BitBuffer。
  BitBuffer();

  /// 从 `Uint8List` 创建一个 `BitBuffer` 实例。
  ///
  /// 每个字节按照 8 个比特写入缓冲区。
  ///
  /// 参数:
  /// - `data`: 包含无符号 8 位整数的列表。
  ///
  /// 返回:
  /// - 一个新的 `BitBuffer` 实例，包含写入的无符号 8 位整数数据。
  ///
  /// 示例:
  /// ```dart
  /// Uint8List values = Uint8List.fromList([1, 2, 3]);
  /// BitBuffer buffer = BitBuffer.formUInt8List(values);
  /// ```
  factory BitBuffer.formUInt8List(Uint8List data) {
    return BitBuffer.formUIntList(data, binaryDigits: 8);
  }

  /// 从无符号整型列表创建一个 `BitBuffer` 实例。
  ///
  /// 每个整型值将按照指定的二进制位数写入缓冲区。
  ///
  /// 参数:
  /// - `data`: 包含无符号整数值的列表。
  /// - `binaryDigits`: 每个整数占用的比特数，默认为 64。
  ///
  /// 返回:
  /// - 一个新的 `BitBuffer` 实例，包含写入的无符号整数数据。
  ///
  /// 示例:
  /// ```dart
  /// List<int> values = [1, 2, 3];
  /// BitBuffer buffer = BitBuffer.formUIntList(values, binaryDigits: 32);
  /// ```
  factory BitBuffer.formUIntList(List<int> data, {int binaryDigits = 64}) {
    BitBuffer bitBuffer = BitBuffer();
    BitBufferWriter writer = bitBuffer.writer();
    for (int value in data) {
      writer.putUnsignedInt(value, binaryDigits: binaryDigits);
    }
    return bitBuffer;
  }

  /// 从整型列表创建一个 `BitBuffer` 实例。
  ///
  /// 每个整型值将按照指定的二进制位数写入缓冲区。
  ///
  /// 参数:
  /// - `data`: 包含整数值的列表。
  /// - `binaryDigits`: 每个整数占用的比特数，默认为 64。
  ///
  /// 返回:
  /// - 一个新的 `BitBuffer` 实例，包含写入的整数数据。
  ///
  /// 示例:
  /// ```dart
  /// List<int> values = [1, -2, 3];
  /// BitBuffer buffer = BitBuffer.formIntList(values, binaryDigits: 32);
  /// ```
  factory BitBuffer.formIntList(List<int> data, {int binaryDigits = 64}) {
    BitBuffer bitBuffer = BitBuffer();
    BitBufferWriter writer = bitBuffer.writer();
    for (int value in data) {
      writer.putInt(value, binaryDigits: binaryDigits);
    }
    return bitBuffer;
  }

  /// 返回一个用于读取的 `BitBufferReader` 实例。
  BitBufferReader reader() => BitBufferReader(this);

  /// 返回一个用于写入的 `BitBufferWriter` 实例。
  BitBufferWriter writer() => BitBufferWriter(this);

  /// 返回一个用于追加比特的 `BitBufferWriter` 实例，并将写入位置设置为当前大小。
  BitBufferWriter append() => writer()..seekTo(_size);

  /// 为 `BitBuffer` 分配指定容量的比特空间。
  ///
  /// ### 参数:
  /// - `capacity`: 需要分配的比特数量。
  ///
  /// ### 功能:
  /// - 使用当前存储单元中剩余的空闲比特。
  /// - 根据需要增加新的存储单元以满足分配需求。
  ///
  /// ### 注意:
  /// - 如果当前存储单元中有空闲比特，会优先使用这些空闲比特。
  /// - 该方法会自动扩展缓冲区的存储单元，不会缩减已有的容量。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(50); // 分配50个位的空间。
  /// print(buffer.size); // 输出: 50
  /// buffer.allocate(20); // 再分配20个位的空间。
  /// print(buffer.size); // 输出: 70
  /// ```
  void allocate(int capacity) {
    // 计算当前剩余的可用比特数。
    int free = _words.length * BITS_PER_WORD - _size;
    if (free > 0) {
      _size += free; // 使用剩余的空闲比特。
      capacity -= free; // 减少所需容量。
    }

    // 如果仍需要容量，则增加存储单元以满足需求。
    while (capacity > 0) {
      _size += min(capacity, BITS_PER_WORD);
      capacity = max(capacity - BITS_PER_WORD, 0);
      _words.add(0); // 增加新的存储单元。
    }

    // 更新大小，防止负容量的意外情况。
    _size += capacity;
  }

  /// 移除超出当前实际大小的多余存储单元，以优化内存使用。
  ///
  /// ### 功能:
  /// - 根据当前使用的比特大小 `_size`，移除未被使用的存储单元。
  /// - 如果存储单元包含多余的空间但仍在使用范围内，不会移除。
  ///
  /// ### 注意:
  /// - 该方法不会改变已分配的比特大小 `_size`，仅调整存储单元数量。
  /// - 只移除完全未使用的存储单元，部分使用的存储单元将保留。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(100); // 分配100个位的空间。
  /// print(buffer.size); // 输出: 100
  /// print(buffer._words.length); // 假设输出: 2
  /// buffer.trim(); // 移除多余的存储单元。
  /// print(buffer._words.length); // 如果多余单元被移除，可能输出: 2
  /// ```
  void trim() {
    int free = _words.length * BITS_PER_WORD - _size;
    // 移除超出当前大小的存储单元。
    while (free > BITS_PER_WORD) {
      _words.removeLast();
      free = _words.length * BITS_PER_WORD - _size;
    }
  }

  /// 将整个缓冲区的比特表示为字符串形式。
  @override
  String toString() {
    return toSectionString(0, _size);
  }

  /// 返回指定范围内比特的字符串表示形式。
  ///
  /// ### 参数:
  /// - `start`: 起始位置（以比特为单位）。
  ///   - 必须在 `[0, size - 1]` 范围内。
  /// - `length`: 要获取的比特长度。
  ///   - 如果指定范围超出缓冲区大小，则返回实际可用的部分。
  ///
  /// ### 返回值:
  /// - `String`: 指定范围内的比特值的字符串表示形式（由 `0` 和 `1` 组成）。
  ///
  /// ### 注意:
  /// - 该方法不会修改缓冲区内容，仅用于获取部分比特的视图。
  /// - 超出缓冲区范围的部分将被自动截断。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(16); // 分配16位缓冲区。
  /// buffer.setBit(0, 1);
  /// buffer.setBit(1, 0);
  /// buffer.setBit(2, 1);
  /// print(buffer.toSectionString(0, 3)); // 输出: "101"
  /// print(buffer.toSectionString(0, 16)); // 输出: "1010000000000000"
  /// ```
  String toSectionString(int start, int length) {
    int end = min(start + length, _size);
    StringBuffer stringBuffer = StringBuffer();
    for (int position = start; position < end; position++) {
      stringBuffer.write(getBit(position)); // 获取每个位并追加到字符串缓冲区。
    }
    return stringBuffer.toString();
  }

  /// 从 `BitBuffer` 中获取指定位置的比特值。
  ///
  /// ### 参数:
  /// - `position`: 要获取的比特索引。
  ///   - 必须在 `[0, size - 1]` 范围内。
  ///
  /// ### 返回值:
  /// - `int`: 指定位置的比特值，取值为 0 或 1。
  ///
  /// ### 异常:
  /// - `RangeError`: 如果 `position` 小于 0 或大于等于缓冲区的大小，将抛出范围错误。
  ///
  /// ### 注意:
  /// - `position` 用于计算存储单元（word）和单元内的比特索引。
  /// - 使用位操作高效地提取比特值。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(32); // 分配32位缓冲区。
  /// buffer.setBit(5, 1); // 将第5个位设置为1。
  /// print(buffer.getBit(5)); // 输出: 1
  /// print(buffer.getBit(0)); // 输出: 0
  /// ```
  int getBit(int position) {
    // 检查位置是否在有效范围内。
    if (position < 0 || position >= _size) {
      throw RangeError('位置 $position 超出范围，当前缓冲区大小为 $_size');
    }
    // 计算该比特所属的存储单元和在单元内的位置。
    int wordIndex = position >> ADDRESS_BITS_PER_WORD;
    int bitIndex = position & BIT_INDEX_MASK;
    // 提取目标比特值。
    return (_words[wordIndex] >> bitIndex) & 0x00000001;
  }

  /// 设置 `BitBuffer` 中指定位置的比特值。
  ///
  /// ### 参数:
  /// - `position`: 要设置的比特索引。
  ///   - 必须在 `[0, size - 1]` 范围内。
  /// - `bit`: 要设置的比特值。
  ///   - 只能为 0 或 1。
  ///
  /// ### 异常:
  /// - `RangeError`: 如果 `position` 小于 0 或大于等于缓冲区的大小，将抛出范围错误。
  ///
  /// ### 注意:
  /// - `position` 用于计算存储单元（word）和单元内的比特索引。
  /// - 根据 `bit` 的值，清除或设置目标比特。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(32); // 分配32位缓冲区。
  /// buffer.setBit(5, 1); // 将第5个位设置为1。
  /// print(buffer.getBit(5)); // 输出: 1
  /// buffer.setBit(5, 0); // 将第5个位清除为0。
  /// print(buffer.getBit(5)); // 输出: 0
  /// ```
  void setBit(int position, int bit) {
    // 检查位置是否在有效范围内。
    if (position < 0 || position >= _size) {
      throw RangeError('位置 $position 超出范围，当前缓冲区大小为 $_size');
    }
    // 计算该比特所属的存储单元和在单元内的位置。
    int wordIndex = position >> ADDRESS_BITS_PER_WORD;
    int bitIndex = position & BIT_INDEX_MASK;
    // 根据值（0 或 1）更新目标比特。
    if (bit == 0) {
      _words[wordIndex] &= ~(1 << bitIndex); // 清除目标比特。
    } else {
      _words[wordIndex] |= (1 << bitIndex); // 设置目标比特。
    }
  }
}
