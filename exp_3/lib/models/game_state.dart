enum GameStatus { idle, playing, paused, gameOver }

class GameState {
  final int score;
  final int highScore;
  final int lives;
  final int level;
  final GameStatus status;
  final int combo;

  const GameState({
    this.score = 0,
    this.highScore = 0,
    this.lives = 3,
    this.level = 1,
    this.status = GameStatus.idle,
    this.combo = 0,
  });

  GameState copyWith({
    int? score,
    int? highScore,
    int? lives,
    int? level,
    GameStatus? status,
    int? combo,
  }) {
    return GameState(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      lives: lives ?? this.lives,
      level: level ?? this.level,
      status: status ?? this.status,
      combo: combo ?? this.combo,
    );
  }

  // Level thresholds
  int get nextLevelScore => level * 100;

  // Speed multiplier increases with level
  double get speedMultiplier => 1.0 + (level - 1) * 0.25;

  // More balls spawn at higher levels
  int get maxBalls => 3 + (level - 1);

  // Bomb probability increases with level
  double get bombProbability => 0.1 + (level - 1) * 0.03;

  // Bonus ball probability
  double get bonusProbability => 0.15;
}
