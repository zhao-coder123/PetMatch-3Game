import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet_tile.dart';
import '../models/pet_type.dart';

// 🎮 游戏提供者 - 修复版本，解决竞态条件和性能问题
class GameProvider extends ChangeNotifier {
  static const int gridSize = 8;
  
  // 核心数据层
  List<List<PetTile?>> _grid = [];
  int _score = 0;
  int _moves = 30;
  int _level = 1;
  int _targetScore = 1000;
  bool _isGameOver = false;
  bool _isAnimating = false;
  List<PetTile> _selectedTiles = [];
  
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

  GameProvider() {
    initializeGame();
  }

  // 🎯 游戏初始化 - 分层设计模式
  void initializeGame() {
    _score = 0;
    _moves = 30;
    _level = 1;
    _targetScore = 1000;
    _isGameOver = false;
    _isAnimating = false;
    _isProcessingMatch = false;
    _matchProcessingDepth = 0;
    _selectedTiles.clear();
    _generateGrid();
    notifyListeners();
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
    const maxIterations = 50; // 减少最大迭代次数，提升性能

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

  // 🎯 匹配检测算法 - 高效实现，添加边界检查
  bool _hasMatchAt(int row, int col) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return false;
    }
    
    final petType = _grid[row][col]?.petType;
    if (petType == null) return false;

    // 水平匹配检测 - 线性优化
    int horizontalCount = 1;
    
    // 向左检查
    for (int i = col - 1; i >= 0 && _grid[row][i]?.petType == petType; i--) {
      horizontalCount++;
    }
    
    // 向右检查
    for (int i = col + 1; i < gridSize && _grid[row][i]?.petType == petType; i++) {
      horizontalCount++;
    }

    if (horizontalCount >= 3) return true;

    // 垂直匹配检测 - 线性优化
    int verticalCount = 1;
    
    // 向上检查
    for (int i = row - 1; i >= 0 && _grid[i][col]?.petType == petType; i--) {
      verticalCount++;
    }
    
    // 向下检查
    for (int i = row + 1; i < gridSize && _grid[i][col]?.petType == petType; i++) {
      verticalCount++;
    }

    return verticalCount >= 3;
  }

  // 🎮 方块点击处理 - 状态管理层，添加锁机制
  void onTileTap(int row, int col) {
    if (_isAnimating || _isGameOver || _isProcessingMatch) return;

    final tile = _grid[row][col];
    if (tile == null) return;

    if (_selectedTiles.isEmpty) {
      // 选择第一个方块
      tile.isSelected = true;
      _selectedTiles.add(tile);
    } else if (_selectedTiles.length == 1) {
      final firstTile = _selectedTiles.first;
      
      if (firstTile == tile) {
        // 取消选择
        tile.isSelected = false;
        _selectedTiles.clear();
      } else if (_areAdjacent(firstTile, tile)) {
        // 交换相邻方块
        _selectedTiles.add(tile);
        _swapTiles(firstTile, tile);
      } else {
        // 选择新方块
        firstTile.isSelected = false;
        tile.isSelected = true;
        _selectedTiles.clear();
        _selectedTiles.add(tile);
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

  // 🔄 方块交换 - 修复异步竞态条件
  Future<void> _swapTiles(PetTile tile1, PetTile tile2) async {
    if (_isProcessingMatch) return;
    
    _isAnimating = true;
    _isProcessingMatch = true;
    notifyListeners();
    
    try {
      // 等待交换动画
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 执行交换
      final tempType = tile1.petType;
      _grid[tile1.row][tile1.col] = PetTile(
        row: tile1.row,
        col: tile1.col,
        petType: tile2.petType,
      );
      _grid[tile2.row][tile2.col] = PetTile(
        row: tile2.row,
        col: tile2.col,
        petType: tempType,
      );

      // 检查匹配
      final hasMatch = _checkForMatches();
      
      if (hasMatch) {
        _moves--;
        await _processMatches();
      } else {
        // 无匹配时恢复原状
        await Future.delayed(const Duration(milliseconds: 200));
        _grid[tile1.row][tile1.col] = tile1;
        _grid[tile2.row][tile2.col] = tile2;
      }

      // 清除选择状态
      _selectedTiles.clear();
      
      if (hasMatch) {
        _checkGameOver();
      }
    } finally {
      _isAnimating = false;
      _isProcessingMatch = false;
      notifyListeners();
    }
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

  // 💥 匹配处理 - 修复递归深度控制和异步处理
  Future<void> _processMatches() async {
    if (_matchProcessingDepth >= maxMatchDepth) {
      debugPrint('达到最大匹配处理深度，停止递归');
      return;
    }
    
    _matchProcessingDepth++;
    
    try {
      final matchedTiles = <PetTile>[];
      
      // 标记所有匹配的方块
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          if (_hasMatchAt(row, col)) {
            final tile = _grid[row][col];
            if (tile != null && !tile.isMatched) {
              tile.isMatched = true;
              matchedTiles.add(tile);
            }
          }
        }
      }

      if (matchedTiles.isNotEmpty) {
        // 计算分数 - 分层奖励系统
        final baseScore = matchedTiles.length * 100;
        final bonusScore = _calculateBonusScore(matchedTiles.length);
        final depthBonus = _matchProcessingDepth * 50; // 连锁奖励
        _score += baseScore + bonusScore + depthBonus;
        
        notifyListeners();
        
        // 分阶段处理消除动画
        await Future.delayed(const Duration(milliseconds: 400));
        _removeMatchedTiles();
        notifyListeners();
        
        await Future.delayed(const Duration(milliseconds: 200));
        _dropTiles();
        notifyListeners();
        
        await Future.delayed(const Duration(milliseconds: 300));
        _fillEmptySpaces();
        notifyListeners();
        
        // 检查连锁反应
        await Future.delayed(const Duration(milliseconds: 400));
        if (_checkForMatches()) {
          await _processMatches(); // 递归处理连锁，有深度控制
        }
      }
    } finally {
      _matchProcessingDepth--;
    }
  }

  // 🎯 奖励分数计算 - 参考缤果消消乐的奖励机制
  int _calculateBonusScore(int matchCount) {
    if (matchCount >= 6) return matchCount * 100; // 超级奖励
    if (matchCount >= 5) return matchCount * 50;  // 大奖励
    if (matchCount >= 4) return matchCount * 25;  // 中奖励
    return 0; // 基础分数
  }

  // 🗑️ 移除已匹配方块
  void _removeMatchedTiles() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_grid[row][col]?.isMatched == true) {
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
        if (_grid[row][col] != null) {
          column.add(_grid[row][col]);
        }
      }
      
      // 重新排列列 - 底部对齐
      for (int row = 0; row < gridSize; row++) {
        if (row < column.length) {
          final tile = column[row];
          _grid[gridSize - 1 - row][col] = tile?.copyWith(
            row: gridSize - 1 - row,
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
    Future.delayed(const Duration(milliseconds: 500), () {
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
        // 胜利进入下一关
        _nextLevel();
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
    _generateGrid();
  }

  // 🔄 重置游戏
  void resetGame() {
    initializeGame();
  }
} 