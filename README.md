# dart_bit_buffer

A Dart library for efficient bit-level data manipulation, providing flexible reading and writing of various data types with configurable bit ordering.

## Features

- **BitBuffer**: Core class for storing and managing bit-level data.
- **BitBufferReader**: Sequential reader for extracting primitive types (bool, int, BigInt, String) from a `BitBuffer`.
- **BitBufferWriter**: Sequential writer for encoding data into a `BitBuffer`, with automatic buffer expansion.
- **BitOrder Support**: Configurable MSB-first or LSB-first bit ordering within bytes.

## Installation

Add the following to your `pubspec.yaml` (replace `[version]` with the latest release):

```yaml
dependencies:
  bit_buffer:
    git:
      url: https://github.com/halifox/dart_bit_buffer
      ref: 2.0.0
```

## Usage

### Basic Example

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Create a BitBuffer and writer
  final buffer = BitBuffer();
  final writer = buffer.getWriter();

  // Write data
  writer.writeBool(true);
  writer.writeUint(255, binaryDigits: 8); // Write 8-bit unsigned integer
  writer.writeUtf8String('Hello', binaryDigits: 8); // Write UTF-8 string

  // Create a reader
  final reader = buffer.getReader();
  
  // Read data
  final boolValue = reader.readBool();
  final uintValue = reader.readUint(binaryDigits: 8);
  final strValue = reader.readUtf8String(5, binaryDigits: 8); // Read 5-byte string

  print('Bool: $boolValue'); // true
  print('UInt: $uintValue'); // 255
  print('String: $strValue'); // Hello
}
```

### BitBuffer Initialization

```dart
// From bytes (Uint8List)
final bytes = Uint8List.fromList([0xFF, 0x00]);
final bufferFromBytes = BitBuffer.fromUint8List(bytes, order: BitOrder.LSBFirst);

// To bytes
final outputBytes = bufferFromBytes.toUint8List(order: BitOrder.MSBFirst);
```

### BitOrder Explained

- **MSBFirst**: Most significant bit first (e.g., `0b10100000` represents 160).
- **LSBFirst**: Least significant bit first (e.g., `0b00000101` represents 5).

Example of writing an 8-bit integer `5` with different orders:

```dart
final writer = buffer.getWriter();
writer.writeUint(5, binaryDigits: 8, order: BitOrder.MSBFirst); // Bits: 00000101
writer.writeUint(5, binaryDigits: 8, order: BitOrder.LSBFirst); // Bits: 10100000
```

## API Overview

### BitBuffer

- `fromUint8List()`/`toUint8List()`: Convert between bytes and bit buffer.
- `readBit()`/`writeBit()`: Direct bit access.
- `readUint()`/`writeUint()`: Read/write integers with configurable bit length and order.
- `readUtf8String()`/`writeUtf8String()`: String encoding/decoding.

### BitBufferReader

- `readBool()`, `readInt()`, `readBigInt()`, `readUtf8String()`: Sequential reads.
- `skip()`, `seekTo()`: Navigate within the buffer.

### BitBufferWriter

- `writeBool()`, `writeInt()`, `writeBigInt()`, `writeUtf8String()`: Sequential writes.
- `allocateIfNeeded()`: Ensure buffer capacity before writing.

## Notes

- **Performance**: Prefer reusing `BitBuffer` instances for high-frequency operations.
- **Error Handling**: Methods throw `RangeError` for invalid positions or overflows.
- **Bit Order**: Ensure consistency between writing and reading order.

## License

This project is licensed under the [LGPL-3.0 License](LICENSE).