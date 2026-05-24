/*


import 'package:flutter/material.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';
import '../svg_image/svg_image_widget.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.active,
    required this.icon, required this.title,
  });

  final bool active;
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18).r,

      child: Column(
        children: [
          SvgImageWidget(
           image: icon,
            colorFilter:  ColorFilter.mode(active ? AppColors.primaryColor:Colors.white, BlendMode.srcIn),
          ),
          4.height,
          Text()
        ],
      ),
    );
  }
}
*/
