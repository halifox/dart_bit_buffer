import 'dart:math';
import 'dart:typed_data';

import 'package:bit_buffer/bit_buffer.dart';

class BitBuffer {
  /// 内部字段，存储“位”的整数列表，用于模拟比特缓冲区。
  List<int> _storage = [];

  /// 已经使用的比特数，表示缓冲区当前使用了多少位。
  int _bitCount = 0;

  /// 获取当前缓冲区已使用的比特数。
  int get bitCount => _bitCount;

  /// 每个存储单元的位数，通过地址位数来定义，表示一个存储单元的大小。
  final int BITS_PER_STORAGE_UNIT = 6;

  /// 每个存储单元的比特数，等于 2 的 `ADDRESS_BITS_PER_WORD` 次方。
  late final int BITS_PER_WORD = 1 << BITS_PER_STORAGE_UNIT;

  /// 位索引掩码，用于快速计算某个位在存储单元中的位置。
  late final int BIT_INDEX_MASK = BITS_PER_WORD - 1;

  /// 默认构造函数，初始化 BitBuffer。
  BitBuffer();

  /// 从 `Uint8List` 创建一个 `BitBuffer`，按指定的位序进行解码。
  ///
  /// ### 参数:
  /// - `data`: 用于创建 `BitBuffer` 的 `Uint8List` 数据。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 将 `Uint8List` 中的每个字节（8 位）按位读取，并转化为 `BitBuffer`。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 每个字节的 8 位将被按指定的位序顺序添加到 `BitBuffer` 中。
  ///
  /// ### 示例:
  /// ```dart
  /// Uint8List data = Uint8List.fromList([255, 127]);
  /// BitBuffer buffer = BitBuffer.formUInt8List(data);
  /// print(buffer.toString()); // 输出对应的二进制表示
  /// ```
  factory BitBuffer.formUInt8List(
    Uint8List data, {
    BitOrder order = BitOrder.MSBFirst,
  }) {
    return BitBuffer.formUIntList(data, binaryDigits: 8, order: order);
  }

  /// 将 `BitBuffer` 转换为一个 `Uint8List`，按指定的位序进行编码。
  ///
  /// ### 参数:
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 按位读取 `BitBuffer` 中的无符号整数，将其转换为 `Uint8List`。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 转换过程中会按 8 位（一个字节）对缓冲区进行读取，直到全部数据被处理完。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// BitBufferWriter writer = buffer.writer();
  /// writer.putUnsignedInt(255, binaryDigits: 8); // 写入 255
  /// writer.putUnsignedInt(127, binaryDigits: 8); // 写入 127
  /// Uint8List uint8List = buffer.toUInt8List();
  /// print(uint8List); // 输出: [255, 127]
  /// ```
  Uint8List toUInt8List({
    BitOrder order = BitOrder.MSBFirst,
  }) {
    List<int> data = [];
    BitBufferReader reader = this.reader();
    while (reader.remainingSize > 0) {
      int value = reader.getUnsignedInt(binaryDigits: 8, order: order);
      data.add(value);
    }
    return Uint8List.fromList(data);
  }

  /// 从 `List<int>` 创建一个 `BitBuffer`，按指定的位数和位序进行编码，要求 `data` 中的每个整数都是无符号类型。
  ///
  /// ### 参数:
  /// - `data`: 用于创建 `BitBuffer` 的无符号整数列表。
  /// - `binaryDigits` (可选): 每个整数使用的二进制位数，默认为 64 位。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 将 `List<int>` 中的每个无符号整数按指定的位数和位序转换为 `BitBuffer`。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 每个整数会根据 `binaryDigits` 参数的位数进行编码。
  /// - `data` 中的每个整数必须是无符号的。
  ///
  /// ### 示例:
  /// ```dart
  /// List<int> data = [255, 127]; // 无符号整数列表
  /// BitBuffer buffer = BitBuffer.formUIntList(data, binaryDigits: 8);
  /// print(buffer.toString()); // 输出对应的二进制表示
  /// ```
  factory BitBuffer.formUIntList(
    List<int> data, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    BitBuffer bitBuffer = BitBuffer();
    BitBufferWriter writer = bitBuffer.writer();
    for (int value in data) {
      writer.putUnsignedInt(value, binaryDigits: binaryDigits, order: order);
    }
    return bitBuffer;
  }

