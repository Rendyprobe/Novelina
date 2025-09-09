import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarsBackground extends StatefulWidget {
  final int starCount;
  const StarsBackground({super.key, this.starCount = 50});

  @override
  State<StarsBackground> createState() => _StarsBackgroundState();
}

class _StarsBackgroundState extends State<StarsBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Star> stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _generateStars();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < widget.starCount; i++) {
      stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.8 + 0.2,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final star in stars) {
      final twinkle = (math.sin(animationValue * 2 * math.pi * star.twinkleSpeed) + 1) / 2;
      final opacity = star.opacity * twinkle;
      
      paint.color = Colors.white.withValues(alpha: opacity);
      
      final x = star.x * size.width;
      final y = star.y * size.height;
      
      // Draw star shape
      if (star.size > 2) {
        _drawStar(canvas, paint, Offset(x, y), star.size);
      } else {
        canvas.drawCircle(Offset(x, y), star.size / 2, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final double radius = size;
    final double innerRadius = radius * 0.4;
    
    for (int i = 0; i < 8; i++) {
      final double angle = (i * math.pi) / 4;
      final double currentRadius = i.isEven ? radius : innerRadius;
      final double x = center.dx + currentRadius * math.cos(angle - math.pi / 2);
      final double y = center.dy + currentRadius * math.sin(angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}