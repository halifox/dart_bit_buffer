import 'dart:typed_data';

import 'package:bit_buffer/bit_buffer.dart';
import 'package:test/test.dart';

main() {
  group("BitBuffer", () {
    test("bit", () {
      BitBuffer buffer = BitBuffer();
      buffer.allocate(128);
      buffer.writeBit(0, 0);
      buffer.writeBit(1, 1);
      buffer.writeBit(127, 1);

      expect(buffer.readBit(0), 0);
      expect(buffer.readBit(1), 1);
      expect(buffer.readBit(127), 1);
      expect(buffer.toString(), "01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");

      expect(() => buffer.writeBit(-1, 0), throwsA(isA<RangeError>()));
      expect(() => buffer.writeBit(129, 0), throwsA(isA<RangeError>()));
    });
    test("testValue", () {
      testValue(-128, 8, BitOrder.MSBFirst, "10000000");
      testValue(-127, 8, BitOrder.MSBFirst, "10000001");
      testValue(-64, 8, BitOrder.MSBFirst, "11000000");
      testValue(-1, 8, BitOrder.MSBFirst, "11111111");
      testValue(0, 8, BitOrder.MSBFirst, "00000000");
      testValue(1, 8, BitOrder.MSBFirst, "00000001");
      testValue(64, 8, BitOrder.MSBFirst, "01000000");
      testUint(255, 8, BitOrder.MSBFirst, "11111111");

      testValue(127, 8, BitOrder.MSBFirst, "01111111");
      testValue(-128, 8, BitOrder.LSBFirst, "00000001");
      testValue(-127, 8, BitOrder.LSBFirst, "10000001");
      testValue(-64, 8, BitOrder.LSBFirst, "00000011");
      testValue(-1, 8, BitOrder.LSBFirst, "11111111");
      testValue(0, 8, BitOrder.LSBFirst, "00000000");
      testValue(1, 8, BitOrder.LSBFirst, "10000000");
      testValue(64, 8, BitOrder.LSBFirst, "00000010");
      testValue(127, 8, BitOrder.LSBFirst, "11111110");
      testUint(255, 8, BitOrder.LSBFirst, "11111111");

      testValue(-128, 16, BitOrder.MSBFirst, "1111111110000000");
      testValue(-127, 16, BitOrder.MSBFirst, "1111111110000001");
      testValue(-64, 16, BitOrder.MSBFirst, "1111111111000000");
      testValue(-1, 16, BitOrder.MSBFirst, "1111111111111111");
      testValue(0, 16, BitOrder.MSBFirst, "0000000000000000");
      testValue(1, 16, BitOrder.MSBFirst, "0000000000000001");
      testValue(64, 16, BitOrder.MSBFirst, "0000000001000000");
      testValue(127, 16, BitOrder.MSBFirst, "0000000001111111");

      testValue(-32768, 16, BitOrder.MSBFirst, "1000000000000000");
      testValue(-128, 16, BitOrder.MSBFirst, "1111111110000000");
      testValue(-127, 16, BitOrder.MSBFirst, "1111111110000001");
      testValue(-64, 16, BitOrder.MSBFirst, "1111111111000000");
      testValue(-1, 16, BitOrder.MSBFirst, "1111111111111111");
      testValue(0, 16, BitOrder.MSBFirst, "0000000000000000");
      testValue(1, 16, BitOrder.MSBFirst, "0000000000000001");
      testValue(64, 16, BitOrder.MSBFirst, "0000000001000000");
      testValue(127, 16, BitOrder.MSBFirst, "0000000001111111");
      testValue(32767, 16, BitOrder.MSBFirst, "0111111111111111");
      testUint(65535, 16, BitOrder.MSBFirst, "1111111111111111");

      testBigInt(BigInt.from(-1), 128, BitOrder.MSBFirst, "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
      testBigInt(BigInt.from(0), 128, BitOrder.MSBFirst, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(BigInt.from(1), 128, BitOrder.MSBFirst, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");
      testBigInt(
          BigInt.from(9223372036854775807), 128, BitOrder.MSBFirst, "00000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111");
      testBigInt(BigInt.from(9223372036854775807) + BigInt.from(1), 128, BitOrder.MSBFirst,
          "00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(BigInt.parse("-170141183460469231731687303715884105728", radix: 10), 128, BitOrder.MSBFirst,
          "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(BigInt.parse("170141183460469231731687303715884105727", radix: 10), 128, BitOrder.MSBFirst,
          "01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");

      testBigInt(BigInt.from(-1), 128, BitOrder.LSBFirst, "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
      testBigInt(BigInt.from(0), 128, BitOrder.LSBFirst, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(BigInt.from(1), 128, BitOrder.LSBFirst, "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(
          BigInt.from(9223372036854775807), 128, BitOrder.LSBFirst, "11111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(BigInt.from(9223372036854775807) + BigInt.from(1), 128, BitOrder.LSBFirst,
          "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000");
      testBigInt(BigInt.parse("-170141183460469231731687303715884105728", radix: 10), 128, BitOrder.LSBFirst,
          "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");
      testBigInt(BigInt.parse("170141183460469231731687303715884105727", radix: 10), 128, BitOrder.LSBFirst,
          "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110");

      testUBigInt(BigInt.from(0), 128, BitOrder.MSBFirst, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testUBigInt(BigInt.from(1), 128, BitOrder.MSBFirst, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");
      testUBigInt(
          BigInt.from(9223372036854775807), 128, BitOrder.MSBFirst, "00000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111");
      testUBigInt(BigInt.from(9223372036854775807) + BigInt.from(1), 128, BitOrder.MSBFirst,
          "00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000");
      testUBigInt(BigInt.parse("170141183460469231731687303715884105727", radix: 10), 128, BitOrder.MSBFirst,
          "01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
      testUBigInt(BigInt.parse("340282366920938463463374607431768211455", radix: 10), 128, BitOrder.MSBFirst,
          "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");

      testUBigInt(BigInt.from(0), 128, BitOrder.LSBFirst, "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testUBigInt(BigInt.from(1), 128, BitOrder.LSBFirst, "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
      testUBigInt(
          BigInt.from(9223372036854775807), 128, BitOrder.LSBFirst, "11111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000");
      testUBigInt(BigInt.from(9223372036854775807) + BigInt.from(1), 128, BitOrder.LSBFirst,
          "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000");
      testUBigInt(BigInt.parse("170141183460469231731687303715884105727", radix: 10), 128, BitOrder.LSBFirst,
          "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110");
      testUBigInt(BigInt.parse("340282366920938463463374607431768211455", radix: 10), 128, BitOrder.LSBFirst,
          "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
    });

    test("Uint8List", () {
      var data = Uint8List.fromList([0, 1, 2, 254, 255]);
      var bitBuffer = BitBuffer.fromUint8List(data);
      expect(bitBuffer.toUint8List(), data);
      expect(bitBuffer.toString(), "0000000000000001000000101111111011111111");
    });
    test("UintList", () {
      var data = [0, 1, 128, 255];
      run(() {
        var bitBuffer = BitBuffer.fromUintList(data, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(bitBuffer.toUintList(binaryDigits: 16, order: BitOrder.MSBFirst), data);
        expect(bitBuffer.toString(), "0000000000000000000000000000000100000000100000000000000011111111");
      });
      run(() {
        var bitBuffer = BitBuffer.fromUintList(data, binaryDigits: 16, order: BitOrder.LSBFirst);
        expect(bitBuffer.toUintList(binaryDigits: 16, order: BitOrder.LSBFirst), data);
        expect(bitBuffer.toString(), "0000000000000000100000000000000000000001000000001111111100000000");
      });
      run(() {
        var bitBuffer = BitBuffer.fromUintList(data, binaryDigits: 64, order: BitOrder.MSBFirst);
        expect(bitBuffer.toUintList(binaryDigits: 64, order: BitOrder.MSBFirst), data);
        expect(
            bitBuffer.toString(),
            "0000000000000000000000000000000000000000000000000000000000000000"
            "0000000000000000000000000000000000000000000000000000000000000001"
            "0000000000000000000000000000000000000000000000000000000010000000"
            "0000000000000000000000000000000000000000000000000000000011111111");
      });
    });
    test("IntList", () {
      var data = [-32768, -1, 0, 1, 32767];
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(bitBuffer.toIntList(binaryDigits: 16, order: BitOrder.MSBFirst), data);
        expect(bitBuffer.toString(), "10000000000000001111111111111111000000000000000000000000000000010111111111111111");
      });
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 16, order: BitOrder.LSBFirst);
        expect(bitBuffer.toIntList(binaryDigits: 16, order: BitOrder.LSBFirst), data);
        expect(bitBuffer.toString(), "00000000000000011111111111111111000000000000000010000000000000001111111111111110");
      });
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 64, order: BitOrder.MSBFirst);
        expect(bitBuffer.toIntList(binaryDigits: 64, order: BitOrder.MSBFirst), data);
        expect(
            bitBuffer.toString(),
            "1111111111111111111111111111111111111111111111111000000000000000"
            "1111111111111111111111111111111111111111111111111111111111111111"
            "0000000000000000000000000000000000000000000000000000000000000000"
            "0000000000000000000000000000000000000000000000000000000000000001"
            "0000000000000000000000000000000000000000000000000111111111111111");
      });
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 16, order: BitOrder.MSBFirst);
        var intList = bitBuffer.readIntList(0, 16 * 3, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(intList, [-32768, -1, 0]);
      });
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 16, order: BitOrder.MSBFirst);
        var intList = bitBuffer.readIntList(0, 16 * 5, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(intList, [-32768, -1, 0, 1, 32767]);
      });
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 16, order: BitOrder.MSBFirst);
        var intList = bitBuffer.readIntList(16, 16 * 3, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(intList, [-1, 0, 1]);
      });
      run(() {
        var bitBuffer = BitBuffer.fromIntList(data, binaryDigits: 16, order: BitOrder.MSBFirst);
        var intList = bitBuffer.readIntList(32, 16 * 3, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(intList, [0, 1, 32767]);
      });
      run(() {
        var bitBuffer = BitBuffer();
        bitBuffer.allocate(16 * 5);
        bitBuffer.writeIntList(0, data, binaryDigits: 16, order: BitOrder.MSBFirst);
        var intList = bitBuffer.readIntList(32, 16 * 3, binaryDigits: 16, order: BitOrder.MSBFirst);
        expect(intList, [0, 1, 32767]);
      });
    });

    test("utf-8", () {
      var value = "hello world!";

      var bitBuffer = BitBuffer();
      bitBuffer.allocate(12 * 8);
      bitBuffer.writeUtf8String(0, value, binaryDigits: 8, order: BitOrder.MSBFirst);
      expect(bitBuffer.readUtf8String(0, 12 * 8, binaryDigits: 8, order: BitOrder.MSBFirst), value);
      expect(bitBuffer.toString(), "011010000110010101101100011011000110111100100000011101110110111101110010011011000110010000100001");
    });
  });
}

