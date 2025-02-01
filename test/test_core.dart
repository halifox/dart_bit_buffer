import 'dart:typed_data';

import 'package:bit_buffer/bit_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('BitBuffer Core Functionality', () {
    test('Initialize empty BitBuffer', () {
      final buffer = BitBuffer();
      expect(buffer.bitLength, 0);
    });

    test('Initialize BitBuffer from Uint8List (MSBFirst)', () {
      final bytes = Uint8List.fromList([0x8F]); // 10001111 in binary
      final buffer = BitBuffer.fromUint8List(bytes, order: BitOrder.MSBFirst);
      expect(buffer.bitLength, 8);
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(4), 1);
      expect(buffer.readBit(7), 1);
    });

    test('Initialize BitBuffer from Uint8List (LSBFirst)', () {
      final bytes = Uint8List.fromList([0x8F]); // 10001111 in binary
      final buffer = BitBuffer.fromUint8List(bytes, order: BitOrder.LSBFirst);
      expect(buffer.bitLength, 8);
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(3), 1);
      expect(buffer.readBit(7), 1);
    });

    test('Write/Read single bit (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBit(1); // Position 0
      writer.writeBit(0); // Position 1
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(1), 0);
    });

    test('Write/Read single bit (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBit(1); // Position 0
      writer.writeBit(0); // Position 1
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(1), 0);
    });

    test('Write/Read multiple bits (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBit(1); // Position 0
      writer.writeBit(0); // Position 1
      writer.writeBit(1); // Position 2
      writer.writeBit(1); // Position 3
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(1), 0);
      expect(buffer.readBit(2), 1);
      expect(buffer.readBit(3), 1);
    });

    test('Write/Read multiple bits (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBit(1); // Position 0
      writer.writeBit(0); // Position 1
      writer.writeBit(1); // Position 2
      writer.writeBit(1); // Position 3
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(1), 0);
      expect(buffer.readBit(2), 1);
      expect(buffer.readBit(3), 1);
    });
  });

  group('Integer Read/Write Tests', () {
    test('Write/Read 8-bit unsigned integer (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xAA, binaryDigits: 8); // 10101010
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8), 0xAA);
    });

    test('Write/Read 8-bit unsigned integer (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xAA, binaryDigits: 8, order: BitOrder.LSBFirst); // 10101010
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8, order: BitOrder.LSBFirst), 0xAA);
    });

    test('Write/Read 16-bit unsigned integer (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xABCD, binaryDigits: 16); // 1010101111001101
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 16), 0xABCD);
    });

    test('Write/Read 16-bit unsigned integer (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xABCD, binaryDigits: 16, order: BitOrder.LSBFirst); // 1010101111001101
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 16, order: BitOrder.LSBFirst), 0xABCD);
    });

    test('Write/Read 32-bit signed integer (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeInt(-123456, binaryDigits: 32); // Negative number
      final reader = buffer.getReader();
      expect(reader.readInt(binaryDigits: 32), -123456);
    });

    test('Write/Read 32-bit signed integer (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeInt(-123456, binaryDigits: 32, order: BitOrder.LSBFirst); // Negative number
      final reader = buffer.getReader();
      expect(reader.readInt(binaryDigits: 32, order: BitOrder.LSBFirst), -123456);
    });

    test('Write/Read 64-bit signed integer (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeInt(-987654321, binaryDigits: 64); // Large negative number
      final reader = buffer.getReader();
      expect(reader.readInt(binaryDigits: 64), -987654321);
    });

    test('Write/Read 64-bit signed integer (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeInt(-987654321, binaryDigits: 64, order: BitOrder.LSBFirst); // Large negative number
      final reader = buffer.getReader();
      expect(reader.readInt(binaryDigits: 64, order: BitOrder.LSBFirst), -987654321);
    });

    test('Write/Read 128-bit BigInt (MSBFirst)', () {
      final bigValue = BigInt.parse('123456789ABCDEF123456789ABCDEF', radix: 16);
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBigInt(bigValue, binaryDigits: 128);
      final reader = buffer.getReader();
      expect(reader.readBigInt(binaryDigits: 128), bigValue);
    });

    test('Write/Read 128-bit BigInt (LSBFirst)', () {
      final bigValue = BigInt.parse('123456789ABCDEF123456789ABCDEF', radix: 16);
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBigInt(bigValue, binaryDigits: 128, order: BitOrder.LSBFirst);
      final reader = buffer.getReader();
      expect(reader.readBigInt(binaryDigits: 128, order: BitOrder.LSBFirst), bigValue);
    });
  });

  group('String and Edge Cases', () {
    test('Write/Read UTF-8 string (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUtf8String('Hello', binaryDigits: 8); // 5 bytes
      final reader = buffer.getReader();
      expect(reader.readUtf8String(5 * 8, binaryDigits: 8), 'Hello');
    });

    test('Write/Read UTF-8 string (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUtf8String('Hello', binaryDigits: 8, order: BitOrder.LSBFirst); // 5 bytes
      final reader = buffer.getReader();
      expect(reader.readUtf8String(5 * 8, binaryDigits: 8, order: BitOrder.LSBFirst), 'Hello');
    });

    test('Buffer auto-expansion', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.seekTo(100); // Force expansion
      writer.writeBit(1);
      expect(buffer.bitLength >= 101, isTrue);
    });

    test('Out-of-bounds read throws RangeError', () {
      final buffer = BitBuffer();
      final reader = buffer.getReader();
      expect(() => reader.readBit(), throwsRangeError);
    });

    test('Write/Read empty string', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUtf8String('', binaryDigits: 8); // Empty string
      final reader = buffer.getReader();
      expect(reader.readUtf8String(0, binaryDigits: 8), '');
    });

    test('Write/Read zero integer', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0, binaryDigits: 8); // Zero
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8), 0);
    });
  });

  group('Writer Position Control', () {
    test('Overwrite bits with seekTo (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xFF, binaryDigits: 8); // Write 0xFF at position 0-7
      writer.seekTo(4); // Move to position 4
      writer.writeUint(0xA, binaryDigits: 4); // Overwrite bits 4-7 with 0xA
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8), 0xFA); // 11111010
    });

    test('Overwrite bits with seekTo (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xFF, binaryDigits: 8, order: BitOrder.LSBFirst); // Write 0xFF at position 0-7
      writer.seekTo(4); // Move to position 4
      writer.writeUint(0xA, binaryDigits: 4, order: BitOrder.LSBFirst); // Overwrite bits 4-7 with 0xA
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8, order: BitOrder.LSBFirst), 0xAF); // 11110101
    });

    test('Seek beyond buffer length expands buffer', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.seekTo(100); // Seek beyond current length
      writer.writeBit(1); // Write a bit at position 100
      expect(buffer.bitLength, 101);
    });
  });

  group('Complex Scenarios', () {
    test('Mixed data types (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBool(true);
      writer.writeInt(-42, binaryDigits: 16);
      writer.writeUtf8String('Dart', binaryDigits: 8);

      final reader = buffer.getReader();
      expect(reader.readBool(), isTrue);
      expect(reader.readInt(binaryDigits: 16), -42);
      expect(reader.readUtf8String(4 * 8, binaryDigits: 8), 'Dart');
    });

    test('Mixed data types (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBool(true);
      writer.writeInt(-42, binaryDigits: 16, order: BitOrder.LSBFirst);
      writer.writeUtf8String('Dart', binaryDigits: 8, order: BitOrder.LSBFirst);

      final reader = buffer.getReader();
      expect(reader.readBool(), isTrue);
      expect(reader.readInt(binaryDigits: 16, order: BitOrder.LSBFirst), -42);
      expect(reader.readUtf8String(4 * 8, binaryDigits: 8, order: BitOrder.LSBFirst), 'Dart');
    });
  });

  group('BitBuffer Core Tests', () {
    test('Initialize from Uint8List and verify bits', () {
      final bytes = Uint8List.fromList([0x8F]); // 10001111 in binary
      final buffer = BitBuffer.fromUint8List(bytes, order: BitOrder.MSBFirst);
      expect(buffer.bitLength, 8);
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(4), 1);
      expect(buffer.readBit(7), 1);
    });

    test('Write/Read single bit with LSBFirst', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBit(1); // Position 0
      writer.writeBit(0); // Position 1
      expect(buffer.readBit(0), 1);
      expect(buffer.readBit(1), 0);
    });
  });

  group('Integer Read/Write Tests', () {
    test('Write/Read 8-bit unsigned integer (MSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xAA, binaryDigits: 8); // 10101010
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8), 0xAA);
    });

    test('Write/Read negative 4-bit signed integer (LSBFirst)', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeInt(-1, binaryDigits: 4, order: BitOrder.LSBFirst); // 1111
      final reader = buffer.getReader();
      expect(reader.readInt(binaryDigits: 4, order: BitOrder.LSBFirst), -1);
    });

    test('Write/Read 128-bit BigInt', () {
      final bigValue = BigInt.parse('123456789ABCDEF123456789ABCDEF', radix: 16);
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBigInt(bigValue, binaryDigits: 128);
      final reader = buffer.getReader();
      expect(reader.readBigInt(binaryDigits: 128), bigValue);
    });
  });

  group('String and Edge Cases', () {
    test('Write/Read UTF-8 string with padding', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUtf8String('Hi', binaryDigits: 8); // 2 bytes
      print(buffer);
      final reader = buffer.getReader();
      expect(reader.readUtf8String(2 * 8, binaryDigits: 8), 'Hi');
    });

    test('Buffer auto-expansion', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.seekTo(100); // Force expansion
      writer.writeBit(1);
      expect(buffer.bitLength >= 101, isTrue);
    });

    test('Out-of-bounds read throws RangeError', () {
      final buffer = BitBuffer();
      final reader = buffer.getReader();
      expect(() => reader.readBit(), throwsRangeError);
    });
  });

  group('Writer Position Control', () {
    test('Overwrite bits with seekTo', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeUint(0xFF, binaryDigits: 8); // Write 0xFF at position 0-7
      writer.seekTo(4); // Move to position 4
      writer.writeUint(0xA, binaryDigits: 4); // Overwrite bits 4-7 with 0xA
      final reader = buffer.getReader();
      expect(reader.readUint(binaryDigits: 8), 0xFA); // 11111010
    });
  });

  group('Complex Scenario', () {
    test('Mixed data types', () {
      final buffer = BitBuffer();
      final writer = buffer.getWriter();
      writer.writeBool(true);
      writer.writeInt(-42, binaryDigits: 16);
      writer.writeUtf8String('Dart', binaryDigits: 8);

      final reader = buffer.getReader();
      expect(reader.readBool(), isTrue);
      expect(reader.readInt(binaryDigits: 16), -42);
      expect(reader.readUtf8String(4 * 8, binaryDigits: 8), 'Dart');
    });
  });
}
