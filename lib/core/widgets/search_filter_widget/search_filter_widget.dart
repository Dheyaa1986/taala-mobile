import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/chips/custom_selection_chip.dart';

import '../../../config/routes/routes.dart';

import '../../app_config/app_icons.dart';
import '../buttons/custom_icon_button.dart';
import '../chips/filter_chip.dart';
import '../fields/custom_search_field.dart';

class FilterArgs {



  FilterArgs copyWith(
      ) {
    return FilterArgs(

    );
  }
}

class SearchFilterWidget extends StatelessWidget {
  const SearchFilterWidget({
    super.key,
    this.searchHint,
    this.valueNotifier,
    required this.controller,
    this.onChanged,
    this.onFilterChanged,
    this.byUniversity,
    this.byCollage,
    this.bySkills,
    this.byLevel,
    this.collegeTitle,
    this.universityTitle,
    this.byLevelTitle,
  });
  final ValueNotifier<FilterArgs>? valueNotifier;
  final Function(FilterArgs?)? onFilterChanged;
  final String? searchHint;
  final TextEditingController controller;
  final Function(String?)? onChanged;

  final bool? byUniversity;
  final bool? byCollage;
  final bool? byLevel;
  final bool? bySkills;

  final String? universityTitle;
  final String? collegeTitle;
  final String? byLevelTitle;
  filter() {}
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: CustomSearchField(
              hint: searchHint,
              controller: controller,
              onChanged: onChanged,
            ),
          ),
          8.width,
          if (onFilterChanged != null && valueNotifier != null)
            CustomIconButton(
                bgColor: Theme.of(context).primaryColor,
                icon: AppIcons.filter,
                bgRadius: 8.r,
                padding: 13.r,
                shape: BoxShape.rectangle,
                onTap: () async {
                  FilterArgs value = valueNotifier!.value;

                  valueNotifier!.value = value;
                  onFilterChanged!(value);
                }),
        ]),
        ...[
          ValueListenableBuilder(
            valueListenable: valueNotifier!,
            builder: (context, value, child) {

                return Container();

            },
          ),
        ],
      ],
    );
  }
}
