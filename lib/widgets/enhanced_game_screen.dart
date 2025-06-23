import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_provider.dart';
import 'simple_game_grid.dart';
import 'game_info_panel.dart';
import 'enhanced_game_over_dialog.dart';
import 'settings_panel.dart';

class EnhancedGameScreen extends StatefulWidget {
  const EnhancedGameScreen({super.key});

  @override
  State<EnhancedGameScreen> createState() => _EnhancedGameScreenState();
}

class _EnhancedGameScreenState extends State<EnhancedGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _titleController;
  
  late ParticleManager _particleManager;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    
    // 优化动画控制器，降低刷新频率
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 12), // 延长周期
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20), // 延长周期
      vsync: this,
    )..repeat();
    
    _titleController = AnimationController(
      duration: const Duration(seconds: 4), // 延长周期
      vsync: this,
    )..repeat(reverse: true);
    
    _particleManager = ParticleManager();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _titleController.dispose();
    _particleManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // 检查游戏结束状态并显示对话框
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (gameProvider.isGameOver && !_hasShownDialog) {
            _hasShownDialog = true;
            _showGameOverDialog(context, gameProvider);
          } else if (!gameProvider.isGameOver) {
            _hasShownDialog = false;
          }
        });

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                // 动态背景
                _buildDynamicBackground(),
                
                // 浮动粒子
                _buildFloatingParticles(),
                
                // 设置按钮 - 右上角
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.purple),
                      onPressed: () => _showSettingsDialog(context),
                    ),
                  ),
                ),
                
                // 主要内容 - 使用安全的布局方式
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;
                    final titleHeight = screenHeight * 0.12; // 12%给标题
                    final panelHeight = screenHeight * 0.12; // 12%给信息面板
                    final buttonHeight = screenHeight * 0.12; // 12%给按钮
                    final gridHeight = screenHeight * 0.64; // 64%给游戏网格
                    
                    return Column(
                      children: [
                        // 炫酷标题 - 固定高度
                        SizedBox(
                          height: titleHeight,
                          child: _buildAnimatedTitle(),
                        )
                            .animate()
                            .slideY(begin: -1, duration: 800.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 600.ms),
                        
                        // 游戏信息面板 - 固定高度
                        SizedBox(
                          height: panelHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: const GameInfoPanel(),
                          ),
                        )
                            .animate()
                            .slideX(begin: -1, duration: 800.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 600.ms),
                        
                        // 游戏网格 - 固定高度，防止溢出
                        SizedBox(
                          height: gridHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: const SimpleGameGrid(),
                          ),
                        )
                            .animate()
                            .scale(begin: const Offset(0.8, 0.8), duration: 1000.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: 800.ms),
                        
                        // 操作按钮 - 固定高度
                        SizedBox(
                          height: buttonHeight,
                          child: _buildActionButtons(gameProvider),
                        )
                            .animate()
                            .slideY(begin: 1, duration: 800.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 600.ms),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final t = _backgroundController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(Colors.pink.shade200, Colors.purple.shade300, t)!,
                Color.lerp(Colors.purple.shade200, Colors.blue.shade300, math.sin(t * math.pi * 2))!,
                Color.lerp(Colors.blue.shade200, Colors.cyan.shade300, t)!,
                Color.lerp(Colors.cyan.shade200, Colors.pink.shade300, math.cos(t * math.pi * 2))!,
              ],
              stops: [
                0.0,
                0.3 + t * 0.2,
                0.7 - t * 0.2,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            _particleController.value,
            _particleManager,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        final pulse = 0.95 + 0.05 * _titleController.value; // 减小脉冲幅度
        
        return Center(
          child: Transform.scale(
            scale: pulse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🐾', style: TextStyle(fontSize: 24 * pulse))
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(begin: 0, end: 0.1, duration: 2000.ms)
                        .then()
                        .rotate(begin: 0.1, end: -0.1, duration: 2000.ms),
                    
                    const SizedBox(width: 8),
                    
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.pink.shade400,
                          Colors.purple.shade400,
                          Colors.blue.shade400,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        '宠物消消乐',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.6)),
                    
                    const SizedBox(width: 8),
                    
                    Text('🐾', style: TextStyle(fontSize: 24 * pulse))
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(begin: 0, end: -0.1, duration: 2000.ms)
                        .then()
                        .rotate(begin: -0.1, end: 0.1, duration: 2000.ms),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEnhancedButton(
            '🔄 重新开始',
            Colors.orange.shade400,
            () => gameProvider.resetGame(),
          ),
          if (gameProvider.isGameOver)
            _buildEnhancedButton(
              gameProvider.score >= gameProvider.targetScore
                  ? '🎉 下一关'
                  : '💪 再挑战',
              gameProvider.score >= gameProvider.targetScore
                  ? Colors.green.shade400
                  : Colors.red.shade400,
              () => gameProvider.score >= gameProvider.targetScore
                  ? gameProvider.nextLevel()
                  : gameProvider.resetGame(),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 48, // 固定高度，防止溢出
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .effect(duration: 4000.ms)
          .then()
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 2000.ms)
          .then()
          .scale(begin: const Offset(1.02, 1.02), end: const Offset(1.0, 1.0), duration: 2000.ms),
    );
  }

  void _showGameOverDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedGameOverDialog(
          isWin: gameProvider.score >= gameProvider.targetScore,
          score: gameProvider.score,
          level: gameProvider.level,
          onRestart: () {
            Navigator.of(context).pop();
            gameProvider.resetGame();
          },
          onNextLevel: () {
            Navigator.of(context).pop();
            gameProvider.nextLevel();
          },
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SettingsPanel();
      },
    );
  }
}

// 优化的粒子管理器
class ParticleManager {
  final List<Particle> _particles = [];
  int _updateCounter = 0;
  
  ParticleManager() {
    _generateParticles();
  }
  
  void _generateParticles() {
    final random = math.Random();
    _particles.clear();
    // 减少粒子数量提升性能
    _particles.addAll(List.generate(6, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 2, // 减小粒子大小
        speed: random.nextDouble() * 0.03 + 0.01, // 减慢速度
        emoji: ['🌟', '✨'][random.nextInt(2)], // 减少种类
        phase: random.nextDouble() * math.pi * 2,
      );
    }));
  }
  
  List<Particle> get particles => _particles;
  
  // 添加更新频率控制
  bool shouldUpdate() {
    _updateCounter++;
    return _updateCounter % 3 == 0; // 每3帧更新一次
  }
  
  void dispose() {
    _particles.clear();
  }
}

// 优化的粒子绘制器
class ParticlePainter extends CustomPainter {
  final double animation;
  final ParticleManager particleManager;
  static final Map<String, TextPainter> _textPainterCache = {};

  ParticlePainter(this.animation, this.particleManager);

  @override
  void paint(Canvas canvas, Size size) {
    // 降低绘制频率
    if (!particleManager.shouldUpdate()) return;
    
    for (var particle in particleManager.particles) {
      // 优化位置更新计算
      particle.y -= particle.speed * 0.002;
      particle.x += math.sin(animation * math.pi + particle.phase) * 0.0003;
      
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = math.Random().nextDouble();
      }
      
      // 使用缓存的TextPainter
      final cacheKey = '${particle.emoji}_${particle.size.toInt()}';
      TextPainter? painter = _textPainterCache[cacheKey];
      
      if (painter == null) {
        painter = TextPainter(
          text: TextSpan(
            text: particle.emoji,
            style: TextStyle(
              fontSize: particle.size,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        painter.layout();
        _textPainterCache[cacheKey] = painter;
      }
      
      painter.paint(
        canvas,
        Offset(
          particle.x * size.width - painter.width / 2,
          particle.y * size.height - painter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => 
      animation != oldDelegate.animation || 
      particleManager.shouldUpdate();
}

// 粒子数据类
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final String emoji;
  final double phase;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.emoji,
    required this.phase,
  });
} 