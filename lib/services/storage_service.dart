import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyUserProfile = 'user_profile';
  static const String _keyGameSettings = 'game_settings';
  static const String _keyGameStats = 'game_stats';
  static const String _keyAchievements = 'achievements';
  static const String _keyThemeSettings = 'theme_settings';
  static const String _keyGameSaves = 'game_saves';

  late SharedPreferences _prefs;
  bool _initialized = false;

  // 初始化存储服务
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // 确保已初始化
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
  }

  // 用户资料相关
  Future<UserProfile> getUserProfile() async {
    _ensureInitialized();
    final data = _prefs.getString(_keyUserProfile);
    if (data != null) {
      return UserProfile.fromJson(jsonDecode(data));
    }
    return UserProfile.defaultProfile();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _ensureInitialized();
    await _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  // 游戏设置相关
  Future<GameSettings> getGameSettings() async {
    _ensureInitialized();
    final data = _prefs.getString(_keyGameSettings);
    if (data != null) {
      return GameSettings.fromJson(jsonDecode(data));
    }
    return GameSettings.defaultSettings();
  }

  Future<void> saveGameSettings(GameSettings settings) async {
    _ensureInitialized();
    await _prefs.setString(_keyGameSettings, jsonEncode(settings.toJson()));
  }

  // 游戏统计相关
  Future<GameStats> getGameStats() async {
    _ensureInitialized();
    final data = _prefs.getString(_keyGameStats);
    if (data != null) {
      return GameStats.fromJson(jsonDecode(data));
    }
    return GameStats.empty();
  }

  Future<void> saveGameStats(GameStats stats) async {
    _ensureInitialized();
    await _prefs.setString(_keyGameStats, jsonEncode(stats.toJson()));
  }

  // 成就相关
  Future<List<Achievement>> getAchievements() async {
    _ensureInitialized();
    final data = _prefs.getString(_keyAchievements);
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.map((item) => Achievement.fromJson(item)).toList();
    }
    return Achievement.defaultAchievements();
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    _ensureInitialized();
    final data = achievements.map((a) => a.toJson()).toList();
    await _prefs.setString(_keyAchievements, jsonEncode(data));
  }

  // 主题设置相关
  Future<ThemeSettings> getThemeSettings() async {
    _ensureInitialized();
    final data = _prefs.getString(_keyThemeSettings);
    if (data != null) {
      return ThemeSettings.fromJson(jsonDecode(data));
    }
    return ThemeSettings.defaultTheme();
  }

  Future<void> saveThemeSettings(ThemeSettings theme) async {
    _ensureInitialized();
    await _prefs.setString(_keyThemeSettings, jsonEncode(theme.toJson()));
  }

  // 游戏存档相关
  Future<GameSave?> getGameSave(String slotId) async {
    _ensureInitialized();
    final data = _prefs.getString('${_keyGameSaves}_$slotId');
    if (data != null) {
      return GameSave.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> saveGame(String slotId, GameSave save) async {
    _ensureInitialized();
    await _prefs.setString('${_keyGameSaves}_$slotId', jsonEncode(save.toJson()));
  }

  Future<List<String>> getGameSaveSlots() async {
    _ensureInitialized();
    return _prefs.getKeys()
        .where((key) => key.startsWith(_keyGameSaves))
        .map((key) => key.substring(_keyGameSaves.length + 1))
        .toList();
  }

  // 通用方法
  Future<void> clearAllData() async {
    _ensureInitialized();
    await _prefs.clear();
  }

  Future<void> exportData() async {
    _ensureInitialized();
    final allData = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      allData[key] = _prefs.get(key);
    }
    // TODO: 实现数据导出功能
  }
}

