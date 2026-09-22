import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

import '../../../../design_system/theme/taala_tokens.dart';
import '../../../../design_system/tokens/taala_shadows.dart';

enum UserRole {
  client,
  provider,
}

class RoleTile extends StatelessWidget {
  final UserRole role;
  final UserRole? value;
  final VoidCallback onTap;
  final String title, body, icon;
  const RoleTile({
    super.key,
    required this.role,
    required this.onTap,
    this.value,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final selected = role == value;
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.all(16).r,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? tokens.primarySoft : tokens.surface,
          borderRadius: BorderRadius.circular(20).r,
          border: Border.all(
            width: selected ? 1.5 : 1,
            color: selected ? tokens.primary : tokens.borderSubtle,
          ),
          boxShadow: selected ? TaalaShadows.soft(brightness) : null,
        ),
        child: Row(
          children: [
            Container(
              height: 56.h,
              width: 56.w,
              padding: const EdgeInsets.all(12).r,
              decoration: BoxDecoration(
                color: selected ? tokens.primary : tokens.surfaceMuted,
                borderRadius: BorderRadius.circular(14).r,
              ),
              child: SvgImageWidget(
                image: icon,
                colorFilter: selected
                    ? ColorFilter.mode(tokens.onPrimary, BlendMode.srcIn)
                    : null,
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  6.height,
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
