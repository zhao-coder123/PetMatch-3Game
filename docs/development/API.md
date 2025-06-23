# 📚 API 文档

本文档描述了宠物消消乐·炫彩版项目的核心API接口和使用方法。

## 📋 目录

- [GameProvider API](#gameprovider-api)
- [Models API](#models-api)
- [Widgets API](#widgets-api)
- [Utils API](#utils-api)
- [Services API](#services-api)
- [使用示例](#使用示例)

---

## 🎮 GameProvider API

`GameProvider` 是游戏状态管理的核心类，基于 `ChangeNotifier` 实现。

### 属性

#### 只读属性

| 属性名 | 类型 | 描述 |
|--------|------|------|
| `grid` | `List<List<PetTile?>>` | 游戏网格，8x8的二维数组 |
| `score` | `int` | 当前游戏分数 |
| `moves` | `int` | 剩余移动步数 |
| `level` | `int` | 当前关卡等级 |
| `targetScore` | `int` | 目标分数 |
| `isGameOver` | `bool` | 游戏是否结束 |
| `isAnimating` | `bool` | 是否正在播放动画 |
| `selectedTiles` | `List<PetTile>` | 当前选中的方块列表 |

#### 常量

| 常量名 | 值 | 描述 |
|--------|---|------|
| `gridSize` | `8` | 游戏网格大小 |

### 方法

#### 游戏控制方法

##### `void initializeGame()`

初始化游戏状态，重置所有数据。

```dart
gameProvider.initializeGame();
```

##### `void resetGame()`

重置当前游戏，等同于 `initializeGame()`。

```dart
gameProvider.resetGame();
```

##### `void onTileTap(int row, int col)`

处理方块点击事件。

**参数:**
- `row` (int): 方块行索引 (0-7)
- `col` (int): 方块列索引 (0-7)

```dart
gameProvider.onTileTap(2, 3);
```

**说明:**
- 如果游戏正在动画或已结束，方法将直接返回
- 第一次点击选中方块
- 第二次点击尝试交换相邻方块

#### 内部核心方法

##### `bool _hasMatchAt(int row, int col)`

检测指定位置是否存在匹配。

**参数:**
- `row` (int): 检测行索引
- `col` (int): 检测列索引

**返回值:**
- `bool`: 是否存在匹配

##### `Future<void> _processMatches()`

异步处理匹配消除逻辑。

**功能:**
- 查找所有匹配
- 播放消除动画
- 计算分数
- 处理方块下落
- 填充新方块
- 检查连锁反应

##### `void _dropTiles()`

处理方块下落重力效果。

##### `void _fillEmptySpaces()`

用新的随机方块填充空白位置。

### 事件监听

GameProvider 基于 `ChangeNotifier`，可以监听状态变化：

```dart
// 使用 Consumer
Consumer<GameProvider>(
  builder: (context, gameProvider, child) {
    return Text('分数: ${gameProvider.score}');
  },
)

// 使用 Provider.of
final gameProvider = Provider.of<GameProvider>(context);

// 使用 context.watch
final gameProvider = context.watch<GameProvider>();
```

---

## 📦 Models API

### PetTile

宠物方块数据模型。

#### 构造函数

```dart
PetTile({
  required int row,
  required int col,
  required PetType petType,
  bool isSelected = false,
  bool isMatched = false,
  bool isHighlighted = false,
  bool isFalling = false,
})
```

#### 属性

| 属性名 | 类型 | 描述 |
|--------|------|------|
| `row` | `int` | 行位置 (只读) |
| `col` | `int` | 列位置 (只读) |
| `petType` | `PetType` | 宠物类型 (只读) |
| `isSelected` | `bool` | 是否被选中 |
| `isMatched` | `bool` | 是否已匹配 |
| `isHighlighted` | `bool` | 是否高亮显示 |
| `isFalling` | `bool` | 是否正在下落 |

#### 方法

##### `PetTile copyWith({...})`

创建副本并修改指定属性。

```dart
final newTile = tile.copyWith(isSelected: true);
```

##### `PetTile resetStates()`

重置所有状态为默认值。

```dart
final cleanTile = tile.resetStates();
```

##### `bool get isAnimated`

检查是否处于动画状态。

```dart
if (tile.isAnimated) {
  // 处理动画状态
}
```

### PetType

宠物类型枚举。

#### 枚举值

```dart
enum PetType {
  cat,      // 🐱
  dog,      // 🐶  
  rabbit,   // 🐰
  panda,    // 🐼
  fox,      // 🦊
  unicorn,  // 🦄
}
```

#### 扩展属性

| 属性名 | 类型 | 描述 |
|--------|------|------|
| `name` | `String` | 宠物中文名称 |
| `emoji` | `String` | 宠物表情符号 |
| `color` | `Color` | 宠物主题色 |
| `shadowColor` | `Color` | 阴影颜色 |

#### 使用示例

```dart
final petType = PetType.cat;
print(petType.name);        // "小猫咪"
print(petType.emoji);       // "🐱"
print(petType.color);       // Color(0xFFFF6B9D)
```

---

## 🎨 Widgets API

### AnimatedPetTileWidget

高级动画宠物方块组件。

#### 构造函数

```dart
const AnimatedPetTileWidget({
  Key? key,
  required PetTile tile,
  required int row,
  required int col,
  required double size,
  VoidCallback? onTap,
  bool isAnimating = false,
})
```

#### 参数说明

| 参数名 | 类型 | 必需 | 描述 |
|--------|------|-----|------|
| `tile` | `PetTile` | ✅ | 宠物方块数据 |
| `row` | `int` | ✅ | 方块行位置 |
| `col` | `int` | ✅ | 方块列位置 |
| `size` | `double` | ✅ | 方块显示尺寸 |
| `onTap` | `VoidCallback?` | ❌ | 点击回调 |
| `isAnimating` | `bool` | ❌ | 是否正在动画 |

#### 动画特性

- **选中动画**: 缩放和发光效果
- **匹配动画**: 旋转和淡出效果
- **下落动画**: 滑入和弹跳效果

#### 使用示例

```dart
AnimatedPetTileWidget(
  tile: tile,
  row: 2,
  col: 3,
  size: 64.0,
  onTap: () => gameProvider.onTileTap(2, 3),
  isAnimating: gameProvider.isAnimating,
)
```

### GameGrid

游戏网格容器组件。

#### 构造函数

```dart
const GameGrid({Key? key})
```

#### 特性

- 响应式布局适配
- 自动计算方块尺寸
- 渐变背景效果
- 圆角和阴影装饰

#### 使用示例

```dart
const GameGrid() // 自动从 Provider 获取数据
```

### GameInfoPanel

游戏信息显示面板。

#### 构造函数

```dart
const GameInfoPanel({Key? key})
```

#### 显示内容

- 当前分数
- 剩余步数
- 当前等级
- 目标进度

#### 使用示例

```dart
const GameInfoPanel()
```

### GameOverDialog

游戏结束对话框。

#### 构造函数

```dart
const GameOverDialog({
  Key? key,
  required bool isWin,
  required int score,
  required int level,
  required VoidCallback onRestart,
  required VoidCallback onNextLevel,
})
```

#### 参数说明

| 参数名 | 类型 | 描述 |
|--------|------|------|
| `isWin` | `bool` | 是否胜利 |
| `score` | `int` | 最终分数 |
| `level` | `int` | 当前等级 |
| `onRestart` | `VoidCallback` | 重新开始回调 |
| `onNextLevel` | `VoidCallback` | 下一关回调 |

#### 使用示例

```dart
GameOverDialog(
  isWin: gameProvider.score >= gameProvider.targetScore,
  score: gameProvider.score,
  level: gameProvider.level,
  onRestart: () => gameProvider.resetGame(),
  onNextLevel: () => gameProvider.resetGame(),
)
```

---

## 🛠️ Utils API

### ResponsiveHelper

响应式布局辅助工具。

#### 静态方法

##### `bool isTablet(BuildContext context)`

判断是否为平板设备。

```dart
if (ResponsiveHelper.isTablet(context)) {
  // 平板布局
}
```

##### `bool isLandscape(BuildContext context)`

判断是否为横屏模式。

```dart
if (ResponsiveHelper.isLandscape(context)) {
  // 横屏布局
}
```

##### `double getResponsiveWidth(BuildContext context, double factor)`

获取响应式宽度。

```dart
final width = ResponsiveHelper.getResponsiveWidth(context, 0.8);
```

### AnimationTimings

动画时长常量。

#### 常量定义

```dart
class AnimationTimings {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration tileSwap = Duration(milliseconds: 400);
  static const Duration tileMatch = Duration(milliseconds: 500);
  static const Duration tileFall = Duration(milliseconds: 600);
}
```

### AnimationCurves

动画缓动曲线。

#### 曲线定义

```dart
class AnimationCurves {
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve gameSwap = Cubic(0.25, 0.46, 0.45, 0.94);
  static const Curve gameMatch = Cubic(0.6, 0.04, 0.98, 0.335);
}
```

### Logger

调试日志工具。

#### 方法

##### `void debug(String message)`
##### `void info(String message)`
##### `void warning(String message)`
##### `void error(String message)`

```dart
Logger.debug('调试信息');
Logger.info('一般信息');
Logger.warning('警告信息');
Logger.error('错误信息');
```

---

## 🔧 Services API

### AudioService

音频服务接口（预留）。

```dart
abstract class AudioService {
  Future<void> playSound(String soundPath);
  Future<void> playBackgroundMusic(String musicPath);
  Future<void> stopMusic();
  void setVolume(double volume);
}
```

### StorageService

本地存储服务接口（预留）。

```dart
abstract class StorageService {
  Future<void> saveScore(int score);
  Future<int> getHighScore();
  Future<void> saveLevel(int level);
  Future<int> getCurrentLevel();
}
```

---

## 📖 使用示例

### 基本游戏界面搭建

```dart
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🐾 宠物消消乐'),
            ),
            body: Column(
              children: [
                // 信息面板
                const GameInfoPanel(),
                
                // 游戏网格
                const Expanded(
                  child: GameGrid(),
                ),
                
                // 控制按钮
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: gameProvider.resetGame,
                    child: const Text('重新开始'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### 自定义方块组件

```dart
class CustomPetTile extends StatelessWidget {
  final PetTile tile;
  final VoidCallback? onTap;

  const CustomPetTile({
    super.key,
    required this.tile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AnimationTimings.medium,
        curve: AnimationCurves.easeInOut,
        decoration: BoxDecoration(
          color: tile.petType.color,
          borderRadius: BorderRadius.circular(12),
          border: tile.isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: tile.petType.shadowColor,
              blurRadius: tile.isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            tile.petType.emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
```

### 状态监听和响应

```dart
class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return AnimatedSwitcher(
          duration: AnimationTimings.medium,
          child: Text(
            '分数: ${gameProvider.score}',
            key: ValueKey(gameProvider.score),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
      },
    );
  }
}
```

### 游戏结束处理

```dart
class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // 监听游戏结束状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (gameProvider.isGameOver) {
            _showGameOverDialog(gameProvider);
          }
        });

        return const GameScreen();
      },
    );
  }

  void _showGameOverDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        isWin: gameProvider.score >= gameProvider.targetScore,
        score: gameProvider.score,
        level: gameProvider.level,
        onRestart: () {
          Navigator.of(context).pop();
          gameProvider.resetGame();
        },
        onNextLevel: () {
          Navigator.of(context).pop();
          gameProvider.resetGame();
        },
      ),
    );
  }
}
```

---

## 🔍 API 最佳实践

### 1. 状态管理

```dart
// ✅ 好的做法：使用 Consumer 精确监听
Consumer<GameProvider>(
  builder: (context, gameProvider, child) {
    return Text('${gameProvider.score}');
  },
)

// ❌ 避免：监听整个 Provider
context.watch<GameProvider>() // 会导致不必要的重建
```

### 2. 异步操作

```dart
// ✅ 好的做法：检查组件状态
Future<void> performGameAction() async {
  await gameProvider.processMatches();
  if (mounted) {
    // 安全的状态更新
  }
}

// ❌ 避免：不检查组件状态
Future<void> badGameAction() async {
  await gameProvider.processMatches();
  setState(() {}); // 可能在组件销毁后执行
}
```

### 3. 性能优化

```dart
// ✅ 好的做法：使用 const 构造函数
const GameTile(
  tile: tile,
  onTap: onTap,
)

// ✅ 好的做法：提供稳定的 key
ListView.builder(
  itemBuilder: (context, index) {
    return GameTile(
      key: ValueKey('${tile.row}-${tile.col}'),
      tile: tile,
    );
  },
)
```

---

*最后更新：2024年* 