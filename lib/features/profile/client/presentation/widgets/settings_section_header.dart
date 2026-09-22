import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../design_system/theme/taala_tokens.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Padding(
      padding: REdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Text(
        title.tr(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