// 用户资料数据模型
class UserProfile {
  final String id;
  final String username;
  final String avatar;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int totalPlayTime; // 秒
  final String favoriteTheme;
  final List<String> unlockedAvatars;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatar,
    required this.createdAt,
    required this.lastLoginAt,
    required this.totalPlayTime,
    required this.favoriteTheme,
    required this.unlockedAvatars,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: '宠物大师',
      avatar: '🐱',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      totalPlayTime: 0,
      favoriteTheme: 'default',
      unlockedAvatars: ['🐱', '🐶', '🐰', '🦊'],
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      totalPlayTime: json['totalPlayTime'],
      favoriteTheme: json['favoriteTheme'],
      unlockedAvatars: List<String>.from(json['unlockedAvatars']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'totalPlayTime': totalPlayTime,
      'favoriteTheme': favoriteTheme,
      'unlockedAvatars': unlockedAvatars,
    };
  }

  UserProfile copyWith({
    String? username,
    String? avatar,
    DateTime? lastLoginAt,
    int? totalPlayTime,
    String? favoriteTheme,
    List<String>? unlockedAvatars,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      favoriteTheme: favoriteTheme ?? this.favoriteTheme,
      unlockedAvatars: unlockedAvatars ?? this.unlockedAvatars,
    );
  }
}

// 游戏设置数据模型
class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final double soundVolume;
  final double musicVolume;
  final String difficulty;
  final bool showAnimations;
  final bool showParticles;
  final int gridSize;

  GameSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    required this.soundVolume,
    required this.musicVolume,
    required this.difficulty,
    required this.showAnimations,
    required this.showParticles,
    required this.gridSize,
  });

  factory GameSettings.defaultSettings() {
    return GameSettings(
      soundEnabled: true,
      musicEnabled: true,
      vibrationEnabled: true,
      soundVolume: 0.8,
      musicVolume: 0.6,
      difficulty: 'normal',
      showAnimations: true,
      showParticles: true,
      gridSize: 8,
    );
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      soundEnabled: json['soundEnabled'],
      musicEnabled: json['musicEnabled'],
      vibrationEnabled: json['vibrationEnabled'],
      soundVolume: json['soundVolume'],
      musicVolume: json['musicVolume'],
      difficulty: json['difficulty'],
      showAnimations: json['showAnimations'],
      showParticles: json['showParticles'],
      gridSize: json['gridSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'vibrationEnabled': vibrationEnabled,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
      'difficulty': difficulty,
      'showAnimations': showAnimations,
      'showParticles': showParticles,
      'gridSize': gridSize,
    };
  }

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    double? soundVolume,
    double? musicVolume,
    String? difficulty,
    bool? showAnimations,
    bool? showParticles,
    int? gridSize,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      difficulty: difficulty ?? this.difficulty,
      showAnimations: showAnimations ?? this.showAnimations,
      showParticles: showParticles ?? this.showParticles,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}

// 游戏统计数据模型
class GameStats {
  final int totalGamesPlayed;
  final int totalScore;
  final int maxLevel;
  final int totalMatches;
  final int longestCombo;
  final int totalPlayTime; // 秒
  final DateTime lastPlayTime;
  final Map<String, int> dailyStats; // 日期 -> 游戏次数

  GameStats({
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.maxLevel,
    required this.totalMatches,
    required this.longestCombo,
    required this.totalPlayTime,
    required this.lastPlayTime,
    required this.dailyStats,
  });

