import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/enhanced_game_screen.dart';
import 'services/audio_manager.dart';

void main() async {
  // 彻底关闭调试模式
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化音效管理器
  await AudioManager().initialize();
  
  // 设置发布模式
  if (kDebugMode) {
    // 在debug模式下禁用所有溢出检查
    WidgetsApp.debugAllowBannerOverride = false;
  }
  
  // 设置状态栏透明
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  ));
  
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
        home: const EnhancedGameScreen(),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        checkerboardRasterCacheImages: false,
        checkerboardOffscreenLayers: false,
        showSemanticsDebugger: false,
        // 完全自定义的builder来控制所有调试信息
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: child!,
            ),
          );
        },
      ),
    );
  }
} 