import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'pet_tile_widget.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 🎯 响应式布局计算 - 参考缤果消消乐的适配策略
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            
            // 计算最佳网格尺寸
            const padding = 16.0;
            final maxSize = availableWidth - padding * 2;
            final maxHeight = availableHeight - padding * 2;
            
            // 选择更小的尺寸确保方形网格
            final gridSize = maxSize < maxHeight ? maxSize : maxHeight;
            
            // 计算每个方块的大小
            final tileSize = (gridSize - 16) / GameProvider.gridSize;
            
            return Center(
              child: Container(
                width: gridSize,
                height: gridSize,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // 🌈 多层渐变背景设计
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.pink.shade50.withValues(alpha: 0.9),
                      Colors.purple.shade50.withValues(alpha: 0.8),
                      Colors.blue.shade50.withValues(alpha: 0.9),
                      Colors.cyan.shade50.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    // 外阴影
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    // 内发光效果
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: _buildGameGrid(gameProvider, tileSize),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGameGrid(GameProvider gameProvider, double tileSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        GameProvider.gridSize,
        (row) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            GameProvider.gridSize,
            (col) => _buildTileContainer(
              gameProvider,
              row,
              col,
              tileSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTileContainer(
    GameProvider gameProvider,
    int row,
    int col,
    double tileSize,
  ) {
    final tile = gameProvider.grid[row][col];
    
    return Container(
      width: tileSize,
      height: tileSize,
      margin: const EdgeInsets.all(1),
      child: tile != null
          ? AnimatedPetTileWidget(
              tile: tile,
              row: row,
              col: col,
              size: tileSize - 2,
              onTap: () => gameProvider.onTileTap(row, col),
              isAnimating: gameProvider.isAnimating,
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
    );
  }
}

// 🎨 增强版宠物方块组件 - 参考缤果消消乐的视觉设计
class EnhancedPetTileWidget extends StatefulWidget {
  final tile;
  final double size;
  final VoidCallback? onTap;
  final bool isAnimating;

  const EnhancedPetTileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.onTap,
    this.isAnimating = false,
  });

  @override
  State<EnhancedPetTileWidget> createState() => _EnhancedPetTileWidgetState();
}

class _EnhancedPetTileWidgetState extends State<EnhancedPetTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(EnhancedPetTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 选中状态变化时的动画
    if (widget.tile?.isSelected == true && oldWidget.tile?.isSelected != true) {
      _controller.forward().then((_) => _controller.reverse());
    }
    
    // 匹配状态变化时的动画
    if (widget.tile?.isMatched == true && oldWidget.tile?.isMatched != true) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.tile?.isSelected == true 
            ? _bounceAnimation.value 
            : (widget.tile?.isMatched == true ? _scaleAnimation.value : 1.0);
            
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                // 🎨 立体渐变效果
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getTileColors(),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _getTileShadows(),
                border: _getTileBorder(),
              ),
              child: Stack(
                children: [
                  // 高光效果
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  // 宠物表情
                  Center(
                    child: Text(
                      widget.tile.petType.emoji,
                      style: TextStyle(
                        fontSize: widget.size * 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 选中状态装饰
                  if (widget.tile?.isSelected == true) ..._buildSelectedDecorations(),
                  
                  // 高亮状态装饰
                  if (widget.tile?.isHighlighted == true) ..._buildHighlightDecorations(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getTileColors() {
    final baseColor = widget.tile?.petType.color ?? Colors.grey;
    
    if (widget.tile?.isSelected == true) {
      return [
        baseColor.withOpacity(1.0),
        baseColor.withOpacity(0.8),
        baseColor.withOpacity(0.9),
      ];
    } else if (widget.tile?.isMatched == true) {
      return [
        baseColor.withOpacity(0.3),
        baseColor.withOpacity(0.1),
        baseColor.withOpacity(0.2),
      ];
    } else {
      return [
        baseColor.withOpacity(0.9),
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.8),
      ];
    }
  }

  List<BoxShadow> _getTileShadows() {
    final baseColor = widget.tile?.petType.color ?? Colors.grey;
    
    if (widget.tile?.isSelected == true) {
      return [
        BoxShadow(
          color: baseColor.withOpacity(0.6),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: baseColor.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
  }

  Border? _getTileBorder() {
    if (widget.tile?.isSelected == true) {
      return Border.all(
        color: Colors.white,
        width: 3,
      );
    } else {
      return Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1,
      );
    }
  }

  List<Widget> _buildSelectedDecorations() {
    return [
      // 左上角爱心
      const Positioned(
        top: 4,
        left: 4,
        child: Text('💖', style: TextStyle(fontSize: 12)),
      ),
      // 右下角爱心
      const Positioned(
        bottom: 4,
        right: 4,
        child: Text('💖', style: TextStyle(fontSize: 12)),
      ),
      // 中心发光效果
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: Alignment.center,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildHighlightDecorations() {
    return [
      // 右上角星星
      const Positioned(
        top: 4,
        right: 4,
        child: Text('✨', style: TextStyle(fontSize: 12)),
      ),
    ];
  }
} 