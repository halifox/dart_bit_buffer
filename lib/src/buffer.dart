import 'dart:math';

import 'package:bit_buffer/bit_buffer.dart';

class BitBuffer {
  /// 对应于serialField“位”的内部字段。
  List<int> _words = [];

  /// 已经使用的比特数
  int _size = 0;

  int get size => _size;

  /// 每个 存储单元 的 位数
  int ADDRESS_BITS_PER_WORD = 6;

  /// 每个 存储单元 的 比特数。
  late int BITS_PER_WORD = 1 << ADDRESS_BITS_PER_WORD;

  /// 位索引掩码
  late int BIT_INDEX_MASK = BITS_PER_WORD - 1;

  BitBuffer();

  BitBufferReader reader() => BitBufferReader(this);

  BitBufferWriter writer() => BitBufferWriter(this);

  BitBufferWriter append() => writer()..seekTo(_size);

  void allocate(int capacity) {
    int free = _words.length * BITS_PER_WORD - _size;
    if (free > 0) {
      _size += free;
      capacity -= free;
    }

    while (capacity > 0) {
      _size += min(capacity, BITS_PER_WORD);
      capacity = max(capacity - BITS_PER_WORD, 0);
      _words.add(0);
    }

    _size += capacity;
  }

  void trim() {
    int free = _words.length * BITS_PER_WORD - _size;
    while (free > BITS_PER_WORD) {
      _words.removeLast();
      free = _words.length * BITS_PER_WORD - _size;
    }
  }

  @override
  String toString() {
    return toSectionString(0, _size);
  }

  String toSectionString(int start, int length) {
    int end = min(start + length, _size);
    StringBuffer stringBuffer = StringBuffer();
    for (int position = start; position < end; position++) {
      stringBuffer.write(getBit(position));
    }
    return stringBuffer.toString();
  }

  int getBit(int position) {
    if (position < 0 || position >= _size) {
      throw RangeError('位置 $position 超出范围，当前缓冲区大小为 $_size');
    }
    int wordIndex = position >> ADDRESS_BITS_PER_WORD;
    int bitIndex = position & BIT_INDEX_MASK;
    return (_words[wordIndex] >> bitIndex) & 0x00000001;
  }

  void setBit(int position, int bit) {
    if (position < 0 || position >= _size) {
      throw RangeError('位置 $position 超出范围，当前缓冲区大小为 $_size');
    }
    int wordIndex = position >> ADDRESS_BITS_PER_WORD;
    int bitIndex = position & BIT_INDEX_MASK;
    if (bit == 0) {
      _words[wordIndex] &= ~(1 << bitIndex);
    } else {
      _words[wordIndex] |= (1 << bitIndex);
    }
  }
}
