import 'package:flutter/material.dart';
import '../models/ball.dart';

class BallWidget extends StatelessWidget {
  final Ball ball;
  final VoidCallback onTap;

  const BallWidget({super.key, required this.ball, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ball.position.dx - ball.radius,
      top: ball.position.dy - ball.radius,
      child: Opacity(
        opacity: ball.opacity.clamp(0.0, 1.0),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedBallPainter(ball: ball),
        ),
      ),
    );
  }
}

class AnimatedBallPainter extends StatefulWidget {
  final Ball ball;
  const AnimatedBallPainter({super.key, required this.ball});

  @override
  State<AnimatedBallPainter> createState() => _AnimatedBallPainterState();
}

class _AnimatedBallPainterState extends State<AnimatedBallPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.ball.radius * 2;
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.ball.type == BallType.bonus
              ? _pulseAnimation.value
              : 1.0,
          child: CustomPaint(
            size: Size(size, size),
            painter: _BallPainter(ball: widget.ball),
          ),
        );
      },
    );
  }
}

class _BallPainter extends CustomPainter {
  final Ball ball;
  _BallPainter({required this.ball});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glow
    final glowPaint = Paint()
      ..color = ball.color.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius * 1.3, glowPaint);

    // Main ball gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 0.9,
      colors: [
        ball.color.withOpacity(0.95),
        ball.color,
        HSLColor.fromColor(ball.color)
            .withLightness(
              (HSLColor.fromColor(ball.color).lightness - 0.2).clamp(0.0, 1.0),
            )
            .toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final ballPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, ballPaint);

    // Specular highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.3),
      radius * 0.22,
      highlightPaint,
    );

    // Bomb icon
    if (ball.type == BallType.bomb) {
      final textPainter = TextPainter(
        text: const TextSpan(text: '💣', style: TextStyle(fontSize: 18)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(center.dx - 9, center.dy - 9));
    } else if (ball.type == BallType.bonus) {
      final textPainter = TextPainter(
        text: const TextSpan(text: '⭐', style: TextStyle(fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(center.dx - 8, center.dy - 8));
    }
  }

  @override
  bool shouldRepaint(_BallPainter old) => false;
}
