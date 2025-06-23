# 🤝 贡献指南

感谢您对宠物消消乐·炫彩版项目的关注！我们非常欢迎社区的贡献，无论是代码、文档、设计还是想法建议。

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发环境设置](#开发环境设置)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [Pull Request流程](#pull-request流程)
- [问题报告](#问题报告)
- [功能建议](#功能建议)

---

## 🤝 行为准则

参与此项目的每个人都应遵守我们的行为准则：

### 我们的承诺

为了促进开放且友好的环境，我们承诺：
- 尊重所有人，无论其背景如何
- 接受建设性的批评和反馈
- 专注于对社区最有利的事情
- 对犯错的社区成员表示同理心

### 不可接受的行为

- 使用性别化语言或意象
- 人身攻击或政治攻击
- 公开或私下骚扰
- 发布他人私人信息

---

## 🚀 如何贡献

### 贡献类型

我们欢迎以下类型的贡献：

#### 🐛 Bug 修复
- 修复已知的错误和问题
- 改进错误处理机制
- 提升代码稳定性

#### ✨ 新功能
- 游戏新玩法和模式
- UI/UX改进
- 性能优化

#### 📝 文档改进
- 代码注释完善
- 使用指南更新
- API文档补充

#### 🎨 设计优化
- 界面美化
- 动画效果增强
- 用户体验提升

#### 🧪 测试改进
- 单元测试编写
- 集成测试添加
- 测试覆盖率提升

---

## 🛠️ 开发环境设置

### 前置要求

请确保您的开发环境满足以下要求：

```bash
# Flutter版本检查
flutter --version

# 应该显示类似以下信息：
# Flutter 3.5.0 • channel stable
# Dart 3.0.0
```

### 项目设置

1. **Fork 仓库**
   - 访问项目GitHub页面
   - 点击右上角 "Fork" 按钮

2. **克隆到本地**
   ```bash
   git clone https://github.com/YOUR_USERNAME/pet-match-game.git
   cd pet-match-game
   ```

3. **添加上游仓库**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/pet-match-game.git
   ```

4. **安装依赖**
   ```bash
   flutter pub get
   ```

5. **运行项目**
   ```bash
   flutter run
   ```

### IDE配置

#### VS Code 推荐插件
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Bracket Pair Colorizer
- GitLens

#### Android Studio 插件
- Flutter Plugin
- Dart Plugin

---

## 📏 代码规范

### Dart 代码风格

我们遵循 [Dart 官方代码风格指南](https://dart.dev/guides/language/effective-dart/style)：

#### 命名规范
```dart
// 类名使用大驼峰命名
class GameProvider extends ChangeNotifier { }

// 变量和方法使用小驼峰命名
int targetScore = 1000;
void resetGame() { }

// 常量使用小驼峰命名
const double tileSize = 64.0;

// 枚举值使用小驼峰命名
enum PetType { cat, dog, rabbit }
```

#### 代码组织
```dart
// 按以下顺序组织类成员：
class ExampleClass {
  // 1. 静态常量
  static const int maxLevel = 100;
  
  // 2. 实例变量
  int score = 0;
  
  // 3. 构造函数
  ExampleClass();
  
  // 4. 重写方法
  @override
  void initState() { }
  
  // 5. 公共方法
  void publicMethod() { }
  
  // 6. 私有方法
  void _privateMethod() { }
}
```

#### 注释规范
```dart
/// 游戏状态管理的核心类
/// 
/// 负责处理游戏逻辑、状态管理和动画控制
class GameProvider extends ChangeNotifier {
  /// 当前游戏分数
  int get score => _score;
  
  /// 重置游戏到初始状态
  /// 
  /// 这将清除所有进度并重新生成游戏网格
  void resetGame() {
    // 实现细节...
  }
}
```

### Flutter 最佳实践

#### Widget 设计
```dart
// 使用const构造函数减少重建
class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 优于Container()
  }
}

// 提取复杂Widget为独立类
class ComplexAnimatedWidget extends StatefulWidget {
  // 实现...
}
```

#### 性能优化
```dart
// 使用 AnimatedBuilder 而不是 setState
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: controller.value,
      child: child,
    );
  },
  child: const ExpensiveWidget(), // 不会重建
)
```

---

## 📝 提交规范

我们使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

### 提交消息格式
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 提交类型

| 类型 | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加音效系统` |
| `fix` | Bug修复 | `fix: 修复内存泄漏问题` |
| `docs` | 文档更新 | `docs: 更新API文档` |
| `style` | 代码格式 | `style: 修复代码缩进` |
| `refactor` | 代码重构 | `refactor: 重构游戏逻辑` |
| `test` | 测试相关 | `test: 添加单元测试` |
| `chore` | 构建/工具 | `chore: 更新依赖版本` |
| `perf` | 性能优化 | `perf: 优化渲染性能` |

### 提交示例
```bash
# 好的提交消息
git commit -m "feat(game): 添加连锁消除特效动画"
git commit -m "fix(ui): 修复在小屏幕设备上的布局问题"
git commit -m "docs: 更新贡献指南和代码规范"

# 避免的提交消息
git commit -m "fix bug"
git commit -m "update"
git commit -m "修改了一些东西"
```

---

## 🔄 Pull Request 流程

### 开发流程

1. **同步主分支**
   ```bash
   git checkout main
   git pull upstream main
   ```

2. **创建功能分支**
   ```bash
   git checkout -b feature/awesome-new-feature
   # 或
   git checkout -b fix/critical-bug-fix
   ```

3. **开发和测试**
   ```bash
   # 进行开发...
   flutter test  # 运行测试
   flutter analyze  # 静态分析
   ```

4. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新的游戏功能"
   ```

5. **推送分支**
   ```bash
   git push origin feature/awesome-new-feature
   ```

6. **创建 Pull Request**

### PR 检查清单

在提交 PR 之前，请确保：

- [ ] 代码通过所有测试 (`flutter test`)
- [ ] 代码通过静态分析 (`flutter analyze`)
- [ ] 遵循项目代码规范
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] 提交消息符合规范
- [ ] PR 描述清楚说明了变更内容

### PR 模板

```markdown
## 变更说明
简要描述这个PR的目的和变更内容

## 变更类型
- [ ] Bug修复
- [ ] 新功能
- [ ] 性能优化
- [ ] 文档更新
- [ ] 代码重构

## 测试
- [ ] 现有测试通过
- [ ] 添加了新的测试
- [ ] 手动测试通过

## 截图
如果涉及UI变更，请添加截图

## 相关问题
Closes #issue_number
```

---

## 🐛 问题报告

### 报告 Bug

发现 Bug 时，请：

1. 搜索现有 Issues，避免重复报告
2. 使用 Bug 报告模板
3. 提供详细的复现步骤
4. 包含必要的环境信息

### Bug 报告模板

```markdown
## Bug 描述
清楚简洁地描述问题

## 复现步骤
1. 打开应用
2. 点击 '...'
3. 观察到 '...'

## 期望行为
描述您期望发生的情况

## 实际行为
描述实际发生的情况

## 环境信息
- Flutter版本: 
- Dart版本: 
- 平台: [iOS/Android/Web/Windows]
- 设备: 
- 操作系统版本: 

## 其他信息
添加任何其他相关信息、截图或日志
```

---

## 💡 功能建议

### 提出新功能

1. 首先在 Discussions 中讨论想法
2. 得到初步认可后创建 Feature Request Issue
3. 详细描述功能需求和使用场景

### 功能请求模板

```markdown
## 功能描述
清楚描述您想要的功能

## 问题/需求
这个功能要解决什么问题？

## 解决方案
您理想中的解决方案是什么？

## 替代方案
您考虑过的其他解决方案

## 其他信息
添加任何其他相关信息或模拟图
```

---

## 🏷️ 发布流程

### 版本号规范

我们遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

- **主版本号**：不兼容的API变更
- **次版本号**：向下兼容的新功能
- **修订号**：向下兼容的Bug修复

示例：`1.2.3` → `1.2.4`（Bug修复）→ `1.3.0`（新功能）→ `2.0.0`（破坏性变更）

### 发布检查清单

- [ ] 所有测试通过
- [ ] 更新 CHANGELOG.md
- [ ] 更新版本号
- [ ] 创建发布标签
- [ ] 更新文档

---

## ❓ 常见问题

### Q: 我不会写代码，能贡献什么？
A: 您可以：
- 报告 Bug 和提出功能建议
- 改进文档和翻译
- 设计游戏资源（图标、音效等）
- 参与社区讨论

### Q: 我的 PR 被拒绝了怎么办？
A: 
- 仔细阅读维护者的反馈
- 根据建议修改代码
- 如有疑问，在 PR 中友好地询问
- 记住被拒绝不是针对个人

### Q: 如何跟上项目的最新进展？
A: 
- Watch 这个仓库获取通知
- 关注 Discussions 和 Issues
- 定期同步主分支的变更

---

## 🙋 获得帮助

如果您在贡献过程中遇到问题：

1. **查看文档**：首先查看本文档和项目 README
2. **搜索 Issues**：可能已经有人遇到过相同问题
3. **提问 Discussion**：在 GitHub Discussions 中提问
4. **联系维护者**：通过 Issue 或邮件联系

---

## 🙏 感谢

感谢所有为项目做出贡献的开发者！您的贡献让这个项目变得更好。

---

*最后更新：2024年* 