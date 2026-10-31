import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/maps/widgets/place_category_3d_icon.dart';

class PlaceLogoAvatar extends StatelessWidget {
  const PlaceLogoAvatar({
    super.key,
    required this.icon,
    required this.color,
    this.imageUrl,
    this.size = 48,
  });

  final IconData icon;
  final Color color;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return PlaceCategory3dIcon(icon: icon, color: color, size: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeholder: (_, __) =>
              PlaceCategory3dIcon(icon: icon, color: color, size: size),
          errorWidget: (_, __, ___) =>
              PlaceCategory3dIcon(icon: icon, color: color, size: size),
        ),
      ),
    );
  }
}