  factory GameStats.empty() {
    return GameStats(
      totalGamesPlayed: 0,
      totalScore: 0,
      maxLevel: 1,
      totalMatches: 0,
      longestCombo: 0,
      totalPlayTime: 0,
      lastPlayTime: DateTime.now(),
      dailyStats: {},
    );
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalGamesPlayed: json['totalGamesPlayed'],
      totalScore: json['totalScore'],
      maxLevel: json['maxLevel'],
      totalMatches: json['totalMatches'],
      longestCombo: json['longestCombo'],
      totalPlayTime: json['totalPlayTime'],
      lastPlayTime: DateTime.parse(json['lastPlayTime']),
      dailyStats: Map<String, int>.from(json['dailyStats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'maxLevel': maxLevel,
      'totalMatches': totalMatches,
      'longestCombo': longestCombo,
      'totalPlayTime': totalPlayTime,
      'lastPlayTime': lastPlayTime.toIso8601String(),
      'dailyStats': dailyStats,
    };
  }

  GameStats copyWith({
    int? totalGamesPlayed,
    int? totalScore,
    int? maxLevel,
    int? totalMatches,
    int? longestCombo,
    int? totalPlayTime,
    DateTime? lastPlayTime,
    Map<String, int>? dailyStats,
  }) {
    return GameStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      maxLevel: maxLevel ?? this.maxLevel,
      totalMatches: totalMatches ?? this.totalMatches,
      longestCombo: longestCombo ?? this.longestCombo,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      lastPlayTime: lastPlayTime ?? this.lastPlayTime,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }
}

// 成就数据模型
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
    required this.progress,
    required this.target,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      unlocked: json['unlocked'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      progress: json['progress'],
      target: json['target'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  static List<Achievement> defaultAchievements() {
    return [
      Achievement(
        id: 'first_game',
        title: '新手上路',
        description: '完成第一局游戏',
        icon: '🎯',
        unlocked: false,
        progress: 0,
        target: 1,
      ),
      Achievement(
        id: 'combo_master',
        title: '连击高手',
        description: '达成5连击',
        icon: '🏆',
        unlocked: false,
        progress: 0,
        target: 5,
      ),
      Achievement(
        id: 'score_master',
        title: '分数大师',
        description: '单局得分达到10000',
        icon: '⭐',
        unlocked: false,
        progress: 0,
        target: 10000,
      ),
      Achievement(
        id: 'level_conqueror',
        title: '关卡征服者',
        description: '通过第10关',
        icon: '🚀',
        unlocked: false,
        progress: 0,
        target: 10,
      ),
      Achievement(
        id: 'legendary_player',
        title: '传奇玩家',
        description: '游戏100次',
        icon: '💎',
        unlocked: false,
        progress: 0,
        target: 100,
      ),
      Achievement(
        id: 'combo_maniac',
        title: '连击狂魔',
        description: '达成15连击',
        icon: '🔥',
        unlocked: false,
        progress: 0,
        target: 15,
      ),
    ];
  }

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target,
    );
  }
}

// 主题设置数据模型
class ThemeSettings {
  final String themeId;
  final String name;
  final List<String> colors;
  final String backgroundType;
  final bool particlesEnabled;

  ThemeSettings({
    required this.themeId,
    required this.name,
    required this.colors,
    required this.backgroundType,
    required this.particlesEnabled,
  });

  factory ThemeSettings.defaultTheme() {
    return ThemeSettings(
      themeId: 'default',
      name: '默认主题',
      colors: ['#FF69B4', '#9370DB', '#20B2AA'],
      backgroundType: 'gradient',
      particlesEnabled: true,
    );
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeId: json['themeId'],
      name: json['name'],
      colors: List<String>.from(json['colors']),
      backgroundType: json['backgroundType'],
      particlesEnabled: json['particlesEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeId': themeId,
      'name': name,
      'colors': colors,
      'backgroundType': backgroundType,
      'particlesEnabled': particlesEnabled,
    };
  }
}

// 游戏存档数据模型
class GameSave {
  final String id;
  final DateTime savedAt;
  final int level;
  final int score;
  final int moves;
  final List<List<String?>> grid; // 存储宠物类型的字符串表示
  final int currentProgress;
  final int maxProgress;

  GameSave({
    required this.id,
    required this.savedAt,
    required this.level,
    required this.score,
    required this.moves,
    required this.grid,
    required this.currentProgress,
    required this.maxProgress,
  });

  factory GameSave.fromJson(Map<String, dynamic> json) {
    return GameSave(
      id: json['id'],
      savedAt: DateTime.parse(json['savedAt']),
      level: json['level'],
      score: json['score'],
      moves: json['moves'],
      grid: (json['grid'] as List).map((row) => List<String?>.from(row)).toList(),
      currentProgress: json['currentProgress'],
      maxProgress: json['maxProgress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savedAt': savedAt.toIso8601String(),
      'level': level,
      'score': score,
      'moves': moves,
      'grid': grid,
      'currentProgress': currentProgress,
      'maxProgress': maxProgress,
    };
  }
} 