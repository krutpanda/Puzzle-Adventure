import 'dart:async';
import 'package:shared_preferences.dart';

enum GameMode {
  classic,
  timeAttack,
  endless,
  puzzleRush,
  daily,
  seasonal
}

class PlayerProgress {
  final int level;
  final int stars;
  final int score;
  final Map<String, int> achievements;
  final List<GameMode> unlockedModes;

  PlayerProgress({
    required this.level,
    required this.stars,
    required this.score,
    required this.achievements,
    required this.unlockedModes,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'stars': stars,
    'score': score,
    'achievements': achievements,
    'unlockedModes': unlockedModes.map((m) => m.toString()).toList(),
  };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      level: json['level'] as int,
      stars: json['stars'] as int,
      score: json['score'] as int,
      achievements: Map<String, int>.from(json['achievements'] as Map),
      unlockedModes: (json['unlockedModes'] as List)
          .map((m) => GameMode.values.firstWhere(
                (mode) => mode.toString() == m,
                orElse: () => GameMode.classic,
              ))
          .toList(),
    );
  }
}

class GameService {
  static const String _progressKey = 'player_progress';
  static const String _settingsKey = 'game_settings';
  late SharedPreferences _prefs;
  final _progressController = StreamController<PlayerProgress>.broadcast();
  PlayerProgress? _currentProgress;

  // Singleton pattern
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
  }

  Stream<PlayerProgress> get progressStream => _progressController.stream;

  Future<void> _loadProgress() async {
    final savedProgress = _prefs.getString(_progressKey);
    if (savedProgress != null) {
      _currentProgress = PlayerProgress.fromJson(
        Map<String, dynamic>.from(
          // ignore: unnecessary_cast
          (const JsonDecoder().convert(savedProgress) as Map),
        ),
      );
    } else {
      _currentProgress = PlayerProgress(
        level: 1,
        stars: 0,
        score: 0,
        achievements: {},
        unlockedModes: [GameMode.classic],
      );
    }
    _progressController.add(_currentProgress!);
  }

  Future<void> saveProgress() async {
    if (_currentProgress != null) {
      await _prefs.setString(
        _progressKey,
        const JsonEncoder().convert(_currentProgress!.toJson()),
      );
    }
  }

  Future<void> updateProgress({
    int? level,
    int? stars,
    int? score,
    Map<String, int>? achievements,
    List<GameMode>? unlockedModes,
  }) async {
    if (_currentProgress == null) return;

    _currentProgress = PlayerProgress(
      level: level ?? _currentProgress!.level,
      stars: stars ?? _currentProgress!.stars,
      score: score ?? _currentProgress!.score,
      achievements: achievements ?? _currentProgress!.achievements,
      unlockedModes: unlockedModes ?? _currentProgress!.unlockedModes,
    );

    _progressController.add(_currentProgress!);
    await saveProgress();
  }

  bool isGameModeUnlocked(GameMode mode) {
    return _currentProgress?.unlockedModes.contains(mode) ?? false;
  }

  Future<void> unlockGameMode(GameMode mode) async {
    if (_currentProgress == null || isGameModeUnlocked(mode)) return;

    final updatedModes = List<GameMode>.from(_currentProgress!.unlockedModes)
      ..add(mode);
    await updateProgress(unlockedModes: updatedModes);
  }

  int getAchievementProgress(String achievementId) {
    return _currentProgress?.achievements[achievementId] ?? 0;
  }

  Future<void> updateAchievement(String achievementId, int progress) async {
    if (_currentProgress == null) return;

    final updatedAchievements = Map<String, int>.from(_currentProgress!.achievements)
      ..[achievementId] = progress;
    await updateProgress(achievements: updatedAchievements);
  }

  // Game mode specific methods
  Future<Map<String, dynamic>> startTimeAttack() async {
    // Initialize time attack mode settings
    return {
      'timeLimit': 60,
      'bonusTime': 5,
      'penaltyTime': 3,
      'minMatchScore': 100,
    };
  }

  Future<Map<String, dynamic>> startEndlessMode() async {
    // Initialize endless mode settings
    return {
      'difficultyMultiplier': 1.0,
      'comboMultiplier': 1.0,
      'powerUpProbability': 0.1,
    };
  }

  Future<Map<String, dynamic>> startPuzzleRush() async {
    // Initialize puzzle rush mode settings
    return {
      'duration': 180,
      'targetScore': 5000,
      'puzzlesPerRound': 10,
      'difficultyProgression': 1.2,
    };
  }

  Future<Map<String, dynamic>> getDailyChallenge() async {
    // Get today's challenge settings
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    return {
      'seed': seed,
      'puzzleType': GameMode.values[seed % GameMode.values.length],
      'targetScore': 1000 + (seed % 1000),
      'maxMoves': 20 + (seed % 10),
    };
  }

  Future<Map<String, dynamic>> getSeasonalEvent() async {
    // Get current seasonal event settings
    final now = DateTime.now();
    final season = (now.month % 12) ~/ 3;
    final themes = ['Spring', 'Summer', 'Fall', 'Winter'];
    return {
      'theme': themes[season],
      'duration': 14, // days
      'specialPowerUps': true,
      'bonusRewards': true,
    };
  }

  void dispose() {
    _progressController.close();
  }
} 