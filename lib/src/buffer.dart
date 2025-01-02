import 'dart:math';

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

  /// 返回一个用于读取的 `BitBufferReader` 实例。
  BitBufferReader reader() => BitBufferReader(this);

  /// 返回一个用于写入的 `BitBufferWriter` 实例。
  BitBufferWriter writer() => BitBufferWriter(this);

  /// 返回一个用于追加比特的 `BitBufferWriter` 实例，并将写入位置设置为当前大小。
  BitBufferWriter append() => writer()..seekTo(_size);

  /// 为缓冲区分配指定数量的比特。
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

  /// 修剪缓冲区，移除多余的存储单元，减少内存浪费。
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

  /// 返回缓冲区中指定范围的比特字符串表示。
  String toSectionString(int start, int length) {
    int end = min(start + length, _size);
    StringBuffer stringBuffer = StringBuffer();
    for (int position = start; position < end; position++) {
      stringBuffer.write(getBit(position)); // 获取每个位并追加到字符串缓冲区。
    }
    return stringBuffer.toString();
  }

  /// 获取指定位置的比特值。
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

  /// 设置指定位置的比特值。
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
