import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/pet_tile.dart';
import '../models/pet_type.dart';
import '../providers/game_provider.dart';

class PetTileWidget extends StatelessWidget {
  final PetTile? tile;
  final double size;
  final VoidCallback? onTap;

  const PetTileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tile == null) {
      return SizedBox(
        width: size,
        height: size,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: tile!.isSelected 
                ? tile!.petType.color.withOpacity(0.8)
                : tile!.petType.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: tile!.petType.shadowColor,
                blurRadius: tile!.isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: tile!.isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
          child: Stack(
            children: [
              // 背景渐变
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tile!.petType.color.withOpacity(0.9),
                      tile!.petType.color,
                      tile!.petType.color.withOpacity(0.8),
                    ],
                  ),
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
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // 宠物表情
              Center(
                child: Text(
                  tile!.petType.emoji,
                  style: TextStyle(
                    fontSize: size * 0.5,
                  ),
                ),
              ),
              
              // 星星装饰
              if (tile!.isHighlighted) 
                Positioned(
                  top: 4,
                  right: 4,
                  child: Text(
                    '✨',
                    style: TextStyle(fontSize: size * 0.2),
                  ),
                ),
              
              // 爱心装饰（选中时）
              if (tile!.isSelected) ...[
                Positioned(
                  top: 2,
                  left: 2,
                  child: Text(
                    '💖',
                    style: TextStyle(fontSize: size * 0.15),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Text(
                    '💖',
                    style: TextStyle(fontSize: size * 0.15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 🎨 增强版动画宠物方块组件 - 修复交换动画和特效
class AnimatedPetTileWidget extends StatefulWidget {
  final PetTile? tile;
  final int row;
  final int col;
  final double size;
  final VoidCallback? onTap;
  final bool isAnimating;

  const AnimatedPetTileWidget({
    super.key,
    required this.tile,
    required this.row,
    required this.col,
    required this.size,
    this.onTap,
    this.isAnimating = false,
  });

  @override
  State<AnimatedPetTileWidget> createState() => _AnimatedPetTileWidgetState();
}

class _AnimatedPetTileWidgetState extends State<AnimatedPetTileWidget> 
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _swapController;
  late AnimationController _matchController;
  late AnimationController _fallController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _swapAnimation;
  late Animation<double> _fallAnimation;
  
  // 交换动画状态
  bool _isSwapping = false;
  Offset _swapOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // 弹跳动画控制器
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // 交换动画控制器
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 匹配消除动画控制器
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 下落动画控制器
    _fallController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
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
      end: 4.0,
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
    
    _fallAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fallController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedPetTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测交换动画
    _checkSwapAnimation();
    
    // 检测匹配消除动画
    if (widget.tile?.isMatched == true && oldWidget.tile?.isMatched != true) {
      _playMatchAnimation();
    }
    
    // 检测选中状态变化
    if (widget.tile?.isSelected == true && oldWidget.tile?.isSelected != true) {
      _playBounceAnimation();
    }
    
    // 检测下落动画
    if (widget.tile?.isFalling == true && oldWidget.tile?.isFalling != true) {
      _playFallAnimation();
    }
  }

  // 🔄 检测并播放交换动画
  void _checkSwapAnimation() {
    final gameProvider = context.read<GameProvider>();
    
    if (gameProvider.isSwapAnimating) {
      final swappingTile1 = gameProvider.swappingTile1;
      final swappingTile2 = gameProvider.swappingTile2;
      
      if (swappingTile1 != null && swappingTile2 != null) {
        // 检查当前方块是否参与交换
        final currentTile = widget.tile;
        if (currentTile != null) {
          if (currentTile.row == swappingTile1.row && currentTile.col == swappingTile1.col) {
            // 当前方块是第一个交换方块
            _playSwapAnimation(swappingTile2.row - swappingTile1.row, swappingTile2.col - swappingTile1.col);
          } else if (currentTile.row == swappingTile2.row && currentTile.col == swappingTile2.col) {
            // 当前方块是第二个交换方块
            _playSwapAnimation(swappingTile1.row - swappingTile2.row, swappingTile1.col - swappingTile2.col);
          }
        }
      }
    } else if (_isSwapping) {
      // 交换动画结束，重置状态
      _isSwapping = false;
      _swapController.reset();
    }
  }

  // 🎬 播放交换动画
  void _playSwapAnimation(int rowDiff, int colDiff) {
    if (_isSwapping) return;
    
    _isSwapping = true;
    
    // 计算交换偏移量
    final offset = Offset(
      colDiff * (widget.size + 4), // 4是margin
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
      // 交换完成后保持在新位置一段时间
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _swapController.reverse();
        }
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

  void _playFallAnimation() {
    _fallController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _swapController.dispose();
    _matchController.dispose();
    _fallController.dispose();
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
        _fallAnimation
      ]),
      builder: (context, child) {
        // 计算综合变换
        double scale = 1.0;
        if (widget.tile!.isMatched) {
          scale = _scaleAnimation.value;
        } else if (widget.tile!.isSelected) {
          scale = _bounceAnimation.value;
        }
        
        // 交换动画偏移
        final swapOffset = _isSwapping ? _swapAnimation.value : Offset.zero;
        
        // 下落动画偏移
        final fallOffset = widget.tile!.isFalling 
            ? Offset(0, _fallAnimation.value * widget.size * 2)
            : Offset.zero;
        
        final totalOffset = swapOffset + fallOffset;
        
        return Transform.translate(
          offset: totalOffset,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: widget.tile!.isMatched ? _rotationAnimation.value : 0,
              child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.size,
                height: widget.size,
                margin: const EdgeInsets.all(1.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  decoration: BoxDecoration(
                    color: widget.tile!.isSelected 
                        ? widget.tile!.petType.color.withOpacity(0.9)
                        : widget.tile!.petType.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tile!.petType.shadowColor,
                        blurRadius: widget.tile!.isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                        spreadRadius: widget.tile!.isSelected ? 2 : 0,
                      ),
                    ],
                    border: widget.tile!.isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Stack(
                    children: [
                      // 背景渐变
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.tile!.petType.color.withOpacity(0.9),
                              widget.tile!.petType.color,
                              widget.tile!.petType.color.withOpacity(0.7),
                            ],
                          ),
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
                      
                      // 选中时的闪光效果
                      if (widget.tile!.isSelected)
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
                      
                      // 星星装饰
                      if (widget.tile!.isHighlighted) 
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            '✨',
                            style: TextStyle(fontSize: widget.size * 0.2),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 1000.ms)
                              .rotate(duration: 2000.ms),
                        ),
                      
                      // 爱心装饰（选中时）
                      if (widget.tile!.isSelected) ...[
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Text(
                            '💖',
                            style: TextStyle(fontSize: widget.size * 0.15),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.2, 1.2),
                                duration: 800.ms,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(0.8, 0.8),
                                duration: 800.ms,
                              ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Text(
                            '💖',
                            style: TextStyle(fontSize: widget.size * 0.15),
                          )
                              .animate(delay: 400.ms, onPlay: (controller) => controller.repeat())
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.2, 1.2),
                                duration: 800.ms,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(0.8, 0.8),
                                duration: 800.ms,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
                  .animate(
                    target: widget.tile!.isFalling ? 1 : 0,
                  )
                  .slideY(
                    begin: -2,
                    duration: 600.ms,
                    curve: Curves.bounceOut,
                  )
                  .fadeIn(duration: 300.ms),
            ),
          ),
        ),
      );
    },
  );
}
}

