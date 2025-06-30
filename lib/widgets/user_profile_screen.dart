import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'enhanced_game_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade300,
                  Colors.pink.shade300,
                  Colors.orange.shade300,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 顶部导航
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            '🐾 玩家档案',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // 占位平衡布局
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 用户头像和基本信息
                    _buildUserHeader(gameProvider)
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: -0.3),
                    
                    const SizedBox(height: 24),
                    
                    // 游戏统计卡片
                    _buildStatsGrid(gameProvider)
                        .animate()
                        .fadeIn(duration: 1000.ms, delay: 200.ms)
                        .slideY(begin: 0.3),
                    
                    const SizedBox(height: 24),
                    
                    // 成就系统
                    _buildAchievements(context, gameProvider)
                        .animate()
                        .fadeIn(duration: 1000.ms, delay: 400.ms)
                        .slideY(begin: 0.3),
                    
                    const SizedBox(height: 24),
                    
                    // 最近游戏记录
                    _buildRecentGames(gameProvider)
                        .animate()
                        .fadeIn(duration: 1000.ms, delay: 600.ms)
                        .slideY(begin: 0.3),
                    
                    const SizedBox(height: 24),
                    
                    // 开始游戏按钮
                    _buildPlayButton(context)
                        .animate()
                        .fadeIn(duration: 1000.ms, delay: 800.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.pink.shade400],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🐱',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 用户名
          const Text(
            '宠物大师',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 当前关卡徽章
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.red.shade400],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '第 ${gameProvider.level} 关守护者',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GameProvider gameProvider) {
    final stats = [
      {'icon': '🎮', 'label': '游戏次数', 'value': '${gameProvider.totalGamesPlayed}', 'color': Colors.blue},
      {'icon': '⭐', 'label': '总分数', 'value': '${gameProvider.totalScore}', 'color': Colors.orange},
      {'icon': '🏆', 'label': '最高关卡', 'value': '${gameProvider.maxLevel}', 'color': Colors.purple},
      {'icon': '💥', 'label': '总消除', 'value': '${gameProvider.totalMatches}', 'color': Colors.red},
      {'icon': '🔥', 'label': '最佳连击', 'value': '${gameProvider.longestCombo}', 'color': Colors.green},
      {'icon': '📅', 'label': '最近游戏', 'value': _formatLastPlay(gameProvider.lastPlayTime), 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat['icon'] as String,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: stat['color'] as Color,
                ),
              ),
              Text(
                stat['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievements(BuildContext context, GameProvider gameProvider) {
    final achievements = [
      {
        'icon': '🎯',
        'title': '新手上路',
        'description': '完成第一局游戏',
        'unlocked': gameProvider.totalGamesPlayed >= 1,
      },
      {
        'icon': '🏆',
        'title': '连击高手',
        'description': '达成5连击',
        'unlocked': gameProvider.longestCombo >= 5,
      },
      {
        'icon': '⭐',
        'title': '分数大师',
        'description': '总分数达到10000',
        'unlocked': gameProvider.totalScore >= 10000,
      },
      {
        'icon': '🚀',
        'title': '关卡征服者',
        'description': '通过第5关',
        'unlocked': gameProvider.maxLevel >= 5,
      },
      {
        'icon': '💎',
        'title': '传奇玩家',
        'description': '游戏50次',
        'unlocked': gameProvider.totalGamesPlayed >= 50,
      },
      {
        'icon': '🔥',
        'title': '连击狂魔',
        'description': '达成10连击',
        'unlocked': gameProvider.longestCombo >= 10,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏅 成就收集',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievements.map((achievement) {
              final unlocked = achievement['unlocked'] as bool;
              return Container(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: unlocked 
                      ? Colors.yellow.shade100 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unlocked 
                        ? Colors.yellow.shade300 
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      achievement['icon'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        color: unlocked ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.purple : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGames(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 游戏统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      '平均分数',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      gameProvider.totalGamesPlayed > 0 
                          ? (gameProvider.totalScore / gameProvider.totalGamesPlayed).toInt().toString()
                          : '0',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      '消除效率',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      gameProvider.totalGamesPlayed > 0 
                          ? (gameProvider.totalMatches / gameProvider.totalGamesPlayed).toInt().toString()
                          : '0',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('🏃', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      '游戏频率',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _getPlayFrequency(gameProvider),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/game'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.purple,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: BorderSide(color: Colors.purple.shade200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text(
              '开始游戏',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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

  String _formatLastPlay(DateTime lastPlay) {
    final now = DateTime.now();
    final difference = now.difference(lastPlay);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  String _getPlayFrequency(GameProvider gameProvider) {
    if (gameProvider.totalGamesPlayed == 0) return '新手';
    if (gameProvider.totalGamesPlayed < 5) return '休闲';
    if (gameProvider.totalGamesPlayed < 20) return '活跃';
    if (gameProvider.totalGamesPlayed < 50) return '热忱';
    return '狂热';
  }
} 