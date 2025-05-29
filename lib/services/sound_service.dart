import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  late SharedPreferences _prefs;
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.5;
  double _effectsVolume = 1.0;

  // Singleton pattern
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    await _setupAudio();
  }

  Future<void> _loadSettings() async {
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
    _musicEnabled = _prefs.getBool(_musicEnabledKey) ?? true;
  }

  Future<void> _setupAudio() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _effectPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_musicEnabled) return;
    
    await _musicPlayer.stop();
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.setSource(AssetSource(assetPath));
    await _musicPlayer.resume();
  }

  Future<void> playSoundEffect(String assetPath) async {
    if (!_soundEnabled) return;
    
    await _effectPlayer.setVolume(_effectsVolume);
    await _effectPlayer.setSource(AssetSource(assetPath));
    await _effectPlayer.resume();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _prefs.setBool(_soundEnabledKey, _soundEnabled);
    
    if (!_soundEnabled) {
      await _effectPlayer.stop();
    }
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await _prefs.setBool(_musicEnabledKey, _musicEnabled);
    
    if (_musicEnabled) {
      await _musicPlayer.resume();
    } else {
      await _musicPlayer.pause();
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }

  Future<void> setEffectsVolume(double volume) async {
    _effectsVolume = volume.clamp(0.0, 1.0);
    await _effectPlayer.setVolume(_effectsVolume);
  }

  // Sound effect methods
  Future<void> playButtonClick() async {
    await playSoundEffect('audio/click.mp3');
  }

  Future<void> playMatchSound() async {
    await playSoundEffect('audio/match.mp3');
  }

  Future<void> playLevelComplete() async {
    await playSoundEffect('audio/level_complete.mp3');
  }

  Future<void> playStarEarned() async {
    await playSoundEffect('audio/star.mp3');
  }

  Future<void> playPowerUpActivated() async {
    await playSoundEffect('audio/power_up.mp3');
  }

  // Background music methods
  Future<void> playMenuMusic() async {
    await playBackgroundMusic('audio/menu_music.mp3');
  }

  Future<void> playGameMusic() async {
    await playBackgroundMusic('audio/game_music.mp3');
  }

  Future<void> playVictoryMusic() async {
    await playBackgroundMusic('audio/victory_music.mp3');
  }

  void dispose() {
    _musicPlayer.dispose();
    _effectPlayer.dispose();
  }

  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;
} 