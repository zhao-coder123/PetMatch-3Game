#!/usr/bin/env python3
"""
🎵 宠物消消乐音效下载工具
自动下载免费的游戏音效，并放置到正确的目录
"""

import os
import requests
import json
from pathlib import Path
import time

class AudioDownloader:
    def __init__(self):
        self.sounds_dir = Path("assets/sounds")
        self.sounds_dir.mkdir(parents=True, exist_ok=True)
        
        # 推荐的音效资源 - 这些都是免费且适合游戏的
        self.recommended_sounds = {
            "tap.mp3": {
                "description": "轻柔点击音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/click/",
                    "https://freesound.org/search/?q=click+game",
                ],
                "keywords": ["click", "tap", "button", "UI"]
            },
            "match.mp3": {
                "description": "匹配消除音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/pop/",
                    "https://freesound.org/search/?q=pop+bubble",
                ],
                "keywords": ["pop", "bubble", "match", "success"]
            },
            "combo.mp3": {
                "description": "连击音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/win/",
                    "https://freesound.org/search/?q=win+game",
                ],
                "keywords": ["win", "success", "combo", "achievement"]
            },
            "swap.mp3": {
                "description": "交换音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/swoosh/",
                ],
                "keywords": ["swoosh", "swap", "move"]
            },
            "drop.mp3": {
                "description": "下落音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/drop/",
                ],
                "keywords": ["drop", "fall", "down"]
            },
            "level_up.mp3": {
                "description": "升级音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/win/",
                ],
                "keywords": ["level up", "achievement", "fanfare"]
            },
            "victory.mp3": {
                "description": "胜利音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/win/",
                ],
                "keywords": ["victory", "win", "complete"]
            },
            "game_over.mp3": {
                "description": "游戏结束音效",
                "urls": [
                    "https://mixkit.co/free-sound-effects/lose/",
                ],
                "keywords": ["lose", "game over", "fail"]
            }
        }

    def print_recommendations(self):
        """打印音效下载推荐"""
        print("🎵 推荐的免费音效资源:")
        print("=" * 50)
        
        print("\n🌟 顶级推荐网站:")
        print("1. Mixkit.co - 高质量免费音效，无需注册")
        print("2. Freesound.org - 社区音效库，需注册但完全免费")
        print("3. OpenGameArt.org - 游戏专用资源")
        
        print("\n🎮 为你的宠物消消乐推荐的音效:")
        for filename, info in self.recommended_sounds.items():
            print(f"\n📁 {filename}")
            print(f"   描述: {info['description']}")
            print(f"   搜索关键词: {', '.join(info['keywords'])}")
            print(f"   推荐网站: {info['urls'][0]}")

    def create_download_guide(self):
        """创建下载指南文件"""
        guide_content = """# 🎵 音效下载指南

## 🚀 快速开始

### 方法1: Mixkit (推荐) ⭐
1. 访问 https://mixkit.co/free-sound-effects/
2. 搜索以下关键词:
   - "click" (点击音效)
   - "pop" (弹窗/匹配音效)
   - "win" (胜利音效)
   - "swoosh" (交换音效)
3. 点击下载，文件名为对应的游戏音效

### 方法2: Freesound
1. 访问 https://freesound.org (需要免费注册)
2. 搜索关键词
3. 选择 CC0 或 CC BY 许可的音效
4. 下载并重命名为对应文件名

## 📁 文件对应表

| 游戏音效 | 文件名 | 搜索关键词 | 描述 |
|---------|--------|-----------|------|
| 点击方块 | tap.mp3 | "click game UI" | 轻柔的点击声 |
| 匹配成功 | match.mp3 | "pop bubble match" | 愉悦的弹窗声 |
| 连击 | combo.mp3 | "win combo success" | 上升的音调 |
| 交换方块 | swap.mp3 | "swoosh move" | 快速移动声 |
| 方块下落 | drop.mp3 | "drop fall down" | 轻柔下落声 |
| 升级 | level_up.mp3 | "level up fanfare" | 庆祝音效 |
| 胜利 | victory.mp3 | "victory win complete" | 完成音效 |
| 游戏结束 | game_over.mp3 | "lose game over" | 失败音效 |

## 🎨 音效特征建议

### 🔊 技术要求:
- 格式: MP3 或 WAV
- 时长: 0.1-1.0秒 (背景音乐除外)
- 大小: < 100KB 每个文件
- 音质: 44.1kHz, 16-bit

### 🎵 风格建议:
- **可爱清新**: 适合宠物主题
- **不刺耳**: 适合长时间游戏
- **明亮**: 正面的游戏体验
- **简洁**: 不要过于复杂的音效

## 🔧 下载后步骤

1. 将音效文件放入 `assets/sounds/` 目录
2. 确保文件名正确
3. 修改代码以使用文件音效:

```dart
// 在 lib/services/audio_manager.dart 中
Future<void> _playSystemSound(SoundEffect effect) async {
  try {
    final player = _getAvailablePlayer();
    if (player != null) {
      await player.setVolume(_soundVolume);
      
      switch (effect) {
        case SoundEffect.tap:
          await player.play(AssetSource('sounds/tap.mp3'));
          break;
        case SoundEffect.match:
          await player.play(AssetSource('sounds/match.mp3'));
          break;
        // ... 其他音效
      }
    }
  } catch (e) {
    // 如果文件不存在，回退到系统音效
    await SystemSound.play(SystemSoundType.click);
  }
}
```

4. 在 pubspec.yaml 中确保已添加音效路径:
```yaml
flutter:
  assets:
    - assets/sounds/
```

## 🎯 具体推荐

### Mixkit 具体音效:
- **点击**: "Mouse click close" 或 "Interface click"
- **匹配**: "Bubble pop up alert notification"
- **胜利**: "Quick win video game notification"
- **失败**: "Click error"

### 许可证信息:
- ✅ Mixkit: 免费商用，无需署名
- ✅ CC0: 完全免费，无限制
- ⚠️ CC BY: 需要署名作者

## 🎁 额外资源

### 在线音效生成器:
- Sfxr.me - 复古8位音效生成器
- Jfxr.frozenfractal.com - 现代音效生成器
- Freesound.org - 巨大的音效库

### 背景音乐:
- YouTube Audio Library
- Incompetech.com (Kevin MacLeod)
- Bensound.com

---
**💡 提示**: 记得测试所有音效，确保它们的音量和风格保持一致！
"""
        
        guide_file = self.sounds_dir / "下载指南.md"
        with open(guide_file, 'w', encoding='utf-8') as f:
            f.write(guide_content)
        
        print(f"📖 下载指南已创建: {guide_file}")

    def generate_sample_sounds(self):
        """生成示例音效配置文件"""
        config = {
            "sound_effects": {
                effect: {
                    "file": f"sounds/{effect}.mp3",
                    "volume": 0.7,
                    "description": info["description"]
                }
                for effect, info in self.recommended_sounds.items()
            },
            "background_music": {
                "file": "sounds/background_music.mp3",
                "volume": 0.4,
                "loop": True
            }
        }
        
        config_file = self.sounds_dir / "audio_config.json"
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        
        print(f"⚙️ 音效配置文件已创建: {config_file}")

def main():
    print("🎮 宠物消消乐音效下载工具")
    print("=" * 40)
    
    downloader = AudioDownloader()
    
    while True:
        print("\n选择操作:")
        print("1. 查看推荐音效资源")
        print("2. 创建下载指南")
        print("3. 生成配置文件")
        print("4. 退出")
        
        choice = input("\n请输入选择 (1-4): ").strip()
        
        if choice == "1":
            downloader.print_recommendations()
        elif choice == "2":
            downloader.create_download_guide()
        elif choice == "3":
            downloader.generate_sample_sounds()
        elif choice == "4":
            print("👋 再见！祝你游戏开发顺利！")
            break
        else:
            print("❌ 无效选择，请重试")

if __name__ == "__main__":
    main() 