  /// 从 `List<int>` 创建一个 `BitBuffer`，按指定的位数和位序进行编码。
  ///
  /// ### 参数:
  /// - `data`: 用于创建 `BitBuffer` 的整数列表。
  /// - `binaryDigits` (可选): 每个整数使用的二进制位数，默认为 64 位。
  /// - `order` (可选): 位序顺序，默认为 `BitOrder.MSBFirst`（高位优先）。
  ///
  /// ### 功能:
  /// - 将 `List<int>` 中的每个整数按指定的位数和位序转换为 `BitBuffer`。
  /// - 支持高位优先（MSBFirst）或低位优先（LSBFirst）的位序。
  ///
  /// ### 注意:
  /// - 每个整数会根据 `binaryDigits` 参数的位数进行编码。
  ///
  /// ### 示例:
  /// ```dart
  /// List<int> data = [255, 127];
  /// BitBuffer buffer = BitBuffer.formUIntList(data, binaryDigits: 8);
  /// print(buffer.toString()); // 输出对应的二进制表示
  /// ```
  factory BitBuffer.formIntList(
    List<int> data, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    BitBuffer bitBuffer = BitBuffer();
    BitBufferWriter writer = bitBuffer.writer();
    for (int value in data) {
      writer.putInt(value, binaryDigits: binaryDigits, order: order);
    }
    return bitBuffer;
  }

  /// 返回一个用于读取的 `BitBufferReader` 实例。
  BitBufferReader reader() => BitBufferReader(this);

  /// 返回一个用于写入的 `BitBufferWriter` 实例。
  BitBufferWriter writer() => BitBufferWriter(this);

  /// 返回一个用于追加比特的 `BitBufferWriter` 实例，并将写入位置设置为当前大小。
  BitBufferWriter append() => writer()..seekTo(_bitCount);

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
    int free = _storage.length * BITS_PER_WORD - _bitCount;
    if (free > 0) {
      _bitCount += free; // 使用剩余的空闲比特。
      capacity -= free; // 减少所需容量。
    }

    // 如果仍需要容量，则增加存储单元以满足需求。
    while (capacity > 0) {
      _bitCount += min(capacity, BITS_PER_WORD);
      capacity = max(capacity - BITS_PER_WORD, 0);
      _storage.add(0); // 增加新的存储单元。
    }

