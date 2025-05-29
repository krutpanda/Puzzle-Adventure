import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/tutorial_screen.dart';
import 'theme/modern_theme.dart';
import 'services/sound_service.dart';
import 'services/social_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize services
  await Future.wait([
    SoundService().initialize(),
    SocialService().initialize(),
  ]);

  runApp(const PuzzleAdventure());
}

class PuzzleAdventure extends StatelessWidget {
  const PuzzleAdventure({super.key});

  Future<bool> _isTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_complete') ?? false;
  }

  void _setTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_complete', true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Adventure',
      debugShowCheckedModeBanner: false,
      theme: ModernTheme.lightTheme,
      darkTheme: ModernTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: FutureBuilder<bool>(
        future: _isTutorialComplete(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink(); // Or a splash/loading widget
          }
          if (snapshot.data == false) {
            return TutorialScreen(
              onTutorialComplete: () {
                _setTutorialComplete();
                // Rebuild to show SplashScreen after tutorial
                (context as Element).reassemble();
              },
            );
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
