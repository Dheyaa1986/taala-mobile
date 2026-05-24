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
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../custom_sheet.dart';

Future showEditProfileSheet(BuildContext context) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const EditProfileSheet(),
  );
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? _image;

  @override
  void initState() {
    nameController.text = 'john Doe';
    emailController.text = 'client@gmail.com';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsSheetHeader(title: AppStrings.editProfile.tr()),
          Form(
              key: formKey,
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.center,
                children: [
                  PhotoAvatar(
                   url: "https://media.istockphoto.com/id/1682296067/photo/happy-studio-portrait-or-professional-man-real-estate-agent-or-asian-businessman-smile-for.jpg?s=612x612&w=0&k=20&c=9zbG2-9fl741fbTWw5fNgcEEe4ll-JegrGlQQ6m54rg=",
                    size: 100.w,
                    isEditing: true,
                    onTap: () {
                      ImagePickerHelper().selectImage(context, (image) {
                        setState(() {
                          _image = image;
                        });
                      });
                    },
                    image: _image,
                  ),
                  16.height,
                  CustomTextField(
                    controller: nameController,
                    label: AppStrings.name.tr(),
                    hint: AppStrings.enterName.tr(),
                    validator: CustomValidators.validateEmpty,
                  ),
                  20.height,
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    label: AppStrings.email.tr(),
                    hint: AppStrings.enterEmail.tr(),
                    validator: CustomValidators.validateEmail,
                  ),
                  20.height,
                  SheetButtons(
                    title:  AppStrings.save.tr(),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
