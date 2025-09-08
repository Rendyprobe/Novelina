import 'package:flutter/material.dart';

class NightSkyBackground extends StatelessWidget {
  const NightSkyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1A4B), Color(0xFF11256E), Color(0xFF0C1A3C)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -60, left: -40, child: _glow(220, const Color(0xFF2E5BFF).withOpacity(0.35))),
          Positioned(bottom: -80, right: -50, child: _glow(260, const Color(0xFF00E5FF).withOpacity(0.22))),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Container(
                height: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x53000000)],
                  ),
                ),
                child: CustomPaint(
                  painter: MosquePainter(color: Colors.black.withOpacity(0.30)),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: size / 2, spreadRadius: size / 5)],
        ),
      );
}

class MosquePainter extends CustomPainter {
  final Color color;
  const MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final baseH = size.height;

    final domeCenter = Offset(size.width * 0.5, baseH * 0.35);
    final domeR = baseH * 0.35;
    canvas.drawCircle(domeCenter, domeR, paint);

    final rect = Rect.fromLTWH(size.width * 0.15, baseH * 0.40, size.width * 0.70, baseH * 0.45);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)), paint);

    final towerW = size.width * 0.06;
    final towerH = baseH * 0.85;
    final left = Rect.fromLTWH(size.width * 0.08, baseH - towerH, towerW, towerH);
    final right = Rect.fromLTWH(size.width * 0.86, baseH - towerH, towerW, towerH);
    canvas.drawRRect(RRect.fromRectAndRadius(left, const Radius.circular(12)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(right, const Radius.circular(12)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}