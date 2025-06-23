import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

class GameOverDialog extends StatefulWidget {
  final bool isWin;
  final int score;
  final int level;
  final VoidCallback onRestart;
  final VoidCallback onNextLevel;

  const GameOverDialog({
    super.key,
    required this.isWin,
    required this.score,
    required this.level,
    required this.onRestart,
    required this.onNextLevel,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _dialogController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isWin) {
      _confettiController.play();
    }
    
    _dialogController.forward();
    _starController.repeat();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _dialogController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景模糊效果
        Container(
          color: Colors.black.withOpacity(0.3),
          child: BackdropFilter(
            filter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
            child: Container(),
          ),
        ),
        
        // 彩带效果（胜利时）
        if (widget.isWin) ...[
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // 向下
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.pink,
                Colors.purple,
                Colors.blue,
                Colors.yellow,
                Colors.orange,
                Colors.green,
              ],
            ),
          ),
          Positioned(
            top: 100,
            right: MediaQuery.of(context).size.width / 2 - 100,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // 向下
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.cyan,
                Colors.lime,
                Colors.amber,
                Colors.deepOrange,
                Colors.teal,
                Colors.indigo,
              ],
            ),
          ),
        ],
        
        // 主对话框
        Center(
          child: AnimatedBuilder(
            animation: _dialogController,
            builder: (context, child) {
              return Transform.scale(
                scale: Curves.elasticOut.transform(_dialogController.value),
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isWin
                          ? [
                              Colors.yellow.shade100,
                              Colors.orange.shade100,
                              Colors.pink.shade100,
                            ]
                          : [
                              Colors.red.shade100,
                              Colors.pink.shade100,
                              Colors.purple.shade100,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 动画表情
                      _buildAnimatedEmoji(),
                      
                      const SizedBox(height: 20),
                      
                      // 标题
                      Text(
                        widget.isWin ? '🎉 恭喜过关！' : '💔 游戏结束',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: widget.isWin 
                              ? Colors.orange.shade800 
                              : Colors.red.shade800,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 24),
                      
                      // 分数信息卡片
                      _buildScoreCard()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 32),
                      
                      // 按钮区域
                      _buildButtonRow()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedEmoji() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.isWin 
                    ? Colors.yellow.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: _starController.value * 6.28, // 2π
              child: Text(
                widget.isWin ? '🎉' : '💔',
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildScoreRow('本关得分', '${widget.score}分', '🏆', Colors.orange),
          const SizedBox(height: 12),
          _buildScoreRow('当前等级', '第${widget.level}关', '⭐', Colors.purple),
          if (widget.isWin) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.blue.shade300],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '🎊 完美通关！',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, String emoji, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24))
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
                             color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGlowButton(
          '🔄 重新开始',
          Colors.blue,
          widget.onRestart,
        ),
        if (widget.isWin)
          _buildGlowButton(
            '🚀 下一关',
            Colors.green,
            widget.onNextLevel,
          ),
      ],
    );
  }

  Widget _buildGlowButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .effect(duration: 2000.ms)
        .then()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 1000.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: 1000.ms,
        );
  }
} 