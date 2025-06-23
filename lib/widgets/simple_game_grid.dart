import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'enhanced_pet_tile_widget.dart';
import 'dart:math' as math;

class SimpleGameGrid extends StatelessWidget {
  const SimpleGameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 🛡️ 极端安全的约束处理
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            
            // 使用屏幕尺寸和约束的最小值
            final safeWidth = math.min(
              constraints.maxWidth > 0 ? constraints.maxWidth : screenWidth,
              screenWidth
            ).clamp(200.0, 800.0);
            
            final safeHeight = math.min(
              constraints.maxHeight > 0 ? constraints.maxHeight : screenHeight,
              screenHeight
            ).clamp(200.0, 800.0);
            
            // 🎯 智能尺寸计算 - 确保方形网格且有足够边距
            final availableSize = math.min(safeWidth, safeHeight);
            
            // 🔧 分层边距系统
            final outerPadding = availableSize * 0.05; // 外边距占5%
            final innerPadding = availableSize * 0.02; // 内边距占2%
            final tilePadding = availableSize * 0.005; // 方块间距占0.5%
            
            // 计算最终尺寸
            final containerSize = availableSize - outerPadding * 2;
            final gridContentSize = containerSize - innerPadding * 2;
            final totalTilePadding = tilePadding * (GameProvider.gridSize - 1) * 2;
            final tileSize = ((gridContentSize - totalTilePadding) / GameProvider.gridSize)
                .clamp(15.0, 60.0); // 方块大小限制在15-60px之间
            
            debugPrint('🎮 网格尺寸计算: 容器=${containerSize.toInt()}, 方块=${tileSize.toInt()}');
            
            return Center(
              child: Container(
                width: containerSize,
                height: containerSize,
                constraints: BoxConstraints(
                  minWidth: 200,
                  minHeight: 200,
                  maxWidth: safeWidth - outerPadding * 2,
                  maxHeight: safeHeight - outerPadding * 2,
                ),
                padding: EdgeInsets.all(innerPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.pink.shade50.withOpacity(0.9),
                      Colors.purple.shade50.withOpacity(0.95),
                      Colors.blue.shade50.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(containerSize * 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: containerSize * 0.02,
                      offset: Offset(0, containerSize * 0.008),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: containerSize * 0.015,
                      offset: Offset(0, -containerSize * 0.005),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: math.max(1.0, containerSize * 0.003),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(containerSize * 0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: math.max(0.5, containerSize * 0.002),
                    ),
                  ),
                  child: _buildGameGrid(gameProvider, tileSize, tilePadding),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🎮 构建游戏网格
  Widget _buildGameGrid(GameProvider gameProvider, double tileSize, double tilePadding) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        GameProvider.gridSize,
        (row) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            GameProvider.gridSize,
            (col) => Container(
              width: tileSize,
              height: tileSize,
              margin: EdgeInsets.all(tilePadding),
              child: gameProvider.grid[row][col] != null
                  ? EnhancedPetTileWidget(
                      tile: gameProvider.grid[row][col],
                      row: row,
                      col: col,
                      size: tileSize - tilePadding * 2,
                      onTap: () => gameProvider.onTileTap(row, col),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(tileSize * 0.15),
                        border: Border.all(
                          color: Colors.grey.shade300.withOpacity(0.7),
                          width: math.max(0.5, tileSize * 0.02),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: tileSize * 0.1,
                            offset: Offset(0, tileSize * 0.03),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
} 