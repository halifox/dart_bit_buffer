# dart_bit_buffer

`dart_bit_buffer` 是一个高效的位操作缓冲区库，提供了对位级别数据的读写操作，适用于需要精细控制比特流的场景。

---

## ⚙️ 功能

- 🔢 提供高效的比特操作，包括读取和写入单个比特、整数、BigInt、布尔值等
- 🛠️ 支持有符号和无符号整数的位级别操作，支持不同的比特顺序（MSBFirst, LSBFirst）
- 🔄 提供缓冲区的动态扩展和跳过、寻址等功能
- 🧠 提供灵活的缓冲区管理，自动扩展或裁剪缓冲区大小

---

## 📥 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  bit_buffer:
    git:
      url: https://github.com/halifox/dart_bit_buffer
      ref: 1.0.6
```

---

## 🛠️ 使用方法

### 基本示例：创建缓冲区

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // 从无符号整数列表创建 BitBuffer
  List<int> data = [123, 456, 789];
  BitBuffer bitBuffer = BitBuffer.formUIntList(data, binaryDigits: 64);

  // 转换回无符号整数列表
  List<int> unsignedInts = bitBuffer.toUIntList(binaryDigits: 64);
  print(unsignedInts); // 输出：[123, 456, 789]
}
```

### 写入与读取数据

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // 创建一个空的 BitBuffer
  BitBuffer bitBuffer = BitBuffer();

  // 创建一个 Writer 对象
  BitBufferWriter writer = BitBufferWriter(bitBuffer);

  // 写入布尔值
  writer.putBool(true);
  writer.putBool(false);

  // 写入单个位
  writer.putBit(1);
  writer.putBit(0);

  // 写入有符号整数
  writer.putInt(-42, binaryDigits: 16, order: BitOrder.LSBFirst);

  // 写入无符号整数
  writer.putUnsignedInt(42, binaryDigits: 16, order: BitOrder.MSBFirst);

  // 写入 BigInt
  writer.putBigInt(BigInt.from(-987654321), binaryDigits: 128);

  // 写入无符号 BigInt
  writer.putUnsignedBigInt(BigInt.from(987654321), binaryDigits: 128);

  // 创建一个 Reader 对象
  BitBufferReader reader = BitBufferReader(bitBuffer);

  // 读取布尔值
  print(reader.getBool()); // 输出：true
  print(reader.getBool()); // 输出：false

  // 读取单个位
  print(reader.getBit()); // 输出：1
  print(reader.getBit()); // 输出：0

  // 读取有符号整数
  print(reader.getInt(binaryDigits: 16, order: BitOrder.LSBFirst)); // 输出：-42

  // 读取无符号整数
  print(reader.getUnsignedInt(binaryDigits: 16, order: BitOrder.MSBFirst)); // 输出：42

  // 读取 BigInt
  print(reader.getBigInt(binaryDigits: 128)); // 输出：-987654321

  // 读取无符号 BigInt
  print(reader.getUnsignedBigInt(binaryDigits: 128)); // 输出：987654321
}
```

### 位操作与缓冲区大小管理

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // 创建一个空的 BitBuffer
  BitBuffer bitBuffer = BitBuffer();

  // 写入单个位
  BitBufferWriter writer = BitBufferWriter(bitBuffer);
  writer.putBit(1);
  writer.putBit(0);
  writer.putBit(1);

  // 手动跳过指定位置
  writer.skip(5);
  writer.putBit(1); // 写入位置变为 9

  // 读取缓冲区的位
  BitBufferReader reader = BitBufferReader(bitBuffer);

  print(reader.getBit()); // 输出：1
  print(reader.getBit()); // 输出：0
  print(reader.getBit()); // 输出：1

  // 跳过位置
  reader.skip(5);
  print(reader.getBit()); // 输出：1

  // 获取剩余可用的位数
  print(reader.remainingSize); // 输出：0
}
```

### 使用 `BitBuffer` 的其他方法

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // 从 Uint8List 数据创建 BitBuffer
  Uint8List data = Uint8List.fromList([0xF0, 0x0F]);
  BitBuffer bitBuffer = BitBuffer.formUInt8List(data);

  // 转换回 Uint8List 数据
  Uint8List result = bitBuffer.toUInt8List();
  print(result); // 输出：[240, 15]

  // 位操作
  bitBuffer.setBit(0, 0); // 将第 0 位设置为 0
  print(bitBuffer.getBit(0)); // 输出：0

  // 动态分配位
  bitBuffer.allocate(16); // 添加 16 位的空间

  // 读取位数
  print(bitBuffer.bitCount); // 输出：32（初始 16 位 + 分配的 16 位）
}
```

### 综合示例

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // 假设我们有一个结构化的数据要序列化：
  // 布尔值：true
  // 有符号整数：-123（16 位）
  // 无符号整数：456（16 位）
  // BigInt：987654321（128 位）

  // 序列化
  BitBuffer bitBuffer = BitBuffer();
  BitBufferWriter writer = BitBufferWriter(bitBuffer);

  writer.putBool(true);
  writer.putInt(-123, binaryDigits: 16);
  writer.putUnsignedInt(456, binaryDigits: 16);
  writer.putBigInt(BigInt.from(987654321), binaryDigits: 128);

  // 反序列化
  BitBufferReader reader = BitBufferReader(bitBuffer);

  bool flag = reader.getBool();
  int signedInt = reader.getInt(binaryDigits: 16);
  int unsignedInt = reader.getUnsignedInt(binaryDigits: 16);
  BigInt bigIntValue = reader.getBigInt(binaryDigits: 128);

  print('布尔值：$flag'); // 输出：布尔值：true
  print('有符号整数：$signedInt'); // 输出：有符号整数：-123
  print('无符号整数：$unsignedInt'); // 输出：无符号整数：456
  print('BigInt：$bigIntValue'); // 输出：BigInt：987654321
}
```

### 综合功能验证

```dart
import 'package:bit_buffer/bit_buffer.dart';

void main() {
  // 测试缓冲区写入和读取所有支持类型的数据
  BitBuffer bitBuffer = BitBuffer();
  BitBufferWriter writer = BitBufferWriter(bitBuffer);

  writer.putBool(true);
  writer.putUnsignedInt(12345, binaryDigits: 32);
  writer.putBigInt(BigInt.parse('123456789012345678901234567890'), binaryDigits: 256);

  BitBufferReader reader = BitBufferReader(bitBuffer);

  print(reader.getBool()); // 输出：true
  print(reader.getUnsignedInt(binaryDigits: 32)); // 输出：12345
  print(reader.getBigInt(binaryDigits: 256)); // 输出：123456789012345678901234567890
}
```

---

## API

### BitBuffer

用于管理位缓冲区的核心类。它支持读取和写入位、整数和 BigInt 值。

#### 方法

- `BitBuffer.formUInt8List(Uint8List data, {BitOrder order})`：从无符号 8 位整数列表创建 `BitBuffer`。
- `BitBuffer.toUInt8List({BitOrder order})`：将缓冲区转换回无符号 8 位整数列表。
- `BitBuffer.formUIntList(List<int> data, {int binaryDigits = 64, BitOrder order})`：从无符号整数列表创建 `BitBuffer`。
    - `binaryDigits`：每个整数占用的二进制位数，默认值为 64 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前（Most Significant Bit First），`BitOrder.LSBFirst` 表示低位比特在前（Least Significant Bit First），默认为 `MSBFirst`。
- `BitBuffer.toUIntList({int binaryDigits = 64, BitOrder order})`：将缓冲区转换为无符号整数列表。
- `BitBuffer.formIntList(List<int> data, {int binaryDigits = 64, BitOrder order})`：从有符号整数列表创建 `BitBuffer`。
- `BitBuffer.toIntList({int binaryDigits = 64, BitOrder order})`：将缓冲区转换为有符号整数列表。
- `BitBuffer.getBit(int position)`：获取指定位置的位。
- `BitBuffer.setBit(int position, int bit)`：设置指定位置的位。

### BitBufferWriter

用于向 `BitBuffer` 写入数据。

#### 方法

- `putBool(bool value)`：写入一个布尔值（true = 1，false = 0）。
- `putBit(int value)`：向缓冲区写入一个位。
- `putInt(int value, {int binaryDigits = 64, BitOrder order})`：向缓冲区写入一个有符号整数。
    - `binaryDigits`：指定要写入的整数的二进制位数，默认为 64 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `putBigInt(BigInt value, {int binaryDigits = 128, BitOrder order})`：向缓冲区写入一个 BigInt 值。
    - `binaryDigits`：指定要写入的 BigInt 的二进制位数，默认为 128 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `putUnsignedInt(int value, {int binaryDigits = 64, BitOrder order})`：向缓冲区写入一个无符号整数。
    - `binaryDigits`：指定要写入的无符号整数的二进制位数，默认为 64 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `putUnsignedBigInt(BigInt value, {int binaryDigits = 128, BitOrder order})`：向缓冲区写入一个无符号 BigInt 值。
    - `binaryDigits`：指定要写入的无符号 BigInt 的二进制位数，默认为 128 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `putIntList(List<int> value, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: 写入一个整数列表到缓冲区。
  - `value`: 要写入的整数列表。
  - `binaryDigits`: 每个整数的二进制位数，默认为 8 位。
  - `order`: 位顺序，`BitOrder.MSBFirst` 表示最高有效位优先，`BitOrder.LSBFirst` 表示最低有效位优先，默认为 `MSBFirst`。
- `putStringByUtf8(String value, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: 写入一个 UTF-8 编码的字符串到缓冲区。
  - `value`: 要写入的字符串。
  - `binaryDigits`: 每个字符的二进制位数，默认为 8 位。
  - `order`: 位顺序，`BitOrder.MSBFirst` 表示最高有效位优先，`BitOrder.LSBFirst` 表示最低有效位优先，默认为 `MSBFirst`。

### BitBufferReader

用于从 `BitBuffer` 读取数据。

#### 方法

- `getBool()`：从缓冲区读取一个布尔值。
- `getBit()`：从缓冲区读取一个位。
- `getInt({int binaryDigits = 64, BitOrder order})`：从缓冲区读取一个有符号整数。
    - `binaryDigits`：指定要读取的整数的二进制位数，默认为 64 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `getBigInt({int binaryDigits = 128, BitOrder order})`：从缓冲区读取一个 BigInt。
    - `binaryDigits`：指定要读取的 BigInt 的二进制位数，默认为 128 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `getUnsignedInt({int binaryDigits = 64, BitOrder order})`：从缓冲区读取一个无符号整数。
    - `binaryDigits`：指定要读取的无符号整数的二进制位数，默认为 64 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `getUnsignedBigInt({int binaryDigits = 128, BitOrder order})`：从缓冲区读取一个无符号 BigInt。
    - `binaryDigits`：指定要读取的无符号 BigInt 的二进制位数，默认为 128 位。
    - `order`：比特序（Bit Order），描述单个字节内比特的排列顺序，`BitOrder.MSBFirst` 表示高位比特在前，`BitOrder.LSBFirst` 表示低位比特在前，默认为 `MSBFirst`。
- `getIntList(int size, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: 从缓冲区读取一个整数列表。
  - `size`: 列表中整数的数量。
  - `binaryDigits`: 每个整数的二进制位数，默认为 8 位。
  - `order`: 位顺序，`BitOrder.MSBFirst` 表示最高有效位优先，`BitOrder.LSBFirst` 表示最低有效位优先，默认为 `MSBFirst`。
  - 返回值：整数列表。
- `getStringByUtf8(int size, {int binaryDigits = 8, BitOrder order = BitOrder.MSBFirst})`: 从缓冲区读取一个 UTF-8 编码的字符串。
  - `size`: 字符串的长度。
  - `binaryDigits`: 每个字符的二进制位数，默认为 8 位。
  - `order`: 位顺序，`BitOrder.MSBFirst` 表示最高有效位优先，`BitOrder.LSBFirst` 表示最低有效位优先，默认为 `MSBFirst`。
  - 返回值：UTF-8 编码的字符串。

---

## 🤝 贡献

我们欢迎任何形式的社区贡献！

请阅读 [贡献指南](CONTRIBUTING.md)，了解如何提交 Issue、请求功能或贡献代码。

---

## 📜 许可证

本项目遵循 [LGPL-3.0 License](LICENSE)。

---

## 🙏 致谢

感谢所有贡献者和社区支持！

## 📢 法律声明

本开源项目仅供学习和交流用途。由于可能涉及专利或版权相关内容，请在使用前确保已充分理解相关法律法规。未经授权，**请勿将本工具用于商业用途或进行任何形式的传播**。

本项目的所有代码和相关内容仅供个人技术学习与参考，任何使用产生的法律责任由使用者自行承担。

感谢您的理解与支持。