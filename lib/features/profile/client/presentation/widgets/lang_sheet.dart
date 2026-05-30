import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/profile/client/presentation/widgets/sheet_buttons.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/validations/validators.dart';
import '../../../../../core/widgets/avatars/photo_avatar.dart';
import '../../../../../core/widgets/bottom_sheets/image_sheet.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_drop_down_field.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../home/provider/data/model/governate.dart';
import '../../../custom_sheet.dart';
enum AppLang {
  ar(title: AppStrings.arabic,code: 'ar' ),
  en(title: AppStrings.english,code: 'en' ),
  kr(title: AppStrings.kurdish,code: 'fa');
  final String code;
  final String title;

  const AppLang({required this.code, required this.title});
}
Future showLangSheet(BuildContext context) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const LangSheet(),
  );
}

class LangSheet extends StatefulWidget {
  const LangSheet({super.key});

  @override
  State<LangSheet> createState() => _LangSheetState();
}

class _LangSheetState extends State<LangSheet> {
  final formKey = GlobalKey<FormState>();
  AppLang? lang;

  @override
  void initState() {
    addPostFrameCallBack();
    super.initState();
  }
  addPostFrameCallBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        lang = AppLang.values.firstWhere((element) =>  element.code == context.locale.languageCode,);

      });
    });
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsSheetHeader(title: AppStrings.language.tr()),
          CustomDropDownField<AppLang?>(
            onChanged: (p0) {
              setState(() {

                lang = p0;
              });
            },
            value: lang,
            label: AppStrings.language.tr(),
            hint: AppStrings.language.tr(),
            validator: CustomValidators.validateDropDown,
            items: AppLang.values
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e.title.tr() ?? ''),
            ))
                .toList(),
          ),
          16.height,
          SheetButtons(
            title: AppStrings.confirm.tr(),
            onPressed: () {

              context.pop(lang);
            },
          ),
        ],
      ),
    );
  }
}
