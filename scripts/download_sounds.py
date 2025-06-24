#!/usr/bin/env python3
"""
🎵 自动下载免费游戏音效脚本
从公共资源库下载适合宠物消消乐的音效文件
"""

import os
import requests
import time
from pathlib import Path
import urllib.parse

class SoundDownloader:
    def __init__(self):
        self.sounds_dir = Path("assets/sounds")
        self.sounds_dir.mkdir(parents=True, exist_ok=True)
        
        # 免费音效资源 - 这些都是公共域或CC0许可的音效
        self.sound_urls = {
            "tap.mp3": [
                "https://www.soundjay.com/misc/sounds/button-4.mp3",
                "https://freesound.org/data/previews/316/316906_5123451-lq.mp3",
                "https://actions.google.com/sounds/v1/ui/ui_tap.ogg"
            ],
            "match.mp3": [
                "https://freesound.org/data/previews/320/320181_5260872-lq.mp3",
                "https://freesound.org/data/previews/260/260614_4486188-lq.mp3",
                "https://actions.google.com/sounds/v1/ui/notification_01.ogg"
            ],
            "combo.mp3": [
                "https://freesound.org/data/previews/341/341695_5858296-lq.mp3",
                "https://actions.google.com/sounds/v1/ui/positive_1.ogg",
                "https://freesound.org/data/previews/270/270324_3263906-lq.mp3"
            ],
            "swap.mp3": [
                "https://freesound.org/data/previews/254/254836_4404341-lq.mp3",
                "https://actions.google.com/sounds/v1/ui/ui_slide.ogg",
                "https://freesound.org/data/previews/244/244658_1038806-lq.mp3"
            ]
        }
        
        # 备用本地生成音效的参数
        self.tone_params = {
            "tap": {"freq": 800, "duration": 0.1},
            "match": {"freq": 600, "duration": 0.3},
            "combo": {"freq": 900, "duration": 0.5},
            "swap": {"freq": 500, "duration": 0.2}
        }

    def download_file(self, url, filename):
        """下载单个文件"""
        try:
            print(f"🔄 正在下载 {filename} 从 {url}")
            
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            file_path = self.sounds_dir / filename
            with open(file_path, 'wb') as f:
                f.write(response.content)
            
            print(f"✅ 成功下载: {filename} ({len(response.content)} bytes)")
            return True
            
        except Exception as e:
            print(f"❌ 下载失败 {filename}: {e}")
            return False

    def create_simple_tone(self, filename, freq, duration):
        """创建简单的音调文件"""
        try:
            print(f"🎵 生成音效: {filename}")
            
            # 创建简单的音效数据
            import wave
            import struct
            import math
            
            sample_rate = 44100
            samples = int(sample_rate * duration)
            
            # 生成正弦波
            audio_data = []
            for i in range(samples):
                # 添加淡入淡出效果
                fade_samples = int(sample_rate * 0.01)  # 10ms淡入淡出
                volume = 1.0
                if i < fade_samples:
                    volume = i / fade_samples
                elif i > samples - fade_samples:
                    volume = (samples - i) / fade_samples
                
                value = int(32767 * volume * math.sin(2 * math.pi * freq * i / sample_rate))
                audio_data.append(struct.pack('<h', value))
            
            # 保存为WAV文件
            wav_path = self.sounds_dir / filename.replace('.mp3', '.wav')
            with wave.open(str(wav_path), 'wb') as wav_file:
                wav_file.setnchannels(1)  # 单声道
                wav_file.setsampwidth(2)  # 16位
                wav_file.setframerate(sample_rate)
                wav_file.writeframes(b''.join(audio_data))
            
            print(f"✅ 生成成功: {filename.replace('.mp3', '.wav')}")
            return True
            
        except Exception as e:
            print(f"❌ 生成失败 {filename}: {e}")
            return False

    def download_from_public_apis(self):
        """从公共API下载音效"""
        print("🌐 尝试从公共API下载音效...")
        
        # Google Actions音效 (公共使用)
        google_sounds = {
            "tap.ogg": "https://actions.google.com/sounds/v1/ui/ui_tap.ogg",
            "match.ogg": "https://actions.google.com/sounds/v1/ui/notification_01.ogg", 
            "combo.ogg": "https://actions.google.com/sounds/v1/ui/positive_1.ogg",
            "swap.ogg": "https://actions.google.com/sounds/v1/ui/ui_slide.ogg"
        }
        
        success_count = 0
        for filename, url in google_sounds.items():
            if self.download_file(url, filename):
                success_count += 1
            time.sleep(0.5)  # 避免请求过快
        
        return success_count

    def create_backup_sounds(self):
        """创建备用音效文件"""
        print("🎵 生成备用音效文件...")
        
        success_count = 0
        for sound_name, params in self.tone_params.items():
            filename = f"{sound_name}.mp3"
            if self.create_simple_tone(filename, params["freq"], params["duration"]):
                success_count += 1
        
        return success_count

    def download_from_freesound_previews(self):
        """从Freesound预览下载（这些是公开的预览文件）"""
        print("🔊 从Freesound预览下载音效...")
        
        # 这些是Freesound的公开预览文件，通常较短但足够游戏使用
        freesound_previews = {
            "click.mp3": "https://freesound.org/data/previews/316/316906_5123451-lq.mp3",
            "pop.mp3": "https://freesound.org/data/previews/260/260614_4486188-lq.mp3",
            "success.mp3": "https://freesound.org/data/previews/270/270324_3263906-lq.mp3",
            "whoosh.mp3": "https://freesound.org/data/previews/244/244658_1038806-lq.mp3"
        }
        
        success_count = 0
        for filename, url in freesound_previews.items():
            if self.download_file(url, filename):
                success_count += 1
            time.sleep(1)  # 尊重服务器
        
        return success_count

    def convert_and_rename_files(self):
        """转换和重命名下载的文件"""
        print("🔄 整理和重命名音效文件...")
        
        # 文件映射
        file_mapping = {
            "ui_tap.ogg": "tap.ogg",
            "notification_01.ogg": "match.ogg", 
            "positive_1.ogg": "combo.ogg",
            "ui_slide.ogg": "swap.ogg",
            "click.mp3": "tap.mp3",
            "pop.mp3": "match.mp3",
            "success.mp3": "combo.mp3",
            "whoosh.mp3": "swap.mp3"
        }
        
        for old_name, new_name in file_mapping.items():
            old_path = self.sounds_dir / old_name
            new_path = self.sounds_dir / new_name
            
            if old_path.exists():
                if new_path.exists():
                    old_path.unlink()  # 删除旧文件
                    print(f"🔄 {new_name} 已存在，删除重复文件")
                else:
                    old_path.rename(new_path)
                    print(f"📝 重命名: {old_name} → {new_name}")

    def verify_downloads(self):
        """验证下载的文件"""
        print("\n📋 验证下载结果:")
        
        required_files = ["tap", "match", "combo", "swap"]
        found_files = []
        
        for sound_name in required_files:
            # 检查多种格式
            for ext in ['.mp3', '.ogg', '.wav']:
                file_path = self.sounds_dir / f"{sound_name}{ext}"
                if file_path.exists():
                    size_kb = file_path.stat().st_size / 1024
                    print(f"✅ {sound_name}{ext} - {size_kb:.1f}KB")
                    found_files.append(sound_name)
                    break
        
        missing_files = set(required_files) - set(found_files)
        if missing_files:
            print(f"⚠️ 缺失文件: {', '.join(missing_files)}")
        else:
            print("🎉 所有音效文件都已准备好！")
        
        return len(found_files), len(missing_files)

    def run(self):
        """运行下载流程"""
        print("🎮 开始下载宠物消消乐音效文件")
        print("=" * 50)
        
        total_success = 0
        
        # 方法1: Google Actions音效
        try:
            success = self.download_from_public_apis()
            total_success += success
            print(f"Google Actions音效: {success} 个成功")
        except Exception as e:
            print(f"Google Actions下载失败: {e}")
        
        time.sleep(1)
        
        # 方法2: Freesound预览
        try:
            success = self.download_from_freesound_previews()
            total_success += success
            print(f"Freesound预览: {success} 个成功")
        except Exception as e:
            print(f"Freesound下载失败: {e}")
        
        # 整理文件
        self.convert_and_rename_files()
        
        # 验证结果
        found, missing = self.verify_downloads()
        
        # 如果缺少文件，生成备用音效
        if missing > 0:
            print(f"\n🎵 为 {missing} 个缺失文件生成备用音效...")
            backup_success = self.create_backup_sounds()
            total_success += backup_success
        
        print(f"\n🎯 下载完成! 总共获得 {total_success} 个音效文件")
        print(f"📁 文件位置: {self.sounds_dir.absolute()}")
        
        return total_success

def main():
    downloader = SoundDownloader()
    try:
        success_count = downloader.run()
        if success_count > 0:
            print("\n🎵 接下来你可以:")
            print("1. 检查 assets/sounds/ 目录中的音效文件")
            print("2. 在游戏中测试音效")
            print("3. 根据需要调整音效音量")
        else:
            print("\n❌ 下载失败，请检查网络连接或手动下载")
    except KeyboardInterrupt:
        print("\n⏹️ 用户取消下载")
    except Exception as e:
        print(f"\n💥 下载过程出错: {e}")

if __name__ == "__main__":
    main() 