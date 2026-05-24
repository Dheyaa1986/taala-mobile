import 'package:flutter/cupertino.dart';

class GradientTabIndicator extends Decoration {
  final Gradient gradient;
  final double radius;

  const GradientTabIndicator({required this.gradient, this.radius = 8.0});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientPainter(gradient: gradient, radius: radius);
  }
}

class _GradientPainter extends BoxPainter {
  final Gradient gradient;
  final double radius;

  _GradientPainter({required this.gradient, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          configuration.size!.width,
          configuration.size!.height,
        ),
      )
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromLTWH(
      offset.dx,
      0,
      configuration.size!.width,// Indicator height
      configuration.size!.height, // Adjust thickness here

    );

    final RRect roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(roundedRect, paint);
  }
}
