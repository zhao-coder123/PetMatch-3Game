import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.pink.shade100,
                Colors.purple.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(
                '分数',
                '${gameProvider.score}',
                '🏆',
                Colors.orange,
              ),
              _buildDivider(),
              _buildInfoItem(
                '步数',
                '${gameProvider.moves}',
                '👣',
                Colors.blue,
              ),
              _buildDivider(),
              _buildInfoItem(
                '等级',
                '${gameProvider.level}',
                '⭐',
                Colors.yellow.shade700,
              ),
              _buildDivider(),
              _buildTargetProgress(gameProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, String emoji, Color color) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildTargetProgress(GameProvider gameProvider) {
    final progress = gameProvider.score / gameProvider.targetScore;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        const Text(
          '🎯',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.pink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(clampedProgress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
} 