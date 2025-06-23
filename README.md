# 🐾 宠物消消乐·炫彩版

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.5.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows-lightgrey?style=for-the-badge)

*一款充满魅力的宠物主题消除游戏，采用Flutter开发*

[🎮 立即体验](#安装运行) • [📖 开发文档](./docs/development/) • [🐛 问题反馈](#问题反馈) • [🤝 贡献代码](./docs/development/CONTRIBUTING.md)

</div>

---

## 📱 项目简介

宠物消消乐·炫彩版是一款基于Flutter开发的跨平台消除类游戏。游戏以可爱的宠物为主题，融合了现代化的UI设计和流畅的动画效果，为玩家带来愉悦的游戏体验。

### ✨ 核心特性

- 🎨 **精美视觉效果**：炫彩渐变背景，动态粒子系统，流畅的动画过渡
- 🐱 **萌宠主题**：6种不同的可爱宠物角色（猫咪、狗狗、兔子、熊猫、狐狸、独角兽）
- 🎯 **丰富玩法**：经典三消玩法，支持连锁消除，动态难度调整
- 🏆 **进阶系统**：关卡模式，分数系统，成就奖励
- 📱 **跨平台**：支持iOS、Android、Web、Windows多平台运行
- ⚡ **高性能**：优化的渲染性能，流畅的60fps体验

### 🎮 游戏玩法

1. **基础消除**：点击选择相邻的宠物方块进行交换
2. **匹配规则**：横向或纵向3个或以上相同宠物即可消除
3. **连锁反应**：消除后新方块下落可能触发连锁消除
4. **目标完成**：在限定步数内达到目标分数即可过关
5. **难度递增**：随着关卡提升，目标分数和挑战难度逐渐增加

---

## 🚀 安装运行

### 系统要求

- **Flutter SDK**: 3.5.0 或更高版本
- **Dart SDK**: 3.0.0 或更高版本
- **开发环境**: VS Code / Android Studio / IntelliJ IDEA

### 快速开始

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/pet-match-game.git
   cd pet-match-game
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   # 调试模式运行
   flutter run
   
   # 指定平台运行
   flutter run -d windows    # Windows桌面
   flutter run -d chrome     # Web浏览器
   flutter run -d android    # Android设备/模拟器
   flutter run -d ios        # iOS设备/模拟器
   ```

4. **构建发布版本**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS App
   flutter build ios --release
   
   # Web应用
   flutter build web --release
   
   # Windows应用
   flutter build windows --release
   ```

---

## 🏗️ 技术架构

### 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.5.0+ | 跨平台UI框架 |
| Dart | 3.0.0+ | 编程语言 |
| Provider | ^6.1.1 | 状态管理 |
| Flutter Animate | ^4.3.0 | 动画效果 |
| Lottie | ^3.1.0 | 矢量动画 |
| Confetti | ^0.7.0 | 彩带特效 |

### 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── pet_tile.dart        # 宠物方块模型
│   └── pet_type.dart        # 宠物类型定义
├── providers/                # 状态管理
│   └── game_provider.dart   # 游戏状态管理器
├── widgets/                  # UI组件
│   ├── game_grid.dart       # 游戏网格
│   ├── game_info_panel.dart # 信息面板
│   ├── game_over_dialog.dart# 游戏结束对话框
│   └── pet_tile_widget.dart # 宠物方块组件
└── assets/                   # 资源文件
    ├── images/              # 图片资源
    ├── sounds/              # 音效资源
    └── fonts/               # 字体资源
```

### 核心架构模式

- **MVVM架构**：使用Provider进行状态管理
- **组件化开发**：模块化的Widget设计
- **响应式编程**：基于Stream和Future的异步处理
- **资源管理**：统一的资源加载和释放机制

---

## 🔧 开发文档

### 核心类说明

#### GameProvider
游戏状态管理的核心类，负责：
- 游戏逻辑处理（匹配检测、消除算法）
- 状态管理（分数、关卡、步数）
- 动画控制（交换、消除、下落动画）

#### PetTile
宠物方块的数据模型：
```dart
class PetTile {
  final int row, col;           // 位置坐标
  final PetType petType;        // 宠物类型
  bool isSelected;              // 选中状态
  bool isMatched;               // 匹配状态
  bool isFalling;               // 下落状态
}
```

#### PetType
宠物类型枚举，包含：
- 6种宠物类型（cat, dog, rabbit, panda, fox, unicorn）
- 每种宠物的颜色、表情、名称定义

### 性能优化

1. **内存管理**
   - 使用对象池减少GC压力
   - 及时释放动画控制器资源
   - 优化粒子系统内存占用

2. **渲染优化**
   - 减少不必要的Widget重建
   - 使用const构造函数
   - 合理使用AnimatedBuilder

3. **异步处理**
   - 避免嵌套回调，使用async/await
   - 添加操作锁防止竞态条件
   - 控制递归深度避免栈溢出

---

## 🧪 测试指南

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 生成测试覆盖率报告
flutter test --coverage
```

### 测试重点

1. **功能测试**
   - 匹配算法正确性
   - 分数计算准确性
   - 关卡进度逻辑

2. **性能测试**
   - 内存泄漏检测
   - 动画流畅度测试
   - 长时间运行稳定性

3. **兼容性测试**
   - 多平台运行测试
   - 不同屏幕尺寸适配
   - 各版本Flutter兼容性

---

## 🐛 问题反馈

如果您在使用过程中遇到问题，请通过以下方式反馈：

1. **GitHub Issues**: [提交Issue](https://github.com/your-username/pet-match-game/issues)
2. **邮箱联系**: developer@example.com
3. **讨论区**: [GitHub Discussions](https://github.com/your-username/pet-match-game/discussions)

### Bug报告模板

```markdown
**问题描述**
简明扼要地描述遇到的问题

**复现步骤**
1. 执行的操作
2. 观察到的现象
3. 期望的结果

**环境信息**
- Flutter版本: 
- 设备平台: 
- 操作系统: 
- 游戏版本: 
```

---

## 🤝 贡献指南

我们欢迎社区贡献！请阅读 [CONTRIBUTING.md](./docs/development/CONTRIBUTING.md) 了解详细信息。

### 贡献类型

- 🐛 **Bug修复**: 修复已知问题
- ✨ **新功能**: 添加新的游戏特性
- 📝 **文档完善**: 改进项目文档
- 🎨 **UI优化**: 提升用户界面体验
- ⚡ **性能优化**: 提高游戏性能

### 开发流程

1. Fork项目仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](./docs/maintenance/LICENSE) 文件了解详情。

---

## 🙏 致谢

- [Flutter团队](https://flutter.dev/) - 优秀的跨平台框架
- [Provider](https://pub.dev/packages/provider) - 简洁的状态管理方案
- [Flutter Animate](https://pub.dev/packages/flutter_animate) - 强大的动画库
- 所有为项目做出贡献的开发者

---

<div align="center">

**如果这个项目对您有帮助，请给我们一个 ⭐**

[🔝 回到顶部](#宠物消消乐炫彩版)

</div>
