import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎆 粒子特效组件 - 为游戏添加炫酷的视觉效果
class ParticleEffect extends StatefulWidget {
  final Offset center;
  final Color color;
  final ParticleType type;
  final VoidCallback? onComplete;

  const ParticleEffect({
    super.key,
    required this.center,
    required this.color,
    this.type = ParticleType.explosion,
    this.onComplete,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.type == ParticleType.explosion ? 1000 : 1500,
      ),
      vsync: this,
    );

    _generateParticles();
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateParticles() {
    final random = math.Random();
    final particleCount = widget.type == ParticleType.explosion ? 15 : 8;
    
    _particles = List.generate(particleCount, (index) {
      return Particle(
        startX: widget.center.dx,
        startY: widget.center.dy,
        velocityX: (random.nextDouble() - 0.5) * _getVelocityRange(),
        velocityY: (random.nextDouble() - 0.5) * _getVelocityRange(),
        size: random.nextDouble() * 8 + 4,
        color: _generateParticleColor(random),
        life: random.nextDouble() * 0.5 + 0.5,
        type: widget.type,
      );
    });
  }

  double _getVelocityRange() {
    switch (widget.type) {
      case ParticleType.explosion:
        return 200.0;
      case ParticleType.firework:
        return 150.0;
      case ParticleType.sparkle:
        return 100.0;
    }
  }

  Color _generateParticleColor(math.Random random) {
    switch (widget.type) {
      case ParticleType.explosion:
        return Color.lerp(widget.color, Colors.white, random.nextDouble() * 0.5)!;
      case ParticleType.firework:
        final colors = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
        ];
        return colors[random.nextInt(colors.length)];
      case ParticleType.sparkle:
        return Color.lerp(Colors.white, widget.color, random.nextDouble())!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticleEffectPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 🎨 粒子特效绘制器
class ParticleEffectPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticleEffectPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    for (final particle in particles) {
      // 计算粒子当前位置
      final currentX = particle.startX + particle.velocityX * animationValue;
      final currentY = particle.startY + 
          particle.velocityY * animationValue + 
          0.5 * 200 * animationValue * animationValue; // 重力效果

      // 计算粒子生命周期
      final normalizedLife = (animationValue / particle.life).clamp(0.0, 1.0);
      final alpha = (1.0 - normalizedLife).clamp(0.0, 1.0);
      
      // 计算粒子大小变化
      double currentSize;
      switch (particle.type) {
        case ParticleType.explosion:
          currentSize = particle.size * (1.0 + animationValue * 0.5);
          break;
        case ParticleType.firework:
          currentSize = particle.size * math.sin(animationValue * math.pi);
          break;
        case ParticleType.sparkle:
          currentSize = particle.size * (1.0 - animationValue * 0.3);
          break;
      }

      // 设置画笔颜色和透明度
      paint.color = particle.color.withOpacity(alpha);

      // 绘制粒子
      switch (particle.type) {
        case ParticleType.explosion:
          _drawExplosionParticle(canvas, paint, currentX, currentY, currentSize);
          break;
        case ParticleType.firework:
          _drawFireworkParticle(canvas, paint, currentX, currentY, currentSize, animationValue);
          break;
        case ParticleType.sparkle:
          _drawSparkleParticle(canvas, paint, currentX, currentY, currentSize, animationValue);
          break;
      }
    }
  }

  void _drawExplosionParticle(Canvas canvas, Paint paint, double x, double y, double size) {
    canvas.drawCircle(Offset(x, y), size, paint);
  }

  void _drawFireworkParticle(Canvas canvas, Paint paint, double x, double y, double size, double animation) {
    // 绘制带拖尾的粒子
    final gradient = RadialGradient(
      colors: [paint.color, paint.color.withOpacity(0.0)],
    );
    
    final rect = Rect.fromCircle(center: Offset(x, y), radius: size);
    paint.shader = gradient.createShader(rect);
    
    canvas.drawCircle(Offset(x, y), size, paint);
    paint.shader = null;
  }

  void _drawSparkleParticle(Canvas canvas, Paint paint, double x, double y, double size, double animation) {
    // 绘制星形粒子
    final sparkleSize = size * (1.0 + math.sin(animation * math.pi * 4) * 0.3);
    
    // 绘制十字星形
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(x - sparkleSize, y),
      Offset(x + sparkleSize, y),
      paint,
    );
    canvas.drawLine(
      Offset(x, y - sparkleSize),
      Offset(x, y + sparkleSize),
      paint,
    );
    
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), sparkleSize * 0.3, paint);
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// 🎭 粒子类型枚举
enum ParticleType {
  explosion,  // 爆炸效果
  firework,   // 烟花效果
  sparkle,    // 闪烁效果
}

/// ✨ 粒子数据类
class Particle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;
  final double life;
  final ParticleType type;

  Particle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
    required this.life,
    required this.type,
  });
}

/// 🎆 粒子特效管理器
class ParticleEffectManager extends StatefulWidget {
  final Widget child;

  const ParticleEffectManager({
    super.key,
    required this.child,
  });

  @override
  State<ParticleEffectManager> createState() => _ParticleEffectManagerState();
}

class _ParticleEffectManagerState extends State<ParticleEffectManager> {
  final List<Widget> _activeEffects = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._activeEffects,
      ],
    );
  }

  /// 🚀 触发粒子特效
  void triggerEffect({
    required Offset position,
    required Color color,
    ParticleType type = ParticleType.explosion,
  }) {
    late Widget effect;
    
    effect = Positioned.fill(
      child: ParticleEffect(
        center: position,
        color: color,
        type: type,
        onComplete: () {
          setState(() {
            _activeEffects.remove(effect);
          });
        },
      ),
    );

    setState(() {
      _activeEffects.add(effect);
    });
  }

  /// 🎯 获取管理器实例的静态方法
  static _ParticleEffectManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ParticleEffectManagerState>();
  }
} 