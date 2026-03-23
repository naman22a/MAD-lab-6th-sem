import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _ballController;
  late Animation<double> _ballY;
  late Animation<double> _ballScale;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _ballY = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _ballController, curve: Curves.easeInOut),
    );
    _ballScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ballController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _ballController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  -0.5 + _bgController.value,
                  -0.5 + _bgController.value * 0.5,
                ),
                radius: 1.5,
                colors: const [
                  Color(0xFF001A2C),
                  Color(0xFF000D1A),
                  Color(0xFF000508),
                ],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Grid lines decoration
            CustomPaint(
              painter: _GridPainter(),
              size: MediaQuery.of(context).size,
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated ball
                  AnimatedBuilder(
                    animation: _ballController,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, _ballY.value),
                        child: Transform.scale(
                          scale: _ballScale.value,
                          child: _buildDecoBall(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'TAP THE\nBALL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'TAP • SCORE • SURVIVE',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 13,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Play button
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const GameScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 56,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF0077FF)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Text(
                        'PLAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Legend
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecoBall() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF80FFFF), Color(0xFF00E5FF), Color(0xFF0077AA)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('🔵', 'Normal', '+10'),
        const SizedBox(width: 24),
        _legendItem('⭐', 'Bonus', '+30'),
        const SizedBox(width: 24),
        _legendItem('💣', 'Bomb', '-20'),
      ],
    );
  }

  Widget _legendItem(String icon, String label, String pts) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        Text(
          pts,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
