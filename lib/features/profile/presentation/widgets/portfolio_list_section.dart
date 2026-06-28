import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/profile/data/models/portfolio_model.dart';
import 'package:taal/features/profile/presentation/widgets/portfolio_card.dart';

class PortfolioListSection extends StatelessWidget {
  const PortfolioListSection({
    super.key,
    required this.portfolios,
    this.horizontal = false,
    this.canDelete = false,
    this.onDelete,
  });

  final List<PortfolioModel> portfolios;
  final bool horizontal;
  final bool canDelete;
  final void Function(PortfolioModel portfolio)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (portfolios.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Text(
            AppStrings.portfolioEmpty.tr(),
            style: TextStyle(
              color: AppColors.greyTitle,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (horizontal) {
      return SizedBox(
        height: 239.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: portfolios.length,
          separatorBuilder: (_, __) => 8.width,
          itemBuilder: (_, index) => SizedBox(
            width: 280.w,
            child: PortfolioCard(
              portfolio: portfolios[index],
              canDelete: canDelete,
              onDelete: onDelete != null
                  ? () => onDelete!(portfolios[index])
                  : null,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < portfolios.length; i++) ...[
          if (i > 0) 8.height,
          PortfolioCard(
            portfolio: portfolios[i],
            canDelete: canDelete,
            onDelete:
                onDelete != null ? () => onDelete!(portfolios[i]) : null,
          ),
        ],
      ],
    );
  }
}