testInt(int value, int binaryDigits, BitOrder order, [String? binaryString]) {
  BitBuffer buffer = BitBuffer();
  buffer.allocate(binaryDigits);
  buffer.writeInt(0, value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(buffer.readInt(0, binaryDigits: binaryDigits, order: order), value);
}

testBigInt(BigInt value, int binaryDigits, BitOrder order, [String? binaryString]) {
  BitBuffer buffer = BitBuffer();
  buffer.allocate(binaryDigits);
  buffer.writeBigInt(0, value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(buffer.readBigInt(0, binaryDigits: binaryDigits, order: order), value);
}

testUint(int value, int binaryDigits, BitOrder order, [String? binaryString]) {
  if (value < 0) return;

  BitBuffer buffer = BitBuffer();
  buffer.allocate(binaryDigits);
  buffer.writeUint(0, value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(buffer.readUint(0, binaryDigits: binaryDigits, order: order), value);
}

testUBigInt(BigInt value, int binaryDigits, BitOrder order, [String? binaryString]) {
  if (value < BigInt.zero) return;

  BitBuffer buffer = BitBuffer();
  buffer.allocate(binaryDigits);
  buffer.writeUBigInt(0, value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(buffer.readUBigInt(0, binaryDigits: binaryDigits, order: order), value);
}

testBitBufferInt(int value, int binaryDigits, BitOrder order, [String? binaryString]) {
  BitBuffer buffer = BitBuffer();
  BitBufferWriter writer = buffer.getWriter();
  BitBufferReader reader = buffer.getReader();
  writer.writeInt(value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(reader.readInt(binaryDigits: binaryDigits, order: order), value);
}

testBitBufferUint(int value, int binaryDigits, BitOrder order, [String? binaryString]) {
  if (value < 0) return;
  BitBuffer buffer = BitBuffer();
  BitBufferWriter writer = buffer.getWriter();
  BitBufferReader reader = buffer.getReader();
  writer.writeUint(value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(reader.readUint(binaryDigits: binaryDigits, order: order), value);
}

testBitBufferBigInt(BigInt value, int binaryDigits, BitOrder order, [String? binaryString]) {
  BitBuffer buffer = BitBuffer();
  BitBufferWriter writer = buffer.getWriter();
  BitBufferReader reader = buffer.getReader();
  writer.writeBigInt(value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(reader.readBigInt(binaryDigits: binaryDigits, order: order), value);
}

testBitBufferUBigInt(BigInt value, int binaryDigits, BitOrder order, [String? binaryString]) {
  if (value < BigInt.zero) return;
  BitBuffer buffer = BitBuffer();
  BitBufferWriter writer = buffer.getWriter();
  BitBufferReader reader = buffer.getReader();
  writer.writeUBigInt(value, binaryDigits: binaryDigits, order: order);
  if (binaryString != null) {
    expect(buffer.toString(), binaryString);
  } else {
    print(buffer);
  }
  expect(reader.readUBigInt(binaryDigits: binaryDigits, order: order), value);
}

testValue(int value, int binaryDigits, BitOrder order, [String? binaryString]) {
  testInt(value, binaryDigits, order, binaryString);
  testUint(value, binaryDigits, order, binaryString);
  testBigInt(BigInt.from(value), binaryDigits, order, binaryString);
  testUBigInt(BigInt.from(value), binaryDigits, order, binaryString);
  testBitBufferInt(value, binaryDigits, order, binaryString);
  testBitBufferUint(value, binaryDigits, order, binaryString);
  testBitBufferBigInt(BigInt.from(value), binaryDigits, order, binaryString);
  testBitBufferUBigInt(BigInt.from(value), binaryDigits, order, binaryString);
}

run(void Function() block) {
  block();
}
