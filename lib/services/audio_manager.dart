import 'package:audioplayers/audioplayers.dart';
// import 'package:vibration/vibration.dart'; // 暂时注释掉，避免编译错误
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// 音效类型枚举
enum SoundEffect {
  tap,           // 点击音效
  match,         // 匹配音效
  combo,         // 连击音效
  levelUp,       // 升级音效
  gameOver,      // 游戏结束音效
  victory,       // 胜利音效
  swap,          // 交换音效
  drop,          // 下落音效
}

/// 🎵 音效管理器 - 统一管理游戏中的音效和背景音乐
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // 音效播放器池 - 支持同时播放多个音效
  final List<AudioPlayer> _soundEffectPlayers = [];
  
  // 背景音乐播放器
  late AudioPlayer _backgroundMusicPlayer;
  
  // 音效设置
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _soundVolume = 0.7;
  double _musicVolume = 0.4;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  /// 🎮 初始化音效系统
  Future<void> initialize() async {
    try {
      _backgroundMusicPlayer = AudioPlayer();
      
      // 预创建音效播放器池
      for (int i = 0; i < 5; i++) {
        _soundEffectPlayers.add(AudioPlayer());
      }
      
      debugPrint('🎵 音效系统初始化完成');
    } catch (e) {
      debugPrint('🚨 音效系统初始化失败: $e');
    }
  }

  /// 🎶 播放背景音乐 - 使用音频合成
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    
    try {
      await _backgroundMusicPlayer.setVolume(_musicVolume);
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      
      debugPrint('🎵 播放背景音乐');
      // 注意：这里可以添加实际的音频文件
      // await _backgroundMusicPlayer.play(AssetSource('sounds/background_music.mp3'));
    } catch (e) {
      debugPrint('🚨 背景音乐播放失败: $e');
    }
  }

  /// 🔊 播放音效
  Future<void> playSoundEffect(SoundEffect effect) async {
    if (!_soundEnabled) return;

    try {
      debugPrint('🔊 播放音效: ${effect.toString()}');
      
      // 使用系统内置音效
      await _playSystemSound(effect);
      
      // 添加震动反馈 - 只使用系统HapticFeedback
      if (_vibrationEnabled) {
        await _addHapticFeedback(effect);
      }
    } catch (e) {
      debugPrint('🚨 音效播放失败: $e');
    }
  }

  /// 🎵 播放音效文件
  Future<void> _playSystemSound(SoundEffect effect) async {
    try {
      final player = _getAvailablePlayer();
      if (player != null) {
        await player.setVolume(_soundVolume);
        
        String soundFile;
        switch (effect) {
          case SoundEffect.tap:
            soundFile = 'sounds/tap.wav';
            break;
          case SoundEffect.match:
            soundFile = 'sounds/match.mp3';  // 使用下载的真实音效
            break;
          case SoundEffect.combo:
            soundFile = 'sounds/combo.wav';
            break;
          case SoundEffect.swap:
            soundFile = 'sounds/swap.wav';
            break;
          case SoundEffect.drop:
            soundFile = 'sounds/tap.wav';  // 复用点击音效
            break;
          case SoundEffect.levelUp:
            soundFile = 'sounds/combo.wav';  // 使用连击音效表示升级
            break;
          case SoundEffect.victory:
            soundFile = 'sounds/combo.wav';  // 使用连击音效表示胜利
            break;
          case SoundEffect.gameOver:
            soundFile = 'sounds/tap.wav';  // 使用低音调表示失败
            break;
          default:
            soundFile = 'sounds/tap.wav';
        }
        
        await player.play(AssetSource(soundFile));
        debugPrint('🎵 播放自定义音效: $soundFile');
      }
    } catch (e) {
      // 如果自定义音效失败，回退到系统音效
      debugPrint('⚠️ 自定义音效播放失败，使用系统音效: $e');
      
      switch (effect) {
        case SoundEffect.match:
        case SoundEffect.combo:
          await SystemSound.play(SystemSoundType.click);
          await Future.delayed(const Duration(milliseconds: 50));
          await SystemSound.play(SystemSoundType.click);
          break;
        case SoundEffect.levelUp:
        case SoundEffect.victory:
          await SystemSound.play(SystemSoundType.alert);
          break;
        default:
          await SystemSound.play(SystemSoundType.click);
      }
    }
  }

  /// 🎵 停止背景音乐
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
      debugPrint('🎵 停止背景音乐');
    } catch (e) {
      debugPrint('🚨 停止背景音乐失败: $e');
    }
  }

  /// 🔇 暂停所有音效
  Future<void> pauseAll() async {
    try {
      await _backgroundMusicPlayer.pause();
      for (final player in _soundEffectPlayers) {
        await player.pause();
      }
      debugPrint('🔇 暂停所有音效');
    } catch (e) {
      debugPrint('🚨 暂停音效失败: $e');
    }
  }

  /// 🔊 恢复所有音效
  Future<void> resumeAll() async {
    try {
      if (_musicEnabled) {
        await _backgroundMusicPlayer.resume();
        debugPrint('🔊 恢复音效');
      }
    } catch (e) {
      debugPrint('🚨 恢复音效失败: $e');
    }
  }

  /// ⚙️ 设置音效开关
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      for (final player in _soundEffectPlayers) {
        player.stop();
      }
    }
    debugPrint('🔊 音效${enabled ? '开启' : '关闭'}');
  }

  /// ⚙️ 设置音乐开关
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  /// ⚙️ 设置震动开关
  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    debugPrint('📳 震动${enabled ? '开启' : '关闭'}');
  }

  /// 🔊 设置音效音量
  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    debugPrint('🔊 音效音量: ${(_soundVolume * 100).toInt()}%');
  }

  /// 🎵 设置音乐音量
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _backgroundMusicPlayer.setVolume(_musicVolume);
    debugPrint('🎵 音乐音量: ${(_musicVolume * 100).toInt()}%');
  }

  /// 🎮 获取可用的音效播放器
  AudioPlayer? _getAvailablePlayer() {
    for (final player in _soundEffectPlayers) {
      if (player.state != PlayerState.playing) {
        return player;
      }
    }
    
    // 如果所有播放器都在使用，返回第一个（会覆盖正在播放的音效）
    return _soundEffectPlayers.isNotEmpty ? _soundEffectPlayers.first : null;
  }

  /// 📳 系统触觉反馈 - 使用Flutter内置功能
  Future<void> _addHapticFeedback(SoundEffect effect) async {
    if (!_vibrationEnabled) return;
    
    try {
      switch (effect) {
        case SoundEffect.tap:
          await HapticFeedback.lightImpact();
          break;
        case SoundEffect.match:
          await HapticFeedback.mediumImpact();
          break;
        case SoundEffect.combo:
          await HapticFeedback.heavyImpact();
          // 连击额外反馈
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
          break;
        case SoundEffect.victory:
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact();
          break;
        case SoundEffect.gameOver:
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 200));
          await HapticFeedback.mediumImpact();
          break;
        case SoundEffect.levelUp:
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
          break;
        case SoundEffect.swap:
          await HapticFeedback.selectionClick();
          break;
        case SoundEffect.drop:
          await HapticFeedback.lightImpact();
          break;
        default:
          await HapticFeedback.selectionClick();
      }
    } catch (e) {
      debugPrint('🚨 触觉反馈失败: $e');
    }
  }

  /// 🧹 清理资源
  Future<void> dispose() async {
    try {
      await _backgroundMusicPlayer.dispose();
      for (final player in _soundEffectPlayers) {
        await player.dispose();
      }
      _soundEffectPlayers.clear();
      debugPrint('🧹 清理音效资源');
    } catch (e) {
      debugPrint('🚨 清理音效资源失败: $e');
    }
  }
} 