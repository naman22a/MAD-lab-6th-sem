import 'package:flutter/material.dart';

enum BallType { normal, bonus, bomb }

class Ball {
  String id;
  Offset position;
  double radius;
  Color color;
  BallType type;
  double speedX;
  double speedY;
  bool isAlive;
  double opacity;

  Ball({
    required this.id,
    required this.position,
    required this.radius,
    required this.color,
    required this.type,
    required this.speedX,
    required this.speedY,
    this.isAlive = true,
    this.opacity = 1.0,
  });

  static Color colorForType(BallType type) {
    switch (type) {
      case BallType.normal:
        return const Color(0xFF00E5FF);
      case BallType.bonus:
        return const Color(0xFFFFD700);
      case BallType.bomb:
        return const Color(0xFFFF3D00);
    }
  }

  static int pointsForType(BallType type) {
    switch (type) {
      case BallType.normal:
        return 10;
      case BallType.bonus:
        return 30;
      case BallType.bomb:
        return -20;
    }
  }
}
