import 'package:flutter/material.dart';
import 'package:taal/core/maps/map_style_config.dart';

/// Heading-up chevron similar to Waze's vehicle arrow.
class NavVehicleMarker extends StatelessWidget {
  const NavVehicleMarker({
    super.key,
    this.size = 44,
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
      ..moveTo(size.width * 0.5, size.height * 0.06)
      ..lineTo(size.width * 0.88, size.height * 0.86)
      ..lineTo(size.width * 0.5, size.height * 0.68)
      ..lineTo(size.width * 0.12, size.height * 0.86)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = MapStyleConfig.routeCasingColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
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
