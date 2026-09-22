import 'package:flutter/material.dart';

import '../theme/taala_tokens.dart';

class TaalaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TaalaAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return AppBar(
      backgroundColor: tokens.background,
      foregroundColor: tokens.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      title: title == null
          ? null
          : Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
    );
  }
}
