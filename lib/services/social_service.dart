import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Friend {
  final String id;
  final String name;
  final String avatarUrl;
  final int level;
  final int score;
  final bool isOnline;
  final DateTime lastSeen;

  const Friend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.score,
    required this.isOnline,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'level': level,
    'score': score,
    'isOnline': isOnline,
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      level: json['level'] as int,
      score: json['score'] as int,
      isOnline: json['isOnline'] as bool,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }
}

class Guild {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final List<Friend> members;
  final int level;
  final int weeklyScore;

  const Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.members,
    required this.level,
    required this.weeklyScore,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconUrl': iconUrl,
    'members': members.map((m) => m.toJson()).toList(),
    'level': level,
    'weeklyScore': weeklyScore,
  };

  factory Guild.fromJson(Map<String, dynamic> json) {
    return Guild(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      members: (json['members'] as List)
          .map((m) => Friend.fromJson(m as Map<String, dynamic>))
          .toList(),
      level: json['level'] as int,
      weeklyScore: json['weeklyScore'] as int,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
    );
  }
}

class LiveChallenge {
  final String id;
  final String challengerId;
  final String challengedId;
  final int puzzleLevel;
  final DateTime startTime;
  final Duration duration;
  final Map<String, int> scores;

  const LiveChallenge({
    required this.id,
    required this.challengerId,
    required this.challengedId,
    required this.puzzleLevel,
    required this.startTime,
    required this.duration,
    required this.scores,
  });
}

class SocialService {
  static const String _friendsKey = 'friends_list';
  static const String _guildKey = 'guild_info';
  late SharedPreferences _prefs;
  
  final _friendsController = StreamController<List<Friend>>.broadcast();
  final _guildController = StreamController<Guild?>.broadcast();
  final _chatController = StreamController<List<ChatMessage>>.broadcast();
  final _challengeController = StreamController<LiveChallenge?>.broadcast();
  
  List<Friend> _friends = [];
  Guild? _currentGuild;
  List<ChatMessage> _chatHistory = [];
  LiveChallenge? _currentChallenge;

  // Singleton pattern
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFriends();
    await _loadGuild();
  }

  Stream<List<Friend>> get friendsStream => _friendsController.stream;
  Stream<Guild?> get guildStream => _guildController.stream;
  Stream<List<ChatMessage>> get chatStream => _chatController.stream;
  Stream<LiveChallenge?> get challengeStream => _challengeController.stream;

  Future<void> _loadFriends() async {
    final savedFriends = _prefs.getString(_friendsKey);
    if (savedFriends != null) {
      final List<dynamic> decoded = const JsonDecoder().convert(savedFriends);
      _friends = decoded
          .map((f) => Friend.fromJson(f as Map<String, dynamic>))
          .toList();
    }
    _friendsController.add(_friends);
  }

  Future<void> _loadGuild() async {
    final savedGuild = _prefs.getString(_guildKey);
    if (savedGuild != null) {
      _currentGuild = Guild.fromJson(
        const JsonDecoder().convert(savedGuild) as Map<String, dynamic>,
      );
    }
    _guildController.add(_currentGuild);
  }

  Future<void> saveFriends() async {
    await _prefs.setString(
      _friendsKey,
      const JsonEncoder().convert(_friends.map((f) => f.toJson()).toList()),
    );
  }

  Future<void> saveGuild() async {
    if (_currentGuild != null) {
      await _prefs.setString(
        _guildKey,
        const JsonEncoder().convert(_currentGuild!.toJson()),
      );
    }
  }

  Future<void> addFriend(Friend friend) async {
    if (!_friends.any((f) => f.id == friend.id)) {
      _friends.add(friend);
      _friendsController.add(_friends);
      await saveFriends();
    }
  }

  Future<void> removeFriend(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    _friendsController.add(_friends);
    await saveFriends();
  }

  Future<void> joinGuild(Guild guild) async {
    _currentGuild = guild;
    _guildController.add(_currentGuild);
    await saveGuild();
  }

  Future<void> leaveGuild() async {
    _currentGuild = null;
    _guildController.add(_currentGuild);
    await saveGuild();
  }

  void sendChatMessage(String content, String recipientId) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'currentUserId', // Replace with actual user ID
      content: content,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(message);
    _chatController.add(_chatHistory);
    // Here you would integrate with your chat backend
  }

  Future<void> startLiveChallenge(String challengedId, int puzzleLevel) async {
    _currentChallenge = LiveChallenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      challengerId: 'currentUserId', // Replace with actual user ID
      challengedId: challengedId,
      puzzleLevel: puzzleLevel,
      startTime: DateTime.now(),
      duration: const Duration(minutes: 5),
      scores: {},
    );
    _challengeController.add(_currentChallenge);
    // Here you would integrate with your multiplayer backend
  }

  void updateChallengeScore(String userId, int score) {
    if (_currentChallenge != null) {
      final updatedScores = Map<String, int>.from(_currentChallenge!.scores)
        ..[userId] = score;
      _currentChallenge = LiveChallenge(
        id: _currentChallenge!.id,
        challengerId: _currentChallenge!.challengerId,
        challengedId: _currentChallenge!.challengedId,
        puzzleLevel: _currentChallenge!.puzzleLevel,
        startTime: _currentChallenge!.startTime,
        duration: _currentChallenge!.duration,
        scores: updatedScores,
      );
      _challengeController.add(_currentChallenge);
    }
  }

  void endChallenge() {
    _currentChallenge = null;
    _challengeController.add(_currentChallenge);
  }

  void dispose() {
    _friendsController.close();
    _guildController.close();
    _chatController.close();
    _challengeController.close();
  }
} 