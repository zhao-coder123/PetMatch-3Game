import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/enhanced_game_screen.dart';

void main() {
  runApp(const SimplePetMatchGame());
}

class SimplePetMatchGame extends StatelessWidget {
  const SimplePetMatchGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: '🐾 宠物消消乐',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const EnhancedGameScreen(),
        debugShowCheckedModeBanner: false,
        // 关闭溢出警告的视觉指示器
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}

 