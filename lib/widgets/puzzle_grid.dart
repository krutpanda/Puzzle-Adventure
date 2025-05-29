import 'package:flutter/material.dart';
import '../models/puzzle_game.dart';

class PuzzleGrid extends StatefulWidget {
  final PuzzleGame game;
  final Function(int, int, int, int) onMove;

  const PuzzleGrid({
    super.key,
    required this.game,
    required this.onMove,
  });

  @override
  State<PuzzleGrid> createState() => _PuzzleGridState();
}

class _PuzzleGridState extends State<PuzzleGrid> {
  int? selectedRow;
  int? selectedCol;

  final List<Color> pieceColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  void _handleTap(int row, int col) {
    if (selectedRow == null || selectedCol == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else {
      // Try to make a move
      widget.onMove(selectedRow!, selectedCol!, row, col);
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = widget.game.gridSize;
        final pieceSize = constraints.maxWidth / gridSize;

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          child: Stack(
            children: [
              // Background grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  );
                },
              ),
              // Puzzle pieces
              ...List.generate(gridSize, (row) {
                return List.generate(gridSize, (col) {
                  final piece = widget.game.grid[row][col];
                  if (piece == -1) return const SizedBox.shrink();

                  return Positioned(
                    left: col * pieceSize,
                    top: row * pieceSize,
                    width: pieceSize,
                    height: pieceSize,
                    child: GestureDetector(
                      onTap: () => _handleTap(row, col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: piece < pieceColors.length
                              ? pieceColors[piece].withOpacity(0.8)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedRow == row && selectedCol == col
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: widget.game.type == PuzzleType.sliding
                              ? Text(
                                  piece.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              : Icon(
                                  _getIconForPiece(piece),
                                  color: Colors.white,
                                  size: pieceSize * 0.5,
                                ),
                        ),
                      ),
                    ),
                  );
                });
              }).expand((widgets) => widgets).toList(),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForPiece(int piece) {
    switch (piece) {
      case 0:
        return Icons.star;
      case 1:
        return Icons.favorite;
      case 2:
        return Icons.brightness_7;
      case 3:
        return Icons.emoji_emotions;
      case 4:
        return Icons.bolt;
      case 5:
        return Icons.local_florist;
      default:
        return Icons.help;
    }
  }
} 