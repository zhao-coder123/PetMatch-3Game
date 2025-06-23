# 🚀 部署指南

本文档详细说明宠物消消乐·炫彩版项目在各个平台的部署方法和最佳实践。

## 📋 目录

- [环境准备](#环境准备)
- [平台部署](#平台部署)
- [构建优化](#构建优化)
- [发布流程](#发布流程)
- [CI/CD 配置](#cicd-配置)
- [故障排除](#故障排除)

---

## 🛠️ 环境准备

### 基础要求

| 工具 | 最低版本 | 推荐版本 | 说明 |
|------|---------|---------|------|
| Flutter | 3.5.0 | 3.16.0+ | 开发框架 |
| Dart | 3.0.0 | 3.2.0+ | 编程语言 |
| Android Studio | 4.1 | 2023.1+ | Android 开发 |
| Xcode | 13.0 | 15.0+ | iOS 开发（仅 macOS） |
| Node.js | 16.0 | 18.0+ | Web 部署 |

### 开发工具检查

```bash
# 检查 Flutter 环境
flutter doctor -v

# 检查可用设备
flutter devices

# 检查依赖状态
flutter pub deps
```

### 环境变量配置

```bash
# Windows (PowerShell)
$env:FLUTTER_ROOT = "C:\flutter"
$env:ANDROID_HOME = "C:\Android\Sdk"

# macOS/Linux (Bash/Zsh)
export FLUTTER_ROOT="/usr/local/flutter"
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$FLUTTER_ROOT/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
```

---

## 📱 平台部署

### Android 部署

#### 1. 开发构建

```bash
# 调试版本
flutter run -d android

# 生成调试 APK
flutter build apk --debug

# Profile 模式（性能分析）
flutter build apk --profile
```

#### 2. 发布构建

```bash
# 生成发布版 APK
flutter build apk --release

# 生成 Android App Bundle（推荐）
flutter build appbundle --release

# 分平台构建
flutter build apk --split-per-abi --release
```

#### 3. 签名配置

创建 `android/key.properties`：
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

修改 `android/app/build.gradle`：
```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 4. Google Play 发布

```bash
# 构建 AAB 文件
flutter build appbundle --release

# 上传到 Google Play Console
# 文件位置: build/app/outputs/bundle/release/app-release.aab
```

### iOS 部署

#### 1. 开发构建

```bash
# 模拟器运行
flutter run -d ios

# 真机调试
flutter run -d ios --release
```

#### 2. 发布构建

```bash
# 生成 iOS 应用
flutter build ios --release

# 生成 IPA 文件
flutter build ipa --release
```

#### 3. Xcode 配置

1. 打开 `ios/Runner.xcworkspace`
2. 配置 Signing & Capabilities
3. 设置 Bundle Identifier
4. 配置 Deployment Target (iOS 12.0+)

#### 4. App Store 发布

```bash
# 构建并上传到 App Store Connect
flutter build ipa --release

# 使用 Xcode 上传
# 或使用 Transporter 应用
```

### Web 部署

#### 1. 本地开发

```bash
# 启动 Web 服务
flutter run -d chrome

# 指定端口
flutter run -d web-server --web-port 8080
```

#### 2. 构建部署

```bash
# 构建 Web 应用
flutter build web --release

# 优化构建
flutter build web --release --web-renderer canvaskit

# 构建结果位置: build/web/
```

#### 3. 服务器部署

**Apache 配置**:
```apache
<Directory "/var/www/html/pet-game">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    
    # 支持 Flutter Web 路由
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
</Directory>
```

**Nginx 配置**:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/pet-game;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 4. CDN 部署

**部署到 Firebase Hosting**:
```bash
# 安装 Firebase CLI
npm install -g firebase-tools

# 登录
firebase login

# 初始化项目
firebase init hosting

# 部署
firebase deploy
```

**部署到 Netlify**:
```bash
# 直接拖拽 build/web 文件夹到 Netlify
# 或使用 Netlify CLI
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

### Windows 桌面部署

#### 1. 开发构建

```bash
# 运行 Windows 应用
flutter run -d windows

# 构建 Windows 应用
flutter build windows --release
```

#### 2. 安装包制作

使用 **Inno Setup** 创建安装程序：

```inno
[Setup]
AppName=宠物消消乐
AppVersion=1.0.0
DefaultDirName={pf}\PetMatchGame
DefaultGroupName=宠物消消乐
OutputDir=installer
OutputBaseFilename=PetMatchGame_Setup

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\宠物消消乐"; Filename: "{app}\flutter_application_1.exe"
Name: "{commondesktop}\宠物消消乐"; Filename: "{app}\flutter_application_1.exe"
```

### macOS 桌面部署

#### 1. 开发构建

```bash
# 运行 macOS 应用
flutter run -d macos

# 构建 macOS 应用
flutter build macos --release
```

#### 2. 应用签名和公证

```bash
# 签名应用
codesign --force --sign "Developer ID Application: Your Name" build/macos/Build/Products/Release/YourApp.app

# 创建 DMG
hdiutil create -volname "Pet Match Game" -srcfolder build/macos/Build/Products/Release/YourApp.app -ov -format UDZO YourApp.dmg

# 公证（如需 App Store 外分发）
xcrun notarytool submit YourApp.dmg --keychain-profile "AC_PASSWORD"
```

---

## ⚡ 构建优化

### 性能优化

#### 1. 代码优化

```bash
# 启用混淆
flutter build apk --release --obfuscate --split-debug-info=symbols

# Web 特定优化
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
```

#### 2. 资源优化

```bash
# 压缩图片资源
flutter packages pub run flutter_launcher_icons:main

# 生成不同密度的图标
flutter packages pub run flutter_native_splash:create
```

#### 3. 包大小优化

```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  
  # 只包含需要的资源
  assets:
    - assets/images/
  
  # 移除不必要的字体
  fonts: []
```

### 构建脚本

#### build.sh (macOS/Linux)

```bash
#!/bin/bash

echo "🚀 开始构建宠物消消乐"

# 清理
flutter clean
flutter pub get

# Android
echo "📱 构建 Android 版本..."
flutter build apk --release --split-per-abi
flutter build appbundle --release

# iOS (仅 macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 构建 iOS 版本..."
    flutter build ios --release
    flutter build ipa --release
fi

# Web
echo "🌐 构建 Web 版本..."
flutter build web --release --web-renderer canvaskit

# Windows (仅 Windows)
if [[ "$OSTYPE" == "msys" ]]; then
    echo "🪟 构建 Windows 版本..."
    flutter build windows --release
fi

echo "✅ 构建完成！"
```

#### build.bat (Windows)

```batch
@echo off
echo 🚀 开始构建宠物消消乐

REM 清理
flutter clean
flutter pub get

REM Android
echo 📱 构建 Android 版本...
flutter build apk --release --split-per-abi
flutter build appbundle --release

REM Web
echo 🌐 构建 Web 版本...
flutter build web --release --web-renderer canvaskit

REM Windows
echo 🪟 构建 Windows 版本...
flutter build windows --release

echo ✅ 构建完成！
pause
```

---

## 🔄 发布流程

### 版本管理

#### 1. 语义化版本控制

```yaml
# pubspec.yaml
version: 1.2.3+4
#         │ │ │ │
#         │ │ │ └─ Build number
#         │ │ └─── Patch version
#         │ └───── Minor version  
#         └─────── Major version
```

#### 2. 版本更新脚本

```bash
#!/bin/bash
# update_version.sh

VERSION=$1
BUILD=$2

if [ -z "$VERSION" ] || [ -z "$BUILD" ]; then
    echo "用法: ./update_version.sh <version> <build>"
    echo "示例: ./update_version.sh 1.2.3 4"
    exit 1
fi

# 更新 pubspec.yaml
sed -i "s/^version: .*/version: $VERSION+$BUILD/" pubspec.yaml

# 更新 CHANGELOG
echo "## [$VERSION] - $(date +%Y-%m-%d)" >> CHANGELOG.md.tmp
echo "" >> CHANGELOG.md.tmp
cat CHANGELOG.md >> CHANGELOG.md.tmp
mv CHANGELOG.md.tmp CHANGELOG.md

echo "✅ 版本已更新至 $VERSION+$BUILD"
```

### 发布检查清单

#### 预发布检查

- [ ] 所有测试通过 (`flutter test`)
- [ ] 代码分析无警告 (`flutter analyze`)
- [ ] 性能测试通过
- [ ] 各平台构建成功
- [ ] 版本号正确更新
- [ ] CHANGELOG 已更新
- [ ] 文档已同步更新

#### 发布步骤

1. **创建发布分支**
   ```bash
   git checkout -b release/v1.2.3
   git push origin release/v1.2.3
   ```

2. **构建所有平台**
   ```bash
   ./scripts/build.sh
   ```

3. **创建 Git 标签**
   ```bash
   git tag -a v1.2.3 -m "Release version 1.2.3"
   git push origin v1.2.3
   ```

4. **上传到各个平台**
   - Google Play Console (Android)
   - App Store Connect (iOS)
   - 部署 Web 版本
   - 发布桌面安装包

---

## 🔧 CI/CD 配置

### GitHub Actions

#### .github/workflows/build.yml

```yaml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run tests
      run: flutter test
      
    - name: Analyze code
      run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build APK
      run: flutter build apk --release
      
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build Web
      run: flutter build web --release
      
    - name: Deploy to GitHub Pages
      if: github.ref == 'refs/heads/main'
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build iOS
      run: flutter build ios --release --no-codesign
```

### GitLab CI

#### .gitlab-ci.yml

```yaml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.16.0"

before_script:
  - apt-get update && apt-get install -y curl git unzip
  - git clone https://github.com/flutter/flutter.git -b stable
  - export PATH="$PATH:`pwd`/flutter/bin"
  - flutter --version

test:
  stage: test
  script:
    - flutter pub get
    - flutter test
    - flutter analyze

build-android:
  stage: build
  script:
    - flutter pub get
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/
    expire_in: 1 week

build-web:
  stage: build
  script:
    - flutter pub get
    - flutter build web --release
  artifacts:
    paths:
      - build/web/
    expire_in: 1 week

deploy-web:
  stage: deploy
  script:
    - echo "部署到生产环境"
  environment:
    name: production
    url: https://your-domain.com
  only:
    - main
```

---

## 🐛 故障排除

### 常见问题

#### 1. Android 构建失败

**问题**: `Execution failed for task ':app:lintVitalRelease'`

**解决方案**:
```gradle
// android/app/build.gradle
android {
    lintOptions {
        disable 'InvalidPackage'
        checkReleaseBuilds false
    }
}
```

#### 2. iOS 构建失败

**问题**: `Podfile out of date`

**解决方案**:
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter build ios
```

#### 3. Web 构建失败

**问题**: `Cannot read property 'call' of undefined`

**解决方案**:
```bash
flutter clean
flutter pub get
flutter build web --web-renderer html
```

#### 4. 内存不足

**问题**: `OutOfMemoryError` during build

**解决方案**:
```gradle
// android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError
```

### 调试技巧

#### 1. 详细日志

```bash
# 启用详细日志
flutter build apk --release -v

# 查看构建性能
flutter build apk --release --analyze-size
```

#### 2. 分析包大小

```bash
# Android
flutter build apk --analyze-size --target-platform android-arm64

# iOS
flutter build ios --analyze-size
```

#### 3. 性能分析

```bash
# Profile 模式构建
flutter build apk --profile

# 启动性能监控
flutter run --profile --trace-startup
```

---

## 📚 最佳实践

### 1. 环境隔离

```bash
# 开发环境
flutter build apk --debug --dart-define=ENV=dev

# 测试环境  
flutter build apk --release --dart-define=ENV=test

# 生产环境
flutter build apk --release --dart-define=ENV=prod
```

### 2. 自动化部署

```bash
# 创建部署脚本
#!/bin/bash
ENVIRONMENT=$1
VERSION=$2

case $ENVIRONMENT in
  "dev")
    firebase deploy --project pet-game-dev
    ;;
  "prod")
    firebase deploy --project pet-game-prod
    ;;
esac
```

### 3. 监控和分析

```yaml
# pubspec.yaml
dependencies:
  firebase_analytics: ^10.0.0
  firebase_crashlytics: ^3.0.0
  sentry_flutter: ^7.0.0
```

---

## 🔗 相关资源

### 官方文档
- [Flutter 部署指南](https://docs.flutter.dev/deployment)
- [Android 发布指南](https://docs.flutter.dev/deployment/android)
- [iOS 发布指南](https://docs.flutter.dev/deployment/ios)
- [Web 部署指南](https://docs.flutter.dev/deployment/web)

### 工具和服务
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [GitHub Actions](https://github.com/features/actions)
- [Codemagic](https://codemagic.io/)
- [Bitrise](https://www.bitrise.io/)

---

*最后更新：2024年* 