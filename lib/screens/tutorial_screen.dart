import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onTutorialComplete;
  const TutorialScreen({Key? key, required this.onTutorialComplete})
      : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 0;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      title: 'Matching',
      description:
          'Match similar items to score points. Try tapping two matching tiles!',
      child: Placeholder(fallbackHeight: 120),
    ),
    _TutorialStep(
      title: 'Sliding',
      description: 'Slide tiles to rearrange them. Try sliding a tile!',
      child: Placeholder(fallbackHeight: 120),
    ),
    _TutorialStep(
      title: 'Pattern',
      description: 'Follow the pattern shown to solve the puzzle.',
      child: Placeholder(fallbackHeight: 120),
    ),
    _TutorialStep(
      title: 'Memory',
      description: 'Remember the positions and match pairs from memory.',
      child: Placeholder(fallbackHeight: 120),
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onTutorialComplete();
    }
  }

  void _skipTutorial() {
    widget.onTutorialComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        actions: [
          TextButton(
            onPressed: _skipTutorial,
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(step.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(step.description, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            step.child,
            const Spacer(),
            ElevatedButton(
              onPressed: _nextStep,
              child:
                  Text(_currentStep == _steps.length - 1 ? 'Finish' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String title;
  final String description;
  final Widget child;
  const _TutorialStep(
      {required this.title, required this.description, required this.child});
}
