import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

// 新的动画宠物方块组件
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
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
  }

  @override
  void didUpdateWidget(AnimatedPetTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测到匹配时播放消除动画
    if (widget.tile?.isMatched == true && oldWidget.tile?.isMatched != true) {
      _playMatchAnimation();
    }
    
    // 检测到选中状态变化时播放弹跳动画
    if (widget.tile?.isSelected == true && oldWidget.tile?.isSelected != true) {
      _playBounceAnimation();
    }
    
    // 检测到下落时播放下落动画
    if (widget.tile?.isFalling == true && oldWidget.tile?.isFalling != true) {
      _playFallAnimation();
    }
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
    // 下落动画已经在 flutter_animate 中处理
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _swapController.dispose();
    _matchController.dispose();
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
      animation: Listenable.merge([_bounceAnimation, _scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.tile!.isMatched 
              ? _scaleAnimation.value 
              : _bounceAnimation.value,
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
        );
      },
    );
  }
}

// 匹配特效组件
class MatchEffectWidget extends StatefulWidget {
  final MatchEffect effect;
  final double size;

  const MatchEffectWidget({
    super.key,
    required this.effect,
    required this.size,
  });

  @override
  State<MatchEffectWidget> createState() => _MatchEffectWidgetState();
}

class _MatchEffectWidgetState extends State<MatchEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.effect.color.withOpacity(0.8),
                    widget.effect.color.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  widget.effect.emoji,
                  style: TextStyle(
                    fontSize: widget.size * 0.6,
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

 