import 'package:flutter/material.dart';
import 'package:taal/core/maps/map_style_config.dart';

/// Heading-up chevron similar to Waze's vehicle arrow.
class NavVehicleMarker extends StatelessWidget {
  const NavVehicleMarker({
    super.key,
    this.size = 22,
    this.headingDegrees = 0,
  });

  final double size;
  final double headingDegrees;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: headingDegrees * 3.1415926535 / 180,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: NavVehicleChevronPainter(),
        ),
      ),
    );
  }
}

class NavVehicleChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.12)
      ..lineTo(size.width * 0.78, size.height * 0.84)
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.22, size.height * 0.84)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = MapStyleConfig.routeCasingColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = MapStyleConfig.routeColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
