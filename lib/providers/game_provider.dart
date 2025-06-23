import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet_tile.dart';
import '../models/pet_type.dart';
import '../services/audio_manager.dart';

// 🎮 游戏提供者 - 修复版本，解决动画和连锁问题
class GameProvider extends ChangeNotifier {
  static const int gridSize = 8;
  
  // 音效管理器
  final AudioManager _audioManager = AudioManager();
  
  // 核心数据层
  List<List<PetTile?>> _grid = [];
  int _score = 0;
  int _moves = 30;
  int _level = 1;
  int _targetScore = 1000;
  bool _isGameOver = false;
  bool _isAnimating = false;
  List<PetTile> _selectedTiles = [];
  
  // 添加交换动画状态
  PetTile? _swappingTile1;
  PetTile? _swappingTile2;
  bool _isSwapAnimating = false;
  
  // 添加消除动画状态
  List<PetTile> _matchingTiles = [];
  bool _showMatchEffect = false;
  
  // 添加递归深度控制
  int _matchProcessingDepth = 0;
  static const int maxMatchDepth = 10;
  
  // 添加异步操作锁
  bool _isProcessingMatch = false;

  // Getters - 数据访问层
  List<List<PetTile?>> get grid => _grid;
  int get score => _score;
  int get moves => _moves;
  int get level => _level;
  int get targetScore => _targetScore;
  bool get isGameOver => _isGameOver;
  bool get isAnimating => _isAnimating;
  List<PetTile> get selectedTiles => _selectedTiles;
  
  // 音效管理器访问
  AudioManager get audioManager => _audioManager;
  
  // 新增动画状态getters
  PetTile? get swappingTile1 => _swappingTile1;
  PetTile? get swappingTile2 => _swappingTile2;
  bool get isSwapAnimating => _isSwapAnimating;
  List<PetTile> get matchingTiles => _matchingTiles;
  bool get showMatchEffect => _showMatchEffect;

  GameProvider() {
    initializeGame();
  }

  // 🎯 游戏初始化 - 分层设计模式
  void initializeGame() async {
    _score = 0;
    _moves = 30;
    _level = 1;
    _targetScore = 1000;
    _isGameOver = false;
    _isAnimating = false;
    _isProcessingMatch = false;
    _matchProcessingDepth = 0;
    _selectedTiles.clear();
    _clearAnimationStates();
    _generateGrid();
    
    // 初始化音效系统
    await _audioManager.initialize();
    
    // 开始播放背景音乐
    _audioManager.playBackgroundMusic();
    
    notifyListeners();
  }

  // 清除动画状态
  void _clearAnimationStates() {
    _swappingTile1 = null;
    _swappingTile2 = null;
    _isSwapAnimating = false;
    _matchingTiles.clear();
    _showMatchEffect = false;
  }

  // 🎲 网格生成算法 - 修复版本
  void _generateGrid() {
    final random = Random();
    _grid = List.generate(
      gridSize,
      (row) => List.generate(
        gridSize,
        (col) => PetTile(
          row: row,
          col: col,
          petType: PetType.values[random.nextInt(PetType.values.length)],
        ),
      ),
    );

    // 确保初始状态没有匹配 - 性能优化
    _removeInitialMatches();
  }