    // 更新大小，防止负容量的意外情况。
    _bitCount += capacity;
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
    int free = _storage.length * BITS_PER_WORD - _bitCount;
    // 移除超出当前大小的存储单元。
    while (free > BITS_PER_WORD) {
      _storage.removeLast();
      free = _storage.length * BITS_PER_WORD - _bitCount;
    }
  }

  /// 将整个缓冲区的比特表示为字符串形式。
  @override
  String toString() {
    return toSectionString(0, _bitCount);
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
    int end = min(start + length, _bitCount);
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
    if (position < 0 || position >= _bitCount) {
      throw RangeError('位置 $position 超出范围，当前缓冲区大小为 $_bitCount');
    }
    // 计算该比特所属的存储单元和在单元内的位置。
    int wordIndex = position >> BITS_PER_STORAGE_UNIT;
    int bitIndex = position & BIT_INDEX_MASK;
    // 提取目标比特值。
    return (_storage[wordIndex] >> bitIndex) & 0x00000001;
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
    if (position < 0 || position >= _bitCount) {
      throw RangeError('位置 $position 超出范围，当前缓冲区大小为 $_bitCount');
    }
    // 计算该比特所属的存储单元和在单元内的位置。
    int wordIndex = position >> BITS_PER_STORAGE_UNIT;
    int bitIndex = position & BIT_INDEX_MASK;
    // 根据值（0 或 1）更新目标比特。
    if (bit == 0) {
      _storage[wordIndex] &= ~(1 << bitIndex); // 清除目标比特。
    } else {
      _storage[wordIndex] |= (1 << bitIndex); // 设置目标比特。
    }
  }

  /// 获取指定偏移位置的有符号整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `binaryDigits`: 要读取的比特位数，默认为 64。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 返回值:
  /// - `int`: 读取到的有符号整数值。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(64); // 分配64位缓冲区。
  /// buffer.putInt(0, -12345); // 设置一个负数值。
  /// print(buffer.getInt(0)); // 输出: -12345
  /// ```
  int getInt(
    int offset, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    // 先读取无符号整数值。
    int number = getUnsignedInt(offset, binaryDigits: binaryDigits, order: order);

    // 检查符号位，判断是否为负数。
    int isNegative = (number >> (binaryDigits - 1)) & 1;

    if (isNegative != 0) {
      // 如果是负数，转换为补码表示的有符号整数。
      int mask = (1 << (binaryDigits - 1)) - 1; // 获取有效位的掩码。
      number = -(~(number - 1) & mask); // 还原负数值。
    }

    return number;
  }

  /// 设置指定偏移位置的有符号整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `value`: 要设置的有符号整数值。
  /// - `binaryDigits`: 要设置的比特位数，默认为 64。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(64); // 分配64位缓冲区。
  /// buffer.putInt(0, -12345); // 设置一个负数值。
  /// print(buffer.getInt(0)); // 输出: -12345
  /// ```
  void putInt(
    int offset,
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
    putUnsignedInt(offset, value, binaryDigits: binaryDigits, order: order);
  }

  /// 获取指定偏移位置的无符号大整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `binaryDigits`: 要读取的比特位数，默认为 128。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 返回值:
  /// - `BigInt`: 读取到的无符号大整数值。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(128); // 分配128位缓冲区。
  /// buffer.putBigInt(0, BigInt.from(1234567890123456789)); // 设置一个大整数。
  /// print(buffer.getBigInt(0)); // 输出: 1234567890123456789
  /// ```
  BigInt getBigInt(
    int offset, {
    int binaryDigits = 128,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    // 先读取无符号整数值。
    BigInt number = getUnsignedBigInt(offset, binaryDigits: binaryDigits, order: order);

    // 检查符号位，判断是否为负数。
    int shiftAmount = binaryDigits - 1;
    BigInt isNegative = number >> shiftAmount;

    if (isNegative != BigInt.zero) {
      // 如果是负数，转换为补码表示的有符号整数。
      BigInt mask = (BigInt.one << (binaryDigits - 1)) - BigInt.one; // 获取有效位的掩码。
      number = -(~(number - BigInt.one) & mask); // 还原负数值。
    }

    return number;
  }

  /// 设置指定偏移位置的无符号大整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `value`: 要设置的无符号大整数值。
  /// - `binaryDigits`: 要设置的比特位数，默认为 128。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(128); // 分配128位缓冲区。
  /// buffer.putBigInt(0, BigInt.from(1234567890123456789)); // 设置一个大整数。
  /// print(buffer.getBigInt(0)); // 输出: 1234567890123456789
  /// ```
  void putBigInt(
    int offset,
    BigInt value, {
    int binaryDigits = 128,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    if (value.isNegative) {
      // 处理负数值，转换为补码形式。
      BigInt mask = (BigInt.one << binaryDigits) - BigInt.one;
      value = ~(-value); // 取反。
      value += BigInt.one; // 加 1 形成补码。
      value &= mask; // 保留指定位数。
    }
    putUnsignedBigInt(offset, value, binaryDigits: binaryDigits, order: order);
  }

  /// 获取指定偏移位置的无符号整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `binaryDigits`: 要读取的比特位数，默认为 64。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 返回值:
  /// - `int`: 读取到的无符号整数值。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(64); // 分配64位缓冲区。
  /// buffer.putUnsignedInt(0, 12345); // 设置一个无符号整数值。
  /// print(buffer.getUnsignedInt(0)); // 输出: 12345
  /// ```
  int getUnsignedInt(
    int offset, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    int value = 0;

    // 根据指定的顺序依次读取每个位。
    for (int i = 0; i < binaryDigits; i++) {
      // 计算当前比特位置。
      int position = offset + binaryDigits - 1 - i;
      if (order == BitOrder.MSBFirst) {
        position = offset + i;
      }

      // 将读取的比特值按权重累加到结果值中。
      value |= (getBit(position) << (binaryDigits - 1 - i));
    }
    return value;
  }

  /// 设置指定偏移位置的无符号整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `value`: 要设置的无符号整数值。
  /// - `binaryDigits`: 要设置的比特位数，默认为 64。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(64); // 分配64位缓冲区。
  /// buffer.putUnsignedInt(0, 12345); // 设置一个无符号整数值。
  /// print(buffer.getUnsignedInt(0)); // 输出: 12345
  /// ```
  void putUnsignedInt(
    int offset,
    int value, {
    int binaryDigits = 64,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    for (int i = 0; i < binaryDigits; i++) {
      // 提取当前位的值。
      int bit = (value >> i) & 1;

      // 根据顺序确定实际写入位置。
      int position = offset + i;
      if (order == BitOrder.MSBFirst) {
        position = offset + binaryDigits - 1 - i;
      }

      // 写入比特值到指定位置。
      setBit(position, bit);
    }
  }

  /// 获取指定偏移位置的无符号大整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `binaryDigits`: 要读取的比特位数，默认为 128。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 返回值:
  /// - `BigInt`: 读取到的无符号大整数值。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(128); // 分配128位缓冲区。
  /// buffer.putUnsignedBigInt(0, BigInt.from(1234567890123456789)); // 设置一个无符号大整数。
  /// print(buffer.getUnsignedBigInt(0)); // 输出: 1234567890123456789
  /// ```
  BigInt getUnsignedBigInt(
    int offset, {
    int binaryDigits = 128,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    BigInt value = BigInt.zero;

    // 根据指定的顺序依次读取每个位。
    for (int i = 0; i < binaryDigits; i++) {
      // 计算当前比特位置。
      int position = offset + binaryDigits - 1 - i;
      if (order == BitOrder.MSBFirst) {
        position = offset + i;
      }

      // 将读取的比特值按权重累加到结果值中。
      int bit = getBit(position);
      int shiftAmount = binaryDigits - 1 - i;
      BigInt bitValue = BigInt.from(bit) << shiftAmount;
      value |= bitValue;
    }
    return value;
  }

  /// 设置指定偏移位置的无符号大整数值。
  ///
  /// ### 参数:
  /// - `offset`: 起始偏移位置（以比特为单位）。
  /// - `value`: 要设置的无符号大整数值。
  /// - `binaryDigits`: 要设置的比特位数，默认为 128。
  /// - `order`: 比特顺序，默认为 `BitOrder.MSBFirst`。
  ///
  /// ### 示例:
  /// ```dart
  /// BitBuffer buffer = BitBuffer();
  /// buffer.allocate(128); // 分配128位缓冲区。
  /// buffer.putUnsignedBigInt(0, BigInt.from(1234567890123456789)); // 设置一个无符号大整数。
  /// print(buffer.getUnsignedBigInt(0)); // 输出: 1234567890123456789
  /// ```
  void putUnsignedBigInt(
    int offset,
    BigInt value, {
    int binaryDigits = 128,
    BitOrder order = BitOrder.MSBFirst,
  }) {
    for (int i = 0; i < binaryDigits; i++) {
      // 提取当前位的值。
      BigInt bit = (value >> i) & BigInt.one;

      // 根据顺序确定实际写入位置。
      int position = offset + i;
      if (order == BitOrder.MSBFirst) {
        position = offset + binaryDigits - 1 - i;
      }

      // 写入比特值到指定位置。
      setBit(position, bit.toInt());
    }
  }
}
