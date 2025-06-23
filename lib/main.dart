import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'providers/game_provider.dart';
import 'widgets/game_grid.dart';
import 'widgets/game_info_panel.dart';
import 'widgets/game_over_dialog.dart';

void main() {
  runApp(const PetMatchGame());
}

class PetMatchGame extends StatelessWidget {
  const PetMatchGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: '🐾 宠物消消乐·炫彩版',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'SystemUI',
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  bool _hasShownDialog = false;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _titleController;
  
  // 添加粒子管理器
  late ParticleManager _particleManager;
  
  @override
  void initState() {
    super.initState();
    
    // 背景动画控制器
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // 粒子动画控制器  
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    // 标题动画控制器
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    // 初始化粒子管理器
    _particleManager = ParticleManager();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _titleController.dispose();
    _particleManager.dispose(); // 清理粒子资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // 检查游戏结束状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (gameProvider.isGameOver && !_hasShownDialog) {
            _hasShownDialog = true;
            _showGameOverDialog(context, gameProvider);
          } else if (!gameProvider.isGameOver) {
            _hasShownDialog = false;
          }
        });

        return Scaffold(
          body: Stack(
            children: [
              // 动态背景
              _buildDynamicBackground(),
              
              // 浮动粒子
              _buildFloatingParticles(),
              
              // 主要内容
              SafeArea(
                child: _buildMainContent(gameProvider),
              ),
            ],
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
          painter: OptimizedParticlePainter(
            _particleController.value,
            _particleManager,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(GameProvider gameProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        
        // 响应式布局计算
        final titleHeight = math.min(100.0, screenHeight * 0.12);
        final infoHeight = math.min(80.0, screenHeight * 0.1);
        final buttonHeight = math.min(100.0, screenHeight * 0.12);
        final spacing = 16.0;
        
        final availableHeight = screenHeight - titleHeight - infoHeight - buttonHeight - spacing * 4;
        
        return Column(
          children: [
            // 🌟 炫酷标题区域
            Container(
              height: titleHeight,
              width: screenWidth,
              child: _buildEnhancedTitle(),
            )
                .animate()
                .slideY(begin: -1, duration: 1000.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 800.ms),
            
            SizedBox(height: spacing),
            
            // 📊 游戏信息面板
            Container(
              height: infoHeight,
              child: const GameInfoPanel(),
            )
                .animate(delay: 300.ms)
                .slideX(begin: -1, duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 600.ms),
            
            SizedBox(height: spacing),
            
            // 🎮 游戏网格区域
            Expanded(
              child: Container(
                height: availableHeight,
                padding: EdgeInsets.symmetric(horizontal: math.min(20, screenWidth * 0.05)),
                child: const GameGrid(),
              )
                  .animate(delay: 600.ms)
                  .scale(begin: const Offset(0.3, 0.3), duration: 1200.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 800.ms),
            ),
            
            SizedBox(height: spacing),
            
            // 🎯 操作按钮区域
            Container(
              height: buttonHeight,
              child: _buildActionButtons(gameProvider),
            )
                .animate(delay: 900.ms)
                .slideY(begin: 1, duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 600.ms),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        final pulse = 0.95 + 0.1 * _titleController.value;
        
        return Transform.scale(
          scale: pulse,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 主标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🐾', style: TextStyle(fontSize: 28 * pulse))
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
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.6)),
                    
                    const SizedBox(width: 8),
                    
                    Text('🐾', style: TextStyle(fontSize: 28 * pulse))
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(begin: 0, end: -0.1, duration: 2000.ms)
                        .then()
                        .rotate(begin: -0.1, end: 0.1, duration: 2000.ms),
                  ],
                ),
                
                // 副标题
                Text(
                  '✨ 炫彩特效版 ✨',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.pink.withOpacity(0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeIn(duration: 1000.ms)
                    .then(delay: 2000.ms)
                    .fadeOut(duration: 1000.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEnhancedButton(
            '🔄 重新开始',
            Colors.orange.shade400,
            Colors.orange.shade600,
            () => gameProvider.resetGame(),
          ),
          
          if (gameProvider.isGameOver) ...[
            const SizedBox(width: 16),
            _buildEnhancedButton(
              gameProvider.score >= gameProvider.targetScore
                  ? '🎉 下一关'
                  : '💪 再挑战',
              gameProvider.score >= gameProvider.targetScore
                  ? Colors.green.shade400
                  : Colors.red.shade400,
              gameProvider.score >= gameProvider.targetScore
                  ? Colors.green.shade600
                  : Colors.red.shade600,
              () => gameProvider.resetGame(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(String text, Color color, Color shadowColor, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .effect(duration: 3000.ms)
          .then()
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 1500.ms)
          .then()
          .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 1500.ms),
    );
  }

  void _showGameOverDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameOverDialog(
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
        );
      },
    );
  }
}

// 🎨 粒子管理器 - 修复内存泄漏问题
class ParticleManager {
  final List<Particle> _particles = [];
  
  ParticleManager() {
    _generateParticles();
  }
  
  void _generateParticles() {
    final random = math.Random();
    _particles.clear();
    _particles.addAll(List.generate(20, (index) { // 减少粒子数量提升性能
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 8 + 6, // 减小粒子大小
        speed: random.nextDouble() * 0.2 + 0.05, // 减慢速度
        emoji: ['🌟', '✨', '💫', '⭐', '🌈', '💖', '🎀', '🦄'][random.nextInt(8)],
        phase: random.nextDouble() * math.pi * 2,
      );
    }));
  }
  
  List<Particle> get particles => _particles;
  
  void dispose() {
    _particles.clear();
  }
}

// 🎨 优化的粒子绘制器 - 修复内存泄漏和性能问题
class OptimizedParticlePainter extends CustomPainter {
  final double animation;
  final ParticleManager particleManager;

  OptimizedParticlePainter(this.animation, this.particleManager);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particleManager.particles) {
      // 更新粒子位置
      particle.y -= particle.speed * 0.006; // 减慢更新速度
      particle.x += math.sin(animation * math.pi * 2 + particle.phase) * 0.001;
      
      // 重置越界粒子
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = math.Random().nextDouble();
      }
      
      // 绘制粒子
      final painter = TextPainter(
        text: TextSpan(
          text: particle.emoji,
          style: TextStyle(
            fontSize: particle.size,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      painter.layout();
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
  bool shouldRepaint(OptimizedParticlePainter oldDelegate) => 
      animation != oldDelegate.animation;
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