  // 🔧 初始匹配移除 - 循环优化算法
  void _removeInitialMatches() {
    bool hasMatches = true;
    final random = Random();
    int iterations = 0;
    const maxIterations = 50;

    while (hasMatches && iterations < maxIterations) {
      hasMatches = false;
      iterations++;
      
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          if (_hasMatchAt(row, col)) {
            hasMatches = true;
            // 生成不会造成匹配的新类型
            PetType newType;
            int attempts = 0;
            do {
              newType = PetType.values[random.nextInt(PetType.values.length)];
              attempts++;
            } while (_wouldCreateMatch(row, col, newType) && attempts < 10);
            
            _grid[row][col] = PetTile(
              row: row,
              col: col,
              petType: newType,
            );
          }
        }
      }
    }
  }

  // 检查放置特定类型是否会创建匹配
  bool _wouldCreateMatch(int row, int col, PetType petType) {
    // 临时设置类型并检查匹配
    final originalTile = _grid[row][col];
    _grid[row][col] = PetTile(row: row, col: col, petType: petType);
    final wouldMatch = _hasMatchAt(row, col);
    _grid[row][col] = originalTile; // 恢复原状
    return wouldMatch;
  }

  // 🎯 匹配检测算法 - 高效实现，修复连锁问题
  bool _hasMatchAt(int row, int col) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return false;
    }
    
    final tile = _grid[row][col];
    if (tile == null) return false;
    
    final petType = tile.petType;

    // 水平匹配检测 - 改进算法
    int horizontalCount = 1;
    int leftCount = 0;
    int rightCount = 0;
    
    // 向左检查
    for (int i = col - 1; i >= 0; i--) {
      final leftTile = _grid[row][i];
      if (leftTile?.petType == petType) {
        leftCount++;
      } else {
        break;
      }
    }
    
    // 向右检查
    for (int i = col + 1; i < gridSize; i++) {
      final rightTile = _grid[row][i];
      if (rightTile?.petType == petType) {
        rightCount++;
      } else {
        break;
      }
    }

    horizontalCount = leftCount + 1 + rightCount;
    if (horizontalCount >= 3) return true;

    // 垂直匹配检测 - 改进算法
    int verticalCount = 1;
    int upCount = 0;
    int downCount = 0;
    
    // 向上检查
    for (int i = row - 1; i >= 0; i--) {
      final upTile = _grid[i][col];
      if (upTile?.petType == petType) {
        upCount++;
      } else {
        break;
      }
    }
    
    // 向下检查
    for (int i = row + 1; i < gridSize; i++) {
      final downTile = _grid[i][col];
      if (downTile?.petType == petType) {
        downCount++;
      } else {
        break;
      }
    }

    verticalCount = upCount + 1 + downCount;
    return verticalCount >= 3;
  }

  // 🎮 方块点击处理 - 状态管理层，添加锁机制
  void onTileTap(int row, int col) {
    if (_isAnimating || _isGameOver || _isProcessingMatch || _isSwapAnimating) return;

    final tile = _grid[row][col];
    if (tile == null) return;

    // 🔊 播放点击音效
    _audioManager.playSoundEffect(SoundEffect.tap);

    if (_selectedTiles.isEmpty) {
      // 选择第一个方块
      tile.isSelected = true;
      _selectedTiles.add(tile);
      debugPrint('🎯 选择第一个方块: (${tile.row}, ${tile.col}) ${tile.petType.emoji}');
    } else if (_selectedTiles.length == 1) {
      final firstTile = _selectedTiles.first;
      
      if (firstTile == tile) {
        // 取消选择
        tile.isSelected = false;
        _selectedTiles.clear();
        debugPrint('❌ 取消选择');
      } else if (_areAdjacent(firstTile, tile)) {
        // 交换相邻方块
        debugPrint('🔄 开始交换: (${firstTile.row}, ${firstTile.col}) ↔ (${tile.row}, ${tile.col})');
        _selectedTiles.add(tile);
        // 🔊 播放交换音效
        _audioManager.playSoundEffect(SoundEffect.swap);
        _swapTiles(firstTile, tile);
      } else {
        // 选择新方块
        firstTile.isSelected = false;
        tile.isSelected = true;
        _selectedTiles.clear();
        _selectedTiles.add(tile);
        debugPrint('🎯 选择新方块: (${tile.row}, ${tile.col}) ${tile.petType.emoji}');
      }
    }

    notifyListeners();
  }

  // 📏 相邻检测 - 数学计算优化
  bool _areAdjacent(PetTile tile1, PetTile tile2) {
    final rowDiff = (tile1.row - tile2.row).abs();
    final colDiff = (tile1.col - tile2.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  // 🔄 方块交换 - 添加真正的交换动画
  Future<void> _swapTiles(PetTile tile1, PetTile tile2) async {
    if (_isProcessingMatch || _isSwapAnimating) return;
    
    _isAnimating = true;
    _isSwapAnimating = true;
    _isProcessingMatch = true;
    
    // 设置交换动画状态
    _swappingTile1 = tile1;
    _swappingTile2 = tile2;
    
    debugPrint('🎬 开始交换动画');
    notifyListeners();
    
    try {
      // 等待交换动画完成
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 执行实际交换
      _performSwap(tile1, tile2);
      
      // 等待交换完成的视觉效果
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 检查是否有匹配
      final hasMatch = _checkForMatches();
      debugPrint('🔍 匹配检查结果: $hasMatch');
      
      if (hasMatch) {
        _moves--;
        debugPrint('✅ 有效交换，剩余步数: $_moves');
        await _processMatches();
      } else {
        // 无匹配时恢复原状
        debugPrint('❌ 无匹配，恢复原状');
        await Future.delayed(const Duration(milliseconds: 200));
        _performSwap(tile2, tile1); // 交换回来
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // 清除选择和交换状态
      _clearSelectionAndSwapStates();
      
      if (hasMatch) {
        _checkGameOver();
      }
    } catch (e) {
      debugPrint('🚨 交换过程出错: $e');
      _clearSelectionAndSwapStates();
    } finally {
      _isAnimating = false;
      _isSwapAnimating = false;
      _isProcessingMatch = false;
      _swappingTile1 = null;
      _swappingTile2 = null;
      notifyListeners();
    }
  }

  // 执行实际的方块交换
  void _performSwap(PetTile tile1, PetTile tile2) {
    final tempType = tile1.petType;
    _grid[tile1.row][tile1.col] = tile1.copyWith(petType: tile2.petType);
    _grid[tile2.row][tile2.col] = tile2.copyWith(petType: tempType);
  }

  // 清除选择和交换状态
  void _clearSelectionAndSwapStates() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final tile = _grid[row][col];
        if (tile != null && tile.isSelected) {
          _grid[row][col] = tile.copyWith(isSelected: false);
        }
      }
    }
    _selectedTiles.clear();
  }

  // 🔍 全局匹配检查 - 优化遍历算法
  bool _checkForMatches() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_hasMatchAt(row, col)) {
          return true;
        }
      }
    }
    return false;
  }

  // 💥 匹配处理 - 修复递归深度控制和特效
  Future<void> _processMatches() async {
    if (_matchProcessingDepth >= maxMatchDepth) {
      debugPrint('⚠️ 达到最大匹配处理深度 ($maxMatchDepth)，停止递归');
      return;
    }
    
    _matchProcessingDepth++;
    debugPrint('🔄 处理匹配，深度: $_matchProcessingDepth');
    
    try {
      final matchedTiles = _findAllMatches();
      
      if (matchedTiles.isNotEmpty) {
        debugPrint('🎯 找到 ${matchedTiles.length} 个匹配的方块');
        
        // 🔊 播放匹配音效
        if (matchedTiles.length >= 5) {
          _audioManager.playSoundEffect(SoundEffect.combo);
        } else {
          _audioManager.playSoundEffect(SoundEffect.match);
        }
        
        // 设置匹配状态和特效
        _matchingTiles = matchedTiles;
        _showMatchEffect = true;
        
        // 标记方块为匹配状态
        for (final tile in matchedTiles) {
          final gridTile = _grid[tile.row][tile.col];
          if (gridTile != null) {
            _grid[tile.row][tile.col] = gridTile.copyWith(isMatched: true);
          }
        }
        
        // 计算分数 - 分层奖励系统
        final baseScore = matchedTiles.length * 100;
        final bonusScore = _calculateBonusScore(matchedTiles.length);
        final depthBonus = _matchProcessingDepth * 50; // 连锁奖励
        final totalScore = baseScore + bonusScore + depthBonus;
        _score += totalScore;
        
        debugPrint('💰 得分: 基础($baseScore) + 奖励($bonusScore) + 连锁($depthBonus) = $totalScore');
        
        notifyListeners();
        
        // 显示匹配特效
        await Future.delayed(const Duration(milliseconds: 600));
        
        // 移除匹配的方块
        _removeMatchedTiles();
        _showMatchEffect = false;
        notifyListeners();
        
        // 下落动画
        await Future.delayed(const Duration(milliseconds: 300));
        // 🔊 播放下落音效
        _audioManager.playSoundEffect(SoundEffect.drop);
        _dropTiles();
        notifyListeners();
        
        // 填充新方块
        await Future.delayed(const Duration(milliseconds: 400));
        _fillEmptySpaces();
        notifyListeners();
        
        // 检查连锁反应
        await Future.delayed(const Duration(milliseconds: 500));
        if (_checkForMatches()) {
          debugPrint('🔗 检测到连锁反应，继续处理...');
          await _processMatches(); // 递归处理连锁
        } else {
          debugPrint('✅ 匹配处理完成，无更多连锁');
        }
      }
    } catch (e) {
      debugPrint('🚨 匹配处理出错: $e');
    } finally {
      _matchProcessingDepth--;
      if (_matchProcessingDepth == 0) {
        _matchingTiles.clear();
        _showMatchEffect = false;
      }
    }
  }

  // 🔍 查找所有匹配的方块 - 改进算法
  List<PetTile> _findAllMatches() {
    final Set<PetTile> matchedTiles = {};
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final tile = _grid[row][col];
        if (tile != null && _hasMatchAt(row, col)) {
          // 添加水平匹配的方块
          _addHorizontalMatches(row, col, tile.petType, matchedTiles);
          // 添加垂直匹配的方块
          _addVerticalMatches(row, col, tile.petType, matchedTiles);
        }
      }
    }
    
    return matchedTiles.toList();
  }

  // 添加水平匹配的方块
  void _addHorizontalMatches(int row, int col, PetType petType, Set<PetTile> matchedTiles) {
    final List<PetTile> horizontalGroup = [];
    
    // 向左收集
    for (int i = col; i >= 0; i--) {
      final tile = _grid[row][i];
      if (tile?.petType == petType) {
        horizontalGroup.add(tile!);
      } else {
        break;
      }
    }
    
    // 向右收集
    for (int i = col + 1; i < gridSize; i++) {
      final tile = _grid[row][i];
      if (tile?.petType == petType) {
        horizontalGroup.add(tile!);
      } else {
        break;
      }
    }
    
    if (horizontalGroup.length >= 3) {
      matchedTiles.addAll(horizontalGroup);
    }
  }

  // 添加垂直匹配的方块
  void _addVerticalMatches(int row, int col, PetType petType, Set<PetTile> matchedTiles) {
    final List<PetTile> verticalGroup = [];
    
    // 向上收集
    for (int i = row; i >= 0; i--) {
      final tile = _grid[i][col];
      if (tile?.petType == petType) {
        verticalGroup.add(tile!);
      } else {
        break;
      }
    }
    
    // 向下收集
    for (int i = row + 1; i < gridSize; i++) {
      final tile = _grid[i][col];
      if (tile?.petType == petType) {
        verticalGroup.add(tile!);
      } else {
        break;
      }
    }
    
    if (verticalGroup.length >= 3) {
      matchedTiles.addAll(verticalGroup);
    }
  }

  // 🎯 奖励分数计算 - 参考缤果消消乐的奖励机制
  int _calculateBonusScore(int matchCount) {
    if (matchCount >= 8) return matchCount * 150; // 超超级奖励
    if (matchCount >= 6) return matchCount * 100; // 超级奖励
    if (matchCount >= 5) return matchCount * 50;  // 大奖励
    if (matchCount >= 4) return matchCount * 25;  // 中奖励
    return 0; // 基础分数
  }

  // 🗑️ 移除已匹配方块
  void _removeMatchedTiles() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final tile = _grid[row][col];
        if (tile?.isMatched == true) {
          _grid[row][col] = null;
        }
      }
    }
  }

  // ⬇️ 方块下落算法 - 重力模拟
  void _dropTiles() {
    for (int col = 0; col < gridSize; col++) {
      final column = <PetTile?>[];
      
      // 收集非空方块
      for (int row = gridSize - 1; row >= 0; row--) {
        final tile = _grid[row][col];
        if (tile != null) {
          column.add(tile);
        }
      }
      
      // 重新排列列 - 底部对齐
      for (int row = 0; row < gridSize; row++) {
        if (row < column.length) {
          final tile = column[row]!;
          _grid[gridSize - 1 - row][col] = tile.copyWith(
            row: gridSize - 1 - row,
            isFalling: true,
          );
        } else {
          _grid[gridSize - 1 - row][col] = null;
        }
      }
    }
  }

  // 🆕 填充空白空间 - 随机生成新方块
  void _fillEmptySpaces() {
    final random = Random();
    
    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row < gridSize; row++) {
        if (_grid[row][col] == null) {
          _grid[row][col] = PetTile(
            row: row,
            col: col,
            petType: PetType.values[random.nextInt(PetType.values.length)],
            isFalling: true,
          );
        }
      }
    }
    
    // 延迟重置下落状态 - 动画效果
    Future.delayed(const Duration(milliseconds: 800), () {
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          final tile = _grid[row][col];
          if (tile != null && tile.isFalling) {
            _grid[row][col] = tile.copyWith(isFalling: false);
          }
        }
      }
      notifyListeners();
    });
  }

  // 🏁 游戏结束检查
  void _checkGameOver() {
    if (_moves <= 0) {
      _isGameOver = true;
      if (_score >= _targetScore) {
        // 🔊 播放胜利音效
        _audioManager.playSoundEffect(SoundEffect.victory);
        // 胜利进入下一关
        _nextLevel();
      } else {
        // 🔊 播放游戏结束音效
        _audioManager.playSoundEffect(SoundEffect.gameOver);
      }
    }
  }

  // ⬆️ 下一关设置
  void _nextLevel() {
    _level++;
    _moves = 30 + (_level * 2); // 每关增加2步
    _targetScore = _level * 1000 + (_level * 200); // 递增目标分数
    _isGameOver = false;
    _matchProcessingDepth = 0;
    
    // 🔊 播放升级音效
    _audioManager.playSoundEffect(SoundEffect.levelUp);
    
    _generateGrid();
  }

  // 🔄 重置游戏
  void resetGame() {
    initializeGame();
  }

  // 🎮 公开的下一关方法
  void nextLevel() {
    _nextLevel();
    notifyListeners();
  }

  // 🎯 获取当前关卡信息
  String get levelInfo => '第 $_level 关';
  
  // 🎯 获取进度信息
  String get progressInfo => '${(_score / _targetScore * 100).toInt()}%';
  
  // 🎮 获取剩余目标分数
  int get remainingScore => (_targetScore - _score).clamp(0, _targetScore);
  
  // 🏆 检查是否可以进入下一关
  bool get canNextLevel => _score >= _targetScore;
} 