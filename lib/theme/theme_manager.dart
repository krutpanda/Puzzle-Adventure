import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

enum ThemeType {
  classic,
  dark,
  neon,
  pastel,
  seasonal
}

class ThemeManager with ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  late SharedPreferences _prefs;
  ThemeType _currentTheme = ThemeType.classic;
  bool _isDarkMode = false;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _currentTheme = ThemeType.values.firstWhere(
        (t) => t.toString() == savedTheme,
        orElse: () => ThemeType.classic,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(ThemeType theme) async {
    _currentTheme = theme;
    await _prefs.setString(_themeKey, theme.toString());
    notifyListeners();
  }

  ThemeType get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData getThemeData() {
    final baseTheme = _isDarkMode ? _darkBaseTheme : _lightBaseTheme;
    
    switch (_currentTheme) {
      case ThemeType.classic:
        return _applyClassicTheme(baseTheme);
      case ThemeType.dark:
        return _applyDarkTheme(baseTheme);
      case ThemeType.neon:
        return _applyNeonTheme(baseTheme);
      case ThemeType.pastel:
        return _applyPastelTheme(baseTheme);
      case ThemeType.seasonal:
        return _applySeasonalTheme(baseTheme);
    }
  }

  ThemeData get _lightBaseTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
  );

  ThemeData get _darkBaseTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
  );

  ThemeData _applyClassicTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: baseTheme.brightness,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData _applyDarkTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeData _applyNeonTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.greenAccent,
        brightness: Brightness.dark,
        primary: Colors.greenAccent,
        secondary: Colors.pinkAccent,
        tertiary: Colors.cyanAccent,
      ),
      cardTheme: CardTheme(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      shadowColor: Colors.greenAccent.withOpacity(0.3),
    );
  }

  ThemeData _applyPastelTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB5EAD7),
        brightness: baseTheme.brightness,
        primary: const Color(0xFFB5EAD7),
        secondary: const Color(0xFFFFB7B2),
        tertiary: const Color(0xFFFFDFD3),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  ThemeData _applySeasonalTheme(ThemeData baseTheme) {
    // Get current season and apply appropriate theme
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) {
      // Spring
      return _applySpringTheme(baseTheme);
    } else if (month >= 6 && month <= 8) {
      // Summer
      return _applySummerTheme(baseTheme);
    } else if (month >= 9 && month <= 11) {
      // Fall
      return _applyFallTheme(baseTheme);
    } else {
      // Winter
      return _applyWinterTheme(baseTheme);
    }
  }

  ThemeData _applySpringTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF98FB98), // Pale green
        brightness: baseTheme.brightness,
        primary: const Color(0xFF98FB98),
        secondary: const Color(0xFFFFB6C1), // Light pink
        tertiary: const Color(0xFFFFF68F), // Light yellow
      ),
    );
  }

  ThemeData _applySummerTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF87CEEB), // Sky blue
        brightness: baseTheme.brightness,
        primary: const Color(0xFF87CEEB),
        secondary: const Color(0xFFFFD700), // Gold
        tertiary: const Color(0xFFFF6B6B), // Coral
      ),
    );
  }

  ThemeData _applyFallTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD2691E), // Chocolate
        brightness: baseTheme.brightness,
        primary: const Color(0xFFD2691E),
        secondary: const Color(0xFFCD853F), // Peru
        tertiary: const Color(0xFFDEB887), // Burlywood
      ),
    );
  }

  ThemeData _applyWinterTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4682B4), // Steel blue
        brightness: baseTheme.brightness,
        primary: const Color(0xFF4682B4),
        secondary: const Color(0xFFB0C4DE), // Light steel blue
        tertiary: const Color(0xFFF0F8FF), // Alice blue
      ),
    );
  }
} 