import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ball.dart';
import '../models/game_state.dart';

class GameController extends ChangeNotifier {
  GameState _state = const GameState();
  final List<Ball> _balls = [];
  final List<ScorePopup> _popups = [];

  Timer? _gameLoop;
  Timer? _spawnTimer;
  final Random _random = Random();

  Size _gameSize = Size.zero;
  int _ballIdCounter = 0;

  GameState get state => _state;
  List<Ball> get balls => List.unmodifiable(_balls);
  List<ScorePopup> get popups => List.unmodifiable(_popups);

  void setGameSize(Size size) {
    _gameSize = size;
  }

  void startGame() {
    _state = GameState(
      highScore: _state.highScore,
      lives: 3,
      score: 0,
      level: 1,
      status: GameStatus.playing,
      combo: 0,
    );
    _balls.clear();
    _popups.clear();
    _startTimers();
    notifyListeners();
  }

  void pauseGame() {
    if (_state.status == GameStatus.playing) {
      _state = _state.copyWith(status: GameStatus.paused);
      _stopTimers();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state.status == GameStatus.paused) {
      _state = _state.copyWith(status: GameStatus.playing);
      _startTimers();
      notifyListeners();
    }
  }

  void _startTimers() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), _update);
    _scheduleNextSpawn();
  }

  void _stopTimers() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
  }

  void _scheduleNextSpawn() {
    if (_state.status != GameStatus.playing) return;
    final delay = max(400, 1200 - (_state.level - 1) * 100);
    _spawnTimer = Timer(Duration(milliseconds: delay), () {
      _spawnBall();
      _scheduleNextSpawn();
    });
  }

  void _spawnBall() {
    if (_gameSize == Size.zero) return;
    if (_balls.where((b) => b.isAlive).length >= _state.maxBalls) return;

    final rand = _random.nextDouble();
    BallType type;
    if (rand < _state.bombProbability) {
      type = BallType.bomb;
    } else if (rand < _state.bombProbability + _state.bonusProbability) {
      type = BallType.bonus;
    } else {
      type = BallType.normal;
    }

    final radius = type == BallType.bonus
        ? 20.0
        : (type == BallType.bomb ? 26.0 : 24.0);
    final margin = radius + 10;
    final x = margin + _random.nextDouble() * (_gameSize.width - margin * 2);
    final y =
        margin +
        _random.nextDouble() * (_gameSize.height * 0.7 - margin * 2) +
        _gameSize.height * 0.1;

    final speed = (1.5 + _random.nextDouble() * 1.5) * _state.speedMultiplier;
    final angle = _random.nextDouble() * 2 * pi;

    _balls.add(
      Ball(
        id: 'ball_${_ballIdCounter++}',
        position: Offset(x, y),
        radius: radius,
        color: Ball.colorForType(type),
        type: type,
        speedX: cos(angle) * speed,
        speedY: sin(angle) * speed,
      ),
    );
  }

  void _update(Timer timer) {
    if (_state.status != GameStatus.playing || _gameSize == Size.zero) return;

    bool stateChanged = false;

    // Move balls
    for (final ball in _balls) {
      if (!ball.isAlive) continue;

      ball.position = Offset(
        ball.position.dx + ball.speedX,
        ball.position.dy + ball.speedY,
      );

      // Bounce off walls
      if (ball.position.dx - ball.radius <= 0 ||
          ball.position.dx + ball.radius >= _gameSize.width) {
        ball.speedX *= -1;
        ball.position = Offset(
          ball.position.dx.clamp(ball.radius, _gameSize.width - ball.radius),
          ball.position.dy,
        );
      }

      // Bounce off top
      if (ball.position.dy - ball.radius <= 0) {
        ball.speedY *= -1;
        ball.position = Offset(ball.position.dx, ball.radius);
      }

      // Ball exits bottom — lose a life
      if (ball.position.dy - ball.radius > _gameSize.height &&
          ball.type != BallType.bomb) {
        ball.isAlive = false;
        stateChanged = true;
        final newLives = _state.lives - 1;
        final newCombo = 0;
        if (newLives <= 0) {
          _endGame();
          return;
        }
        _state = _state.copyWith(lives: newLives, combo: newCombo);
      } else if (ball.position.dy - ball.radius > _gameSize.height &&
          ball.type == BallType.bomb) {
        ball.isAlive = false;
        stateChanged = true;
      }
    }

    // Clean up dead balls
    _balls.removeWhere((b) => !b.isAlive && b.opacity <= 0);
    for (final ball in _balls.where((b) => !b.isAlive)) {
      ball.opacity = max(0, ball.opacity - 0.1);
    }

    // Clean up popups
    _popups.removeWhere((p) => p.opacity <= 0);
    for (final popup in _popups) {
      popup.opacity = max(0, popup.opacity - 0.04);
      popup.y -= 1.5;
    }

    if (stateChanged) notifyListeners();
    notifyListeners();
  }

  void onTapBall(Ball ball) {
    if (!ball.isAlive || _state.status != GameStatus.playing) return;

    ball.isAlive = false;

    int points = Ball.pointsForType(ball.type);
    int newCombo = ball.type == BallType.bomb ? 0 : _state.combo + 1;
    if (ball.type != BallType.bomb && newCombo > 1) {
      points = (points * (1 + (newCombo - 1) * 0.5)).round();
    }

    final newScore = max(0, _state.score + points);
    int newLives = _state.lives;
    if (ball.type == BallType.bomb) {
      newLives = max(0, newLives - 1);
      newCombo = 0;
    }

    final newHighScore = max(newScore, _state.highScore);
    int newLevel = _state.level;
    if (newScore >= _state.nextLevelScore && ball.type != BallType.bomb) {
      newLevel = _state.level + 1;
    }

    _popups.add(
      ScorePopup(
        text: points >= 0
            ? '+$points${newCombo > 1 ? ' x$newCombo' : ''}'
            : '$points',
        x: ball.position.dx,
        y: ball.position.dy,
        color: ball.type == BallType.bomb
            ? Colors.red
            : (points > 10 ? Colors.amber : Colors.greenAccent),
      ),
    );

    if (newLives <= 0) {
      _state = _state.copyWith(
        score: newScore,
        highScore: newHighScore,
        lives: 0,
      );
      _endGame();
      return;
    }

    _state = _state.copyWith(
      score: newScore,
      highScore: newHighScore,
      lives: newLives,
      level: newLevel,
      combo: newCombo,
    );
    notifyListeners();
  }

  void _endGame() {
    _stopTimers();
    _state = _state.copyWith(status: GameStatus.gameOver);
    _balls.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}

class ScorePopup {
  String text;
  double x;
  double y;
  Color color;
  double opacity;

  ScorePopup({
    required this.text,
    required this.x,
    required this.y,
    required this.color,
    this.opacity = 1.0,
  });
}
