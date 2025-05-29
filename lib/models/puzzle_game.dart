import 'dart:math';

enum PuzzleType {
  match3,
  sliding,
  pattern,
  memory
}

class PuzzleGame {
  final int level;
  final PuzzleType type;
  final int gridSize;
  int moves = 0;
  int score = 0;
  bool isComplete = false;
  List<List<int>> grid = [];
  
  PuzzleGame({
    required this.level,
    required this.type,
    this.gridSize = 6,
  }) {
    _initializeGrid();
  }

  void _initializeGrid() {
    final random = Random();
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => random.nextInt(6), // 6 different types of pieces
      ),
    );
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    // Check if the move is within bounds
    if (fromRow < 0 || fromRow >= gridSize ||
        fromCol < 0 || fromCol >= gridSize ||
        toRow < 0 || toRow >= gridSize ||
        toCol < 0 || toCol >= gridSize) {
      return false;
    }

    switch (type) {
      case PuzzleType.match3:
        // Allow only adjacent swaps
        return (fromRow == toRow && (fromCol - toCol).abs() == 1) ||
               (fromCol == toCol && (fromRow - toRow).abs() == 1);
      
      case PuzzleType.sliding:
        // Allow moves to empty space (represented by 0)
        return grid[toRow][toCol] == 0 &&
               ((fromRow == toRow && (fromCol - toCol).abs() == 1) ||
                (fromCol == toCol && (fromRow - toRow).abs() == 1));
      
      case PuzzleType.pattern:
        // Allow moves that complete the pattern
        // TODO: Implement pattern validation
        return true;
      
      case PuzzleType.memory:
        // Allow revealing two cards at a time
        // TODO: Implement memory game validation
        return true;
    }
  }

  void makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (!isValidMove(fromRow, fromCol, toRow, toCol)) {
      return;
    }

    // Swap pieces
    final temp = grid[fromRow][fromCol];
    grid[fromRow][fromCol] = grid[toRow][toCol];
    grid[toRow][toCol] = temp;

    moves++;
    _checkMatches();
    _checkCompletion();
  }

  void _checkMatches() {
    if (type != PuzzleType.match3) return;

    // Check horizontal matches
    for (var i = 0; i < gridSize; i++) {
      for (var j = 0; j < gridSize - 2; j++) {
        if (grid[i][j] != -1 &&
            grid[i][j] == grid[i][j + 1] &&
            grid[i][j] == grid[i][j + 2]) {
          // Mark matched pieces
          grid[i][j] = -1;
          grid[i][j + 1] = -1;
          grid[i][j + 2] = -1;
          score += 100;
        }
      }
    }

    // Check vertical matches
    for (var i = 0; i < gridSize - 2; i++) {
      for (var j = 0; j < gridSize; j++) {
        if (grid[i][j] != -1 &&
            grid[i][j] == grid[i + 1][j] &&
            grid[i][j] == grid[i + 2][j]) {
          // Mark matched pieces
          grid[i][j] = -1;
          grid[i + 1][j] = -1;
          grid[i + 2][j] = -1;
          score += 100;
        }
      }
    }

    // Replace matched pieces
    _fillEmptySpaces();
  }

  void _fillEmptySpaces() {
    final random = Random();

    // Move pieces down
    for (var j = 0; j < gridSize; j++) {
      var writeIndex = gridSize - 1;
      for (var i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j] != -1) {
          if (writeIndex != i) {
            grid[writeIndex][j] = grid[i][j];
            grid[i][j] = -1;
          }
          writeIndex--;
        }
      }
    }

    // Fill empty spaces with new pieces
    for (var i = 0; i < gridSize; i++) {
      for (var j = 0; j < gridSize; j++) {
        if (grid[i][j] == -1) {
          grid[i][j] = random.nextInt(6);
        }
      }
    }
  }

  void _checkCompletion() {
    switch (type) {
      case PuzzleType.match3:
        // Complete when reaching target score
        isComplete = score >= level * 1000;
        break;
      case PuzzleType.sliding:
        // Check if pieces are in order
        var expected = 0;
        for (var i = 0; i < gridSize; i++) {
          for (var j = 0; j < gridSize; j++) {
            if (grid[i][j] != expected++) {
              return;
            }
          }
        }
        isComplete = true;
        break;
      case PuzzleType.pattern:
        // TODO: Implement pattern completion check
        break;
      case PuzzleType.memory:
        // TODO: Implement memory game completion check
        break;
    }
  }

  int calculateStars() {
    if (!isComplete) return 0;
    
    // Calculate stars based on moves and score
    final maxMoves = level * 15;
    final maxScore = level * 1500;
    
    if (moves <= maxMoves * 0.6 && score >= maxScore) {
      return 3;
    } else if (moves <= maxMoves * 0.8 && score >= maxScore * 0.8) {
      return 2;
    } else {
      return 1;
    }
  }
} 