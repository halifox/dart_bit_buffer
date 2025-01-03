import 'dart:typed_data';

import 'package:bit_buffer/bit_buffer.dart';
import 'package:test/test.dart';

main() {
  group("buffer", () {
    test("description", () {
      BitBuffer buffer = BitBuffer();
      buffer.allocate(128);
      buffer.setBit(0, 0);
      buffer.setBit(1, 1);
      buffer.setBit(127, 1);

      expect(buffer.getBit(0), 0);
      expect(buffer.getBit(1), 1);
      expect(buffer.getBit(127), 1);
      expect(buffer.toString(), "01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001");

      expect(() => buffer.setBit(-1, 0), throwsA(isA<RangeError>()));
      expect(() => buffer.setBit(129, 0), throwsA(isA<RangeError>()));
    });

    test("Uint8List", () {
      var data = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7]);
      var bitBuffer = BitBuffer.formUInt8List(data);
      var uInt8List = bitBuffer.toUInt8List();
      expect(data, uInt8List);
    });

    test("int64 msb", () {
      void testInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putInt(value);
        int val = reader.getInt();
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testInt(0, "0000000000000000000000000000000000000000000000000000000000000000");
      testInt(1, "0000000000000000000000000000000000000000000000000000000000000001");
      testInt(-1, "1111111111111111111111111111111111111111111111111111111111111111");
      testInt(2, "0000000000000000000000000000000000000000000000000000000000000010");
      testInt(3, "0000000000000000000000000000000000000000000000000000000000000011");
      testInt(3854, "0000000000000000000000000000000000000000000000000000111100001110");
      testInt(-3346, "1111111111111111111111111111111111111111111111111111001011101110");
      testInt(1234567890, "0000000000000000000000000000000001001001100101100000001011010010");
      testInt(-1234567890, "1111111111111111111111111111111110110110011010011111110100101110");
      testInt(2147483647, "0000000000000000000000000000000001111111111111111111111111111111");
      testInt(-2147483748, "1111111111111111111111111111111101111111111111111111111110011100");
      testInt(4294967295, "0000000000000000000000000000000011111111111111111111111111111111");
      testInt(-4294967295, "1111111111111111111111111111111100000000000000000000000000000001");
      testInt(9223372036854775807, "0111111111111111111111111111111111111111111111111111111111111111");
      testInt(-922337203685477580, "1111001100110011001100110011001100110011001100110011001100110100");
    });
    test("int32 msb", () {
      void testInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putInt(value, binaryDigits: 32);
        int val = reader.getInt(binaryDigits: 32);
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testInt(0, "00000000000000000000000000000000");
      testInt(1, "00000000000000000000000000000001");
      testInt(-1, "11111111111111111111111111111111");
      testInt(2, "00000000000000000000000000000010");
      testInt(3, "00000000000000000000000000000011");
      testInt(3854, "00000000000000000000111100001110");
      testInt(-3346, "11111111111111111111001011101110");
      testInt(1234567890, "01001001100101100000001011010010");
      testInt(-1234567890, "10110110011010011111110100101110");
      testInt(2147483647, "01111111111111111111111111111111");
    });
    test("int64 lsb", () {
      void testInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putInt(value, order: BitOrder.LSBFirst);
        int val = reader.getInt(order: BitOrder.LSBFirst);
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testInt(0, "0000000000000000000000000000000000000000000000000000000000000000");
      testInt(1, "1000000000000000000000000000000000000000000000000000000000000000");
      testInt(-1, "1111111111111111111111111111111111111111111111111111111111111111");
      testInt(2, "0100000000000000000000000000000000000000000000000000000000000000");
      testInt(3, "1100000000000000000000000000000000000000000000000000000000000000");
      testInt(3854, "0111000011110000000000000000000000000000000000000000000000000000");
      testInt(-3346, "0111011101001111111111111111111111111111111111111111111111111111");
      testInt(1234567890, "0100101101000000011010011001001000000000000000000000000000000000");
      testInt(-1234567890, "0111010010111111100101100110110111111111111111111111111111111111");
      testInt(2147483647, "1111111111111111111111111111111000000000000000000000000000000000");
      testInt(-2147483748, "0011100111111111111111111111111011111111111111111111111111111111");
      testInt(4294967295, "1111111111111111111111111111111100000000000000000000000000000000");
      testInt(-4294967295, "1000000000000000000000000000000011111111111111111111111111111111");
      testInt(9223372036854775807, "1111111111111111111111111111111111111111111111111111111111111110");
      testInt(-922337203685477580, "0010110011001100110011001100110011001100110011001100110011001111");
    });
    test("int32 lsb", () {
      void testInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putInt(value, binaryDigits: 32, order: BitOrder.LSBFirst);
        int val = reader.getInt(binaryDigits: 32, order: BitOrder.LSBFirst);
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testInt(0, "00000000000000000000000000000000");
      testInt(1, "10000000000000000000000000000000");
      testInt(-1, "11111111111111111111111111111111");
      testInt(2, "01000000000000000000000000000000");
      testInt(3, "11000000000000000000000000000000");
      testInt(3854, "01110000111100000000000000000000");
      testInt(-3346, "01110111010011111111111111111111");
      testInt(1234567890, "01001011010000000110100110010010");
      testInt(-1234567890, "01110100101111111001011001101101");
      testInt(2147483647, "11111111111111111111111111111110");
    });
    test("unit64 msb", () {
      void testUInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putUnsignedInt(value);
        int val = reader.getUnsignedInt();
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testUInt(0, "0000000000000000000000000000000000000000000000000000000000000000");
      testUInt(1, "0000000000000000000000000000000000000000000000000000000000000001");
      testUInt(2, "0000000000000000000000000000000000000000000000000000000000000010");
      testUInt(3, "0000000000000000000000000000000000000000000000000000000000000011");
      testUInt(3854, "0000000000000000000000000000000000000000000000000000111100001110");
      testUInt(1234567890, "0000000000000000000000000000000001001001100101100000001011010010");
      testUInt(2147483647, "0000000000000000000000000000000001111111111111111111111111111111");
      testUInt(4294967295, "0000000000000000000000000000000011111111111111111111111111111111");
      testUInt(9223372036854775807, "0111111111111111111111111111111111111111111111111111111111111111");
    });
    test("unit64 lsb", () {
      void testUInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putUnsignedInt(value, order: BitOrder.LSBFirst);
        int val = reader.getUnsignedInt(order: BitOrder.LSBFirst);
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testUInt(0, "0000000000000000000000000000000000000000000000000000000000000000");
      testUInt(1, "1000000000000000000000000000000000000000000000000000000000000000");
      testUInt(2, "0100000000000000000000000000000000000000000000000000000000000000");
      testUInt(3, "1100000000000000000000000000000000000000000000000000000000000000");
      testUInt(3854, "0111000011110000000000000000000000000000000000000000000000000000");
      testUInt(1234567890, "0100101101000000011010011001001000000000000000000000000000000000");
      testUInt(2147483647, "1111111111111111111111111111111000000000000000000000000000000000");
      testUInt(4294967295, "1111111111111111111111111111111100000000000000000000000000000000");
      testUInt(9223372036854775807, "1111111111111111111111111111111111111111111111111111111111111110");
    });
    test("unit32 msb", () {
      void testUInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putUnsignedInt(value, binaryDigits: 32);
        int val = reader.getUnsignedInt(binaryDigits: 32);
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testUInt(0, "00000000000000000000000000000000");
      testUInt(1, "00000000000000000000000000000001");
      testUInt(2, "00000000000000000000000000000010");
      testUInt(3, "00000000000000000000000000000011");
      testUInt(3854, "00000000000000000000111100001110");
      testUInt(1234567890, "01001001100101100000001011010010");
      testUInt(2147483647, "01111111111111111111111111111111");
      testUInt(4294967295, "11111111111111111111111111111111");
    });
    test("unit32 lsb", () {
      void testUInt(int value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putUnsignedInt(value, binaryDigits: 32, order: BitOrder.LSBFirst);
        int val = reader.getUnsignedInt(binaryDigits: 32, order: BitOrder.LSBFirst);
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testUInt(0, "00000000000000000000000000000000");
      testUInt(1, "10000000000000000000000000000000");
      testUInt(2, "01000000000000000000000000000000");
      testUInt(3, "11000000000000000000000000000000");
      testUInt(3854, "01110000111100000000000000000000");
      testUInt(1234567890, "01001011010000000110100110010010");
      testUInt(2147483647, "11111111111111111111111111111110");
      testUInt(4294967295, "11111111111111111111111111111111");
    });
    test("bool", () {
      void testBool(bool value, String binaryString) {
        BitBuffer buffer = BitBuffer();
        BitBufferWriter writer = buffer.writer();
        BitBufferReader reader = buffer.reader();
        writer.putBool(value);
        bool val = reader.getBool();
        expect(val, value);
        expect(buffer.toString(), binaryString);
      }

      testBool(true, "1");
      testBool(false, "0");
    });
  });
}
