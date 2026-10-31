import 'package:flutter/material.dart';

class PlaceCategory3dIcon extends StatelessWidget {
  const PlaceCategory3dIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 52,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final highlight = Color.lerp(color, Colors.white, 0.55)!;
    final shade = Color.lerp(color, Colors.black, 0.38)!;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [highlight, color, shade],
            stops: const [0, 0.42, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.42),
              blurRadius: size * 0.18,
              offset: Offset(0, size * 0.08),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.35),
              blurRadius: 1,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(-0.45, -0.48),
              child: Container(
                width: size * 0.38,
                height: size * 0.22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: Colors.white.withValues(alpha: 0.38),
                ),
              ),
            ),
            Icon(
              icon,
              color: Colors.white,
              size: size * 0.48,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
