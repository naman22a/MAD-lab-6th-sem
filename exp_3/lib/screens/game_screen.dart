import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../widgets/ball_widget.dart';
import '../widgets/hud_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _controller;
  late AnimationController _bgPulse;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _controller.addListener(_onGameUpdate);

    _bgPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  void _onGameUpdate() {
    if (_controller.state.status == GameStatus.gameOver) {
      _showGameOverDialog();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameUpdate);
    _controller.dispose();
    _bgPulse.dispose();
    super.dispose();
  }

  void _showGameOverDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GameOverDialog(
          score: _controller.state.score,
          highScore: _controller.state.highScore,
          level: _controller.state.level,
          onRestart: () {
            Navigator.pop(context);
            _controller.startGame();
          },
          onHome: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  void _showPauseDialog() {
    _controller.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PauseDialog(
        onResume: () {
          Navigator.pop(context);
          _controller.resumeGame();
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _controller.setGameSize(size);

          return AnimatedBuilder(
            animation: _bgPulse,
            builder: (context, child) {
              return Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.3 + _bgPulse.value * 0.6,
                      -0.5 + _bgPulse.value * 0.3,
                    ),
                    radius: 1.8,
                    colors: const [
                      Color(0xFF001525),
                      Color(0xFF000D18),
                      Color(0xFF000305),
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
                // Grid
                CustomPaint(
                  painter: _GameGridPainter(),
                  size: MediaQuery.of(context).size,
                ),

                // Start Prompt
                if (_controller.state.status == GameStatus.idle)
                  Center(
                    child: GestureDetector(
                      onTap: _controller.startGame,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app,
                            size: 64,
                            color: Color(0xFF00E5FF),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'TAP TO START',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap balls before they escape!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Balls
                ..._controller.balls.map(
                  (ball) => BallWidget(
                    key: ValueKey(ball.id),
                    ball: ball,
                    onTap: () => _controller.onTapBall(ball),
                  ),
                ),

                // Score popups
                ..._controller.popups.map(
                  (popup) => Positioned(
                    left: popup.x - 30,
                    top: popup.y,
                    child: Opacity(
                      opacity: popup.opacity.clamp(0.0, 1.0),
                      child: Text(
                        popup.text,
                        style: TextStyle(
                          color: popup.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: popup.color.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom danger zone line
                if (_controller.state.status == GameStatus.playing)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.redAccent.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // HUD
                if (_controller.state.status == GameStatus.playing ||
                    _controller.state.status == GameStatus.paused)
                  HudOverlay(
                    state: _controller.state,
                    onPause: _showPauseDialog,
                  ),

                // Combo
                if (_controller.state.status == GameStatus.playing)
                  ComboIndicator(combo: _controller.state.combo),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GameGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const step = 50.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GameGridPainter old) => false;
}

class _GameOverDialog extends StatelessWidget {
  final int score;
  final int highScore;
  final int level;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const _GameOverDialog({
    required this.score,
    required this.highScore,
    required this.level,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score >= highScore && score > 0;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF001525),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💥', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            if (isNewHighScore) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🏆 NEW HIGH SCORE!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _statRow('Score', '$score', const Color(0xFF00E5FF)),
            const SizedBox(height: 8),
            _statRow('Best', '$highScore', Colors.amber),
            const SizedBox(height: 8),
            _statRow('Level Reached', '$level', Colors.greenAccent),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _dialogButton('HOME', onHome, Colors.white24)),
                const SizedBox(width: 12),
                Expanded(
                  child: _dialogButton(
                    'PLAY AGAIN',
                    onRestart,
                    const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _dialogButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: color == Colors.white24 ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onHome;

  const _PauseDialog({required this.onResume, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF001525),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              size: 56,
              color: Color(0xFF00E5FF),
            ),
            const SizedBox(height: 12),
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onResume,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF0077FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'RESUME',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onHome,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'QUIT',
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
