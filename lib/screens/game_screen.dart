import 'package:flutter/material.dart';
import 'dart:async';
import '../models/puzzle_game.dart';
import '../widgets/puzzle_grid.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final PuzzleType puzzleType;

  const GameScreen({
    super.key,
    required this.level,
    required this.puzzleType,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PuzzleGame _game;
  late Timer _timer;
  int _secondsElapsed = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _game = PuzzleGame(
      level: widget.level,
      type: widget.puzzleType,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _handleMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (_isPaused) return;

    setState(() {
      _game.makeMove(fromRow, fromCol, toRow, toCol);
      if (_game.isComplete) {
        _showVictoryDialog();
      }
    });
  }

  void _showVictoryDialog() {
    _togglePause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  Icons.star,
                  size: 40,
                  color: index < _game.calculateStars()
                      ? Colors.amber
                      : Colors.grey.shade300,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Score: ${_game.score}'),
            Text('Moves: ${_game.moves}'),
            Text('Time: ${_formatTime(_secondsElapsed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to level select
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _togglePause();
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quit Game?'),
            content: const Text('Are you sure you want to quit? Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('QUIT'),
              ),
            ],
          ),
        );
        if (!shouldPop!) {
          _togglePause();
        }
        return shouldPop;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildGameHeader(),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PuzzleGrid(
                        game: _game,
                        onMove: _handleMove,
                      ),
                    ),
                    if (_isPaused) _buildPauseOverlay(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Level ${widget.level}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text(_formatTime(_secondsElapsed)),
              const SizedBox(width: 16),
              Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text('${_game.moves}'),
              const SizedBox(width: 16),
              Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text('${_game.score}'),
            ],
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _togglePause,
              child: const Text('Resume'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _game = PuzzleGame(
                    level: widget.level,
                    type: widget.puzzleType,
                  );
                  _secondsElapsed = 0;
                  _togglePause();
                });
              },
              child: const Text('Restart Level'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quit to Menu'),
            ),
          ],
        ),
      ),
    );
  }
} 