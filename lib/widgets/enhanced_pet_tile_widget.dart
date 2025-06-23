import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/pet_tile.dart';
import '../models/pet_type.dart';
import '../providers/game_provider.dart';

class EnhancedPetTileWidget extends StatefulWidget {
  final PetTile? tile;
  final int row;
  final int col;
  final double size;
  final VoidCallback? onTap;

  const EnhancedPetTileWidget({
    super.key,
    required this.tile,
    required this.row,
    required this.col,
    required this.size,
    this.onTap,
  });

  @override
  State<EnhancedPetTileWidget> createState() => _EnhancedPetTileWidgetState();
}

class _EnhancedPetTileWidgetState extends State<EnhancedPetTileWidget> 
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _swapController;
  late AnimationController _matchController;
  late AnimationController _shimmerController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _swapAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isSwapping = false;
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    
    // 弹跳动画控制器
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 交换动画控制器
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // 匹配消除动画控制器
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 光泽动画控制器 - 优化性能
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 延长周期减少更新频率
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.easeInBack,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.easeInOut,
    ));
    
    _swapAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.elasticOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // 光泽动画按需启动，提升性能
  }

  @override
  void didUpdateWidget(EnhancedPetTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测选中状态变化
    final isSelected = widget.tile?.isSelected == true;
    if (isSelected && !_wasSelected) {
      _playBounceAnimation();
      // 只在选中时启动光泽动画
      _shimmerController.repeat();
    } else if (!isSelected && _wasSelected) {
      // 取消选中时停止光泽动画
      _shimmerController.stop();
      _shimmerController.reset();
    }
    _wasSelected = isSelected;
    
    // 检测匹配消除动画
    if (widget.tile?.isMatched == true && oldWidget.tile?.isMatched != true) {
      _playMatchAnimation();
    }
    
    // 检测交换动画
    _checkSwapAnimation();
  }

  void _checkSwapAnimation() {
    final gameProvider = context.read<GameProvider>();
    
    if (gameProvider.isSwapAnimating && !_isSwapping) {
      final swappingTile1 = gameProvider.swappingTile1;
      final swappingTile2 = gameProvider.swappingTile2;
      
      if (swappingTile1 != null && swappingTile2 != null) {
        final currentTile = widget.tile;
        if (currentTile != null) {
          if (currentTile.row == swappingTile1.row && currentTile.col == swappingTile1.col) {
            _playSwapAnimation(
              swappingTile2.row - swappingTile1.row, 
              swappingTile2.col - swappingTile1.col
            );
          } else if (currentTile.row == swappingTile2.row && currentTile.col == swappingTile2.col) {
            _playSwapAnimation(
              swappingTile1.row - swappingTile2.row, 
              swappingTile1.col - swappingTile2.col
            );
          }
        }
      }
    } else if (!gameProvider.isSwapAnimating && _isSwapping) {
      _isSwapping = false;
      _swapController.reset();
    }
  }

  void _playSwapAnimation(int rowDiff, int colDiff) {
    if (_isSwapping) return;
    
    _isSwapping = true;
    
    final offset = Offset(
      colDiff * (widget.size + 4),
      rowDiff * (widget.size + 4),
    );
    
    _swapAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: offset,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.elasticOut,
    ));
    
    _swapController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _swapController.reverse();
      });
    });
  }

  void _playBounceAnimation() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
  }

  void _playMatchAnimation() {
    _matchController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _swapController.dispose();
    _matchController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceAnimation, 
        _scaleAnimation, 
        _rotationAnimation, 
        _swapAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        // 计算综合变换
        double scale = 1.0;
        if (widget.tile!.isMatched) {
          scale = _scaleAnimation.value;
        } else if (widget.tile!.isSelected) {
          scale = _bounceAnimation.value;
        }
        
        final swapOffset = _isSwapping ? _swapAnimation.value : Offset.zero;
        
        return Transform.translate(
          offset: swapOffset,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: widget.tile!.isMatched ? _rotationAnimation.value : 0,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tile!.petType.shadowColor,
                        blurRadius: widget.tile!.isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                        spreadRadius: widget.tile!.isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 主体容器
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.tile!.petType.color.withOpacity(0.9),
                              widget.tile!.petType.color,
                              widget.tile!.petType.color.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: widget.tile!.isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                      ),
                      
                      // 光泽效果
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
                      
                      // 选中时的光泽动画
                      if (widget.tile!.isSelected)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(_shimmerAnimation.value - 1, -1),
                                end: Alignment(_shimmerAnimation.value, 0),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      
                      // 宠物表情
                      Center(
                        child: Text(
                          widget.tile!.petType.emoji,
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
                      
                      // 选中装饰
                      if (widget.tile!.isSelected) ...[
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Text(
                            '💖',
                            style: TextStyle(fontSize: widget.size * 0.15),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .scale(duration: 800.ms, curve: Curves.easeInOut)
                              .then()
                              .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0)),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Text(
                            '💖',
                            style: TextStyle(fontSize: widget.size * 0.15),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .scale(duration: 800.ms, curve: Curves.easeInOut, delay: 200.ms)
                              .then()
                              .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0)),
                        ),
                      ],
                      
                      // 匹配特效
                      if (widget.tile!.isMatched)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: RadialGradient(
                              colors: [
                                Colors.yellow.withOpacity(0.8),
                                Colors.orange.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '✨',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .scale(duration: 300.ms)
                            .then()
                            .rotate(duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 