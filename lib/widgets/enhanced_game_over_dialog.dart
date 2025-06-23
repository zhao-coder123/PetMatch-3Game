import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class EnhancedGameOverDialog extends StatefulWidget {
  final bool isWin;
  final int score;
  final int level;
  final VoidCallback onRestart;
  final VoidCallback onNextLevel;

  const EnhancedGameOverDialog({
    super.key,
    required this.isWin,
    required this.score,
    required this.level,
    required this.onRestart,
    required this.onNextLevel,
  });

  @override
  State<EnhancedGameOverDialog> createState() => _EnhancedGameOverDialogState();
}

class _EnhancedGameOverDialogState extends State<EnhancedGameOverDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.85).clamp(280.0, 400.0);
    final dialogHeight = (screenSize.height * 0.6).clamp(300.0, 500.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isWin
                        ? [
                            Colors.green.shade100,
                            Colors.blue.shade100,
                            Colors.purple.shade100,
                          ]
                        : [
                            Colors.orange.shade100,
                            Colors.red.shade100,
                            Colors.pink.shade100,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 标题和表情
                      Expanded(
                        flex: 2,
                        child: _buildTitle(),
                      ),
                      
                      // 分数信息
                      Expanded(
                        flex: 2,
                        child: _buildScoreInfo(),
                      ),
                      
                      // 成就展示
                      Expanded(
                        flex: 2,
                        child: _buildAchievements(),
                      ),
                      
                      // 操作按钮
                      Expanded(
                        flex: 2,
                        child: _buildActionButtons(),
                      ),
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

  Widget _buildTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.isWin ? '🎉' : '😔',
          style: const TextStyle(fontSize: 48),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(begin: -0.1, end: 0.1, duration: 2000.ms)
            .then()
            .rotate(begin: 0.1, end: -0.1, duration: 2000.ms),
        
        const SizedBox(height: 8),
        
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.isWin ? '恭喜过关！' : '再接再厉！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isWin ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        )
            .animate()
            .slideY(begin: -1, duration: 600.ms, curve: Curves.bounceOut)
            .fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildScoreInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('关卡', '${widget.level}', '⭐', Colors.yellow.shade700),
              _buildStatItem('得分', '${widget.score}', '🏆', Colors.orange.shade600),
            ],
          ),
          if (widget.isWin) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade200, Colors.blue.shade200],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '🌟 解锁第${widget.level + 1}关 🌟',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            )
                .animate()
                .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.6))
                .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut),
          ],
        ],
      ),
    )
        .animate()
        .slideX(begin: 1, duration: 800.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 600.ms);
  }

  Widget _buildStatItem(String label, String value, String emoji, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final achievements = <String>[];
    
    if (widget.score >= 5000) achievements.add('🔥 高分达人');
    if (widget.level >= 5) achievements.add('🚀 闯关专家');
    if (widget.score >= 10000) achievements.add('💎 超级玩家');
    
    if (achievements.isEmpty) achievements.add('🌱 继续努力');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '🏅 成就展示',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: achievements.map((achievement) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade100, Colors.pink.shade100],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      achievement,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, duration: 1000.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 800.ms);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            '🔄 重新开始',
            Colors.orange.shade400,
            widget.onRestart,
          ),
        ),
        const SizedBox(width: 12),
        if (widget.isWin)
          Expanded(
            child: _buildActionButton(
              '🎉 下一关',
              Colors.green.shade400,
              widget.onNextLevel,
            ),
          )
        else
          Expanded(
            child: _buildActionButton(
              '💪 再挑战',
              Colors.red.shade400,
              widget.onRestart,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      height: 48,
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
        .animate()
        .slideY(begin: 1, duration: 1200.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 1000.ms);
  }
}

// 烟花绘制器
class FireworksPainter extends CustomPainter {
  final double animation;

  FireworksPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 绘制多个烟花
    for (int i = 0; i < 5; i++) {
      final centerX = size.width * (0.2 + i * 0.15);
      final centerY = size.height * (0.3 + (i % 2) * 0.3);
      
      // 烟花爆炸效果
      for (int j = 0; j < 8; j++) {
        final angle = (j / 8) * 2 * 3.14159;
        final radius = 30 * animation;
        
        final x = centerX + radius * math.cos(angle);
        final y = centerY + radius * math.sin(angle);
        
        paint.color = [
          Colors.yellow,
          Colors.orange,
          Colors.red,
          Colors.pink,
          Colors.purple,
        ][j % 5].withOpacity(1 - animation);
        
        canvas.drawCircle(
          Offset(x, y),
          5 * (1 - animation),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) => 
      animation != oldDelegate.animation;
}

 