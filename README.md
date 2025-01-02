# dart_bit_buffer

`dart_bit_buffer` 是一个高效的位操作缓冲区库，提供了对位级别数据的读写操作，适用于需要精细控制比特流的场景。

---

## ⚙️ 功能

- 🔢 提供高效的比特操作，包括读取和写入单个比特、整数、布尔值等
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
      ref: 1.0.0
```

---

## 🛠️ 使用方法

```dart
final buffer = BitBuffer();

// 创建 BitBufferWriter 用于写入数据
final writer = BitBufferWriter(buffer);
writer.putBool(true);
writer.putInt(-123, binaryDigits: 32);

// 创建 BitBufferReader 用于读取数据
final reader = BitBufferReader(buffer);
bool value = reader.getBool();  // 读取布尔值
int number = reader.getInt(binaryDigits: 32);  // 读取有符号整数
```

**写入单个比特**

```dart
writer.putBit(1); // 写入 1
writer.putBit(0); // 写入 0
```

**写入整数**

```dart
writer.putInt(1234, binaryDigits: 32); // 写入 32 位整数
writer.putUnsignedInt(4321, binaryDigits: 32); // 写入无符号 32 位整数
```

**读取数据**

```dart
int value = reader.getInt(binaryDigits: 32);  // 读取一个有符号整数
```

---

## API

### BitBufferWriter

- **putBool**: 写入一个布尔值（true/false）。
- **putBit**: 写入一个单比特值（0 或 1）。
- **putInt**: 写入一个有符号整数。
- **putUnsignedInt**: 写入一个无符号整数。
- **skip**: 跳过指定数量的比特。
- **seekTo**: 将写入位置移动到指定位置。
- **allocateIfNeeded**: 确保有足够空间写入指定数量的比特。

### BitBufferReader

- **getBool**: 读取一个布尔值（true/false）。
- **getBit**: 读取一个单比特值（0 或 1）。
- **getInt**: 读取一个有符号整数。
- **getUnsignedInt**: 读取一个无符号整数。
- **skip**: 跳过指定数量的比特。
- **seekTo**: 将读取位置移动到指定位置。

### BitBuffer

- **allocate**: 动态分配更多比特空间。
- **trim**: 裁剪掉多余的比特空间。
- **getBit**: 获取指定位置的比特值。
- **setBit**: 设置指定位置的比特值。
- **toSectionString**: 获取指定范围内的比特序列字符串。

---

## 🤝 贡献

我们欢迎任何形式的社区贡献！

请阅读 [贡献指南 (CONTRIBUTING.md)](CONTRIBUTING.md)，了解如何提交 Issue、请求功能或贡献代码。

---

## 📜 许可证

本项目遵循 [LGPL-3.0 License](License)。

---

## 🙏 致谢

感谢所有贡献者和社区支持！

## 📢 法律声明

本开源项目仅供学习和交流用途。由于可能涉及专利或版权相关内容，请在使用前确保已充分理解相关法律法规。未经授权，**请勿将本工具用于商业用途或进行任何形式的传播**。

本项目的所有代码和相关内容仅供个人技术学习与参考，任何使用产生的法律责任由使用者自行承担。

感谢您的理解与支持。