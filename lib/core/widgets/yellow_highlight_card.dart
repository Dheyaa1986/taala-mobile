import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../design_system/theme/taala_tokens.dart';
import '../../design_system/tokens/taala_shadows.dart';
import '../extensions/space_extension.dart';

/// Soft list/card surface used for orders, notifications, and highlights.
class YellowHighlightCard extends StatelessWidget {
  const YellowHighlightCard({
    super.key,
    required this.isHighlighted,
    required this.child,
    this.onTap,
    this.onDelete,
  });

  final bool isHighlighted;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    final card = Container(
      decoration: BoxDecoration(
        color: isHighlighted ? tokens.primarySoft : tokens.surface,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(
          color: isHighlighted ? tokens.primary : tokens.borderSubtle,
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: TaalaShadows.soft(brightness),
      ),
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
          if (onDelete != null) ...[
            8.width,
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: tokens.error,
                size: 22.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: card,
      ),
    );
  }
}
