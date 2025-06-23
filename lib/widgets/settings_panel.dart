import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final AudioManager _audioManager = AudioManager();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.pink.shade100,
              Colors.blue.shade100,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                const Text(
                  '游戏设置',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 音效设置
            _buildSettingItem(
              icon: Icons.volume_up,
              title: '音效',
              subtitle: '游戏音效开关',
              value: _audioManager.soundEnabled,
              onChanged: (value) {
                setState(() {
                  _audioManager.setSoundEnabled(value);
                });
              },
            ),
            
            // 音效音量
            if (_audioManager.soundEnabled) ...[
              const SizedBox(height: 8),
              _buildVolumeSlider(
                icon: Icons.volume_down,
                title: '音效音量',
                value: _audioManager.soundVolume,
                onChanged: (value) {
                  setState(() {
                    _audioManager.setSoundVolume(value);
                  });
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 背景音乐设置
            _buildSettingItem(
              icon: Icons.music_note,
              title: '背景音乐',
              subtitle: '播放背景音乐',
              value: _audioManager.musicEnabled,
              onChanged: (value) {
                setState(() {
                  _audioManager.setMusicEnabled(value);
                });
              },
            ),
            
            // 音乐音量
            if (_audioManager.musicEnabled) ...[
              const SizedBox(height: 8),
              _buildVolumeSlider(
                icon: Icons.music_note_outlined,
                title: '音乐音量',
                value: _audioManager.musicVolume,
                onChanged: (value) {
                  setState(() {
                    _audioManager.setMusicVolume(value);
                  });
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 震动设置
            _buildSettingItem(
              icon: Icons.vibration,
              title: '震动反馈',
              subtitle: '触感反馈开关',
              value: _audioManager.vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _audioManager.setVibrationEnabled(value);
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // 确定按钮
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '确定',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purple.shade400,
            activeTrackColor: Colors.purple.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade400, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.purple.shade400,
                inactiveTrackColor: Colors.purple.shade200,
                thumbColor: Colors.purple.shade500,
                overlayColor: Colors.purple.shade200.withOpacity(0.4),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(value * 100).toInt()}%',
              ),
            ),
          ),
        ],
      ),
    );
  }
} 