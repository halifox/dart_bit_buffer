# dart_bit_buffer

[中文文档](README-CN.md)

`dart_bit_buffer` is an efficient bit manipulation buffer library that provides read and write operations for bit-level data, suitable for scenarios where fine control over bitstreams is required.

---

## ⚙️ Features

- 🔢 Provides efficient bit operations, including reading and writing single bits, integers, BigInts, booleans, etc.
- 🛠️ Supports bit-level operations for signed and unsigned integers, with support for different bit orders (MSBFirst, LSBFirst).
- 🔄 Provides dynamic buffer expansion, skipping, addressing, and other functionalities.
- 🧠 Offers flexible buffer management, automatically expanding or trimming buffer size as needed.

---

## 📥 Installation

Add the following dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  bit_buffer:
    git:
      url: https://github.com/halifox/dart_bit_buffer
      ref: 1.0.5
```

---

## 🛠️ Usage

### Basic Example: Create a Buffer

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Create BitBuffer from an unsigned integer list
  List<int> data = [123, 456, 789];
  BitBuffer bitBuffer = BitBuffer.formUIntList(data, binaryDigits: 64);

  // Convert back to unsigned integer list
  List<int> unsignedInts = bitBuffer.toUIntList(binaryDigits: 64);
  print(unsignedInts); // Output: [123, 456, 789]
}
```

### Writing and Reading Data

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Create an empty BitBuffer
  BitBuffer bitBuffer = BitBuffer();

  // Create a Writer object
  BitBufferWriter writer = BitBufferWriter(bitBuffer);

  // Write booleans
  writer.putBool(true);
  writer.putBool(false);

  // Write single bits
  writer.putBit(1);
  writer.putBit(0);

  // Write signed integer
  writer.putInt(-42, binaryDigits: 16, order: BitOrder.LSBFirst);

  // Write unsigned integer
  writer.putUnsignedInt(42, binaryDigits: 16, order: BitOrder.MSBFirst);

  // Write BigInt
  writer.putBigInt(BigInt.from(-987654321), binaryDigits: 128);

  // Write unsigned BigInt
  writer.putUnsignedBigInt(BigInt.from(987654321), binaryDigits: 128);

  // Create a Reader object
  BitBufferReader reader = BitBufferReader(bitBuffer);

  // Read booleans
  print(reader.getBool()); // Output: true
  print(reader.getBool()); // Output: false

  // Read single bits
  print(reader.getBit()); // Output: 1
  print(reader.getBit()); // Output: 0

  // Read signed integer
  print(reader.getInt(binaryDigits: 16, order: BitOrder.LSBFirst)); // Output: -42

  // Read unsigned integer
  print(reader.getUnsignedInt(binaryDigits: 16, order: BitOrder.MSBFirst)); // Output: 42

  // Read BigInt
  print(reader.getBigInt(binaryDigits: 128)); // Output: -987654321

  // Read unsigned BigInt
  print(reader.getUnsignedBigInt(binaryDigits: 128)); // Output: 987654321
}
```

### Bit Operations and Buffer Size Management

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Create an empty BitBuffer
  BitBuffer bitBuffer = BitBuffer();

  // Write single bits
  BitBufferWriter writer = BitBufferWriter(bitBuffer);
  writer.putBit(1);
  writer.putBit(0);
  writer.putBit(1);

  // Manually skip to a specific position
  writer.skip(5);
  writer.putBit(1); // Write at position 9

  // Read bits from the buffer
  BitBufferReader reader = BitBufferReader(bitBuffer);

  print(reader.getBit()); // Output: 1
  print(reader.getBit()); // Output: 0
  print(reader.getBit()); // Output: 1

  // Skip position
  reader.skip(5);
  print(reader.getBit()); // Output: 1

  // Get remaining bit count
  print(reader.remainingSize); // Output: 0
}
```

### Other Methods for `BitBuffer`

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Create BitBuffer from Uint8List data
  Uint8List data = Uint8List.fromList([0xF0, 0x0F]);
  BitBuffer bitBuffer = BitBuffer.formUInt8List(data);

  // Convert back to Uint8List data
  Uint8List result = bitBuffer.toUInt8List();
  print(result); // Output: [240, 15]

  // Bit operations
  bitBuffer.setBit(0, 0); // Set bit at position 0 to 0
  print(bitBuffer.getBit(0)); // Output: 0

  // Dynamically allocate bits
  bitBuffer.allocate(16); // Add 16 bits of space

  // Read bit count
  print(bitBuffer.bitCount); // Output: 32 (initial 16 + allocated 16)
}
```

### Comprehensive Example

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Suppose we have structured data to serialize:
  // Boolean: true
  // Signed integer: -123 (16 bits)
  // Unsigned integer: 456 (16 bits)
  // BigInt: 987654321 (128 bits)

  // Serialization
  BitBuffer bitBuffer = BitBuffer();
  BitBufferWriter writer = BitBufferWriter(bitBuffer);

  writer.putBool(true);
  writer.putInt(-123, binaryDigits: 16);
  writer.putUnsignedInt(456, binaryDigits: 16);
  writer.putBigInt(BigInt.from(987654321), binaryDigits: 128);

  // Deserialization
  BitBufferReader reader = BitBufferReader(bitBuffer);

  bool flag = reader.getBool();
  int signedInt = reader.getInt(binaryDigits: 16);
  int unsignedInt = reader.getUnsignedInt(binaryDigits: 16);
  BigInt bigIntValue = reader.getBigInt(binaryDigits: 128);

  print('Boolean: $flag'); // Output: Boolean: true
  print('Signed integer: $signedInt'); // Output: Signed integer: -123
  print('Unsigned integer: $unsignedInt'); // Output: Unsigned integer: 456
  print('BigInt: $bigIntValue'); // Output: BigInt: 987654321
}
```

### Comprehensive Feature Validation

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // Test writing and reading all supported data types from the buffer
  BitBuffer bitBuffer = BitBuffer();
  BitBufferWriter writer = BitBufferWriter(bitBuffer);

  writer.putBool(true);
  writer.putUnsignedInt(12345, binaryDigits: 32);
  writer.putBigInt(BigInt.parse('123456789012345678901234567890'), binaryDigits: 256);

  BitBufferReader reader = BitBufferReader(bitBuffer);

  print(reader.getBool()); // Output: true
  print(reader.getUnsignedInt(binaryDigits: 32)); // Output: 12345
  print(reader.getBigInt(binaryDigits: 256)); // Output: 123456789012345678901234567890
}
```

---

## API

### BitBuffer

The core class for managing bit buffers. It supports reading and writing bits, integers, and BigInt values.

#### Methods

- `BitBuffer.formUInt8List(Uint8List data, {BitOrder order})`: Creates a `BitBuffer` from a list of unsigned 8-bit integers.
- `BitBuffer.toUInt8List({BitOrder order})`: Converts the buffer back to a list of unsigned 8-bit integers.
- `BitBuffer.formUIntList(List<int> data, {int binaryDigits = 64, BitOrder order})`: Creates a `BitBuffer` from a list of unsigned integers.
  - `binaryDigits`: The number of binary digits each integer occupies, default is 64 bits.
  - `order`: The bit order within the byte, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `BitBuffer.toUIntList({int binaryDigits = 64, BitOrder order})`: Converts the buffer to a list of unsigned integers.
- `BitBuffer.formIntList(List<int> data, {int binaryDigits = 64, BitOrder order})`: Creates a `BitBuffer` from a list of signed integers.
- `BitBuffer.toIntList({int binaryDigits = 64, BitOrder order})`: Converts the buffer to a list of signed integers.
- `BitBuffer.getBit(int position)`: Gets the bit at the specified position.
- `BitBuffer.setBit(int position, int bit)`: Sets the bit at the specified position.

### BitBufferWriter

Used to write data into a `BitBuffer`.

#### Methods

- `putBool(bool value)`: Write a boolean value (true = 1, false = 0).
- `putBit(int value)`: Write a single bit into the buffer.
- `putInt(int value, {int binaryDigits = 64, BitOrder order})`: Write a signed integer into the buffer.
    - `binaryDigits`: The number of binary digits for the integer, default is 64 bits.
    - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `putBigInt(BigInt value, {int binaryDigits = 128, BitOrder order})`: Write a BigInt value into the buffer.
  - `binaryDigits`: The number of binary digits for the BigInt, default is 128 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `putUnsignedInt(int value, {int binaryDigits = 64, BitOrder order})`: Write an unsigned integer into the buffer.
  - `binaryDigits`: The number of binary digits for the unsigned integer, default is 64 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `putUnsignedBigInt(BigInt value, {int binaryDigits = 128, BitOrder order})`: Write an unsigned BigInt value into the buffer.
  - `binaryDigits`: The number of binary digits for the unsigned BigInt, default is 128 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `putIntList(List<int> value, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: Write a list of integers into the buffer.
  - `value`: The list of integers to write.
  - `binaryDigits`: The number of binary digits for each integer, default is 8 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `putStringByUtf8(String value, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: Write a UTF-8 encoded string into the buffer.
  - `value`: The string to write.
  - `binaryDigits`: The number of binary digits for each character, default is 8 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.

### BitBufferReader

Used to read data from a `BitBuffer`.

#### Methods

- `getBool()`: Reads a boolean value from the buffer.
- `getBit()`: Reads a single bit from the buffer.
- `getInt({int binaryDigits = 64, BitOrder order})`: Reads a signed integer from the buffer.
  - `binaryDigits`: The number of binary digits for the integer, default is 64 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `getBigInt({int binaryDigits = 128, BitOrder order})`: Reads a BigInt from the buffer.
  - `binaryDigits`: The number of binary digits for the BigInt, default is 128 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `getUnsignedInt({int binaryDigits = 64, BitOrder order})`: Reads an unsigned integer from the buffer.
  - `binaryDigits`: The number of binary digits for the unsigned integer, default is 64 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `getUnsignedBigInt({int binaryDigits = 128, BitOrder order})`: Reads an unsigned BigInt from the buffer.
  - `binaryDigits`: The number of binary digits for the unsigned BigInt, default is 128 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
- `getIntList(int size, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: Read a list of integers from the buffer.
  - `size`: The number of integers in the list.
  - `binaryDigits`: The number of binary digits for each integer, default is 8 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
  - Return value: The list of integers.
- `getStringByUtf8(int size, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: Read a UTF-8 encoded string from the buffer.
  - `size`: The length of the string.
  - `binaryDigits`: The number of binary digits for each character, default is 8 bits.
  - `order`: The bit order, `BitOrder.MSBFirst` means most significant bit first, `BitOrder.LSBFirst` means least significant bit first, default is `MSBFirst`.
  - Return value: The UTF-8 encoded string.
---

## 🤝 Contributing

We welcome all forms of community contributions!

Please read the [contributing guide](CONTRIBUTING.md) for instructions on how to submit issues, request features, or contribute code.

---

## 📜 License

This project is licensed under the [LGPL-3.0 License](LICENSE).

---

## 🙏 Acknowledgements

Thanks to all the contributors and community supporters!

## 📢 Legal Disclaimer

This open-source project is for educational and communication purposes only. It may involve patents or copyrights, so please ensure that you fully understand the applicable laws and regulations before using it. **Do not use this tool for commercial purposes or distribute it in any form without authorization**.

All code and related content in this project are for personal technical learning and reference only. Any legal responsibilities arising from usage are to be borne by the user.

Thank you for your understanding and support.