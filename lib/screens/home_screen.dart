import 'package:flutter/material.dart';
import '../models/puzzle_game.dart';
import 'game_screen.dart';
import 'social_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.grid_3x3),
                          text: PuzzleType.match3.name.toUpperCase(),
                        ),
                        Tab(
                          icon: const Icon(Icons.swap_horiz),
                          text: PuzzleType.sliding.name.toUpperCase(),
                        ),
                        Tab(
                          icon: const Icon(Icons.pattern),
                          text: PuzzleType.pattern.name.toUpperCase(),
                        ),
                        Tab(
                          icon: const Icon(Icons.memory),
                          text: PuzzleType.memory.name.toUpperCase(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildLevelGrid(context, PuzzleType.match3),
                          _buildLevelGrid(context, PuzzleType.sliding),
                          _buildLevelGrid(context, PuzzleType.pattern),
                          _buildLevelGrid(context, PuzzleType.memory),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Player',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // TODO: Navigate to shop
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Navigate to settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(BuildContext context, PuzzleType type) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 150,
      itemBuilder: (context, index) {
        final level = index + 1;
        final isLocked = level > 1; // For demo, only first level is unlocked

        return GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        level: level,
                        puzzleType: type,
                      ),
                    ),
                  );
                },
          child: Container(
            decoration: BoxDecoration(
              color: isLocked
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLocked ? Icons.lock : _getIconForType(type),
                  color: isLocked
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Level $level',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isLocked
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                if (!isLocked) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber.withOpacity(0.5),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(PuzzleType type) {
    switch (type) {
      case PuzzleType.match3:
        return Icons.grid_3x3;
      case PuzzleType.sliding:
        return Icons.swap_horiz;
      case PuzzleType.pattern:
        return Icons.pattern;
      case PuzzleType.memory:
        return Icons.memory;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 'Home', true),
          _buildNavItem(context, Icons.emoji_events, 'Achievements', false),
          _buildNavItem(context, Icons.leaderboard, 'Leaderboard', false),
          _buildNavItem(context, Icons.people, 'Friends', false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SocialScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
} 