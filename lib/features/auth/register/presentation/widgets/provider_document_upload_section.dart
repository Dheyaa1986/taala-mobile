import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/document_image_picker.dart';
import 'package:taal/features/auth/register/utils/provider_registration_documents.dart';

class ProviderDocumentUploadSection extends StatelessWidget {
  const ProviderDocumentUploadSection({
    super.key,
    required this.requirements,
    required this.files,
    required this.onChanged,
  });

  final ProviderDocumentRequirements requirements;
  final ProviderRegistrationDocumentFiles files;
  final ValueChanged<ProviderRegistrationDocumentFiles> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.providerDocumentsHint.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.commentColor,
            height: 1.4,
          ),
        ),
        10.height,
        Container(
          width: double.infinity,
          padding: REdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            _requirementsSummary(requirements),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
              height: 1.4,
            ),
          ),
        ),
        16.height,
        if (requirements.nationalId) ...[
          _DocumentPairSection(
            title: AppStrings.nationalIdDocument.tr(),
            frontLabel: AppStrings.documentFront.tr(),
            backLabel: AppStrings.documentBack.tr(),
            frontFile: files.nationalIdFront,
            backFile: files.nationalIdBack,
            onPickFront: () => _pick(
              context,
              (file) => onChanged(files.copyWith(nationalIdFront: file)),
            ),
            onPickBack: () => _pick(
              context,
              (file) => onChanged(files.copyWith(nationalIdBack: file)),
            ),
            onRemoveFront: () =>
                onChanged(files.copyWith(nationalIdFront: null)),
            onRemoveBack: () =>
                onChanged(files.copyWith(nationalIdBack: null)),
          ),
          20.height,
        ],
        if (requirements.vehicleRegistration) ...[
          _DocumentPairSection(
            title: AppStrings.vehicleRegistrationDocument.tr(),
            frontLabel: AppStrings.documentFront.tr(),
            backLabel: AppStrings.documentBack.tr(),
            frontFile: files.vehicleRegFront,
            backFile: files.vehicleRegBack,
            onPickFront: () => _pick(
              context,
              (file) => onChanged(files.copyWith(vehicleRegFront: file)),
            ),
            onPickBack: () => _pick(
              context,
              (file) => onChanged(files.copyWith(vehicleRegBack: file)),
            ),
            onRemoveFront: () =>
                onChanged(files.copyWith(vehicleRegFront: null)),
            onRemoveBack: () =>
                onChanged(files.copyWith(vehicleRegBack: null)),
          ),
          20.height,
        ],
        if (requirements.residenceCard) ...[
          _DocumentPairSection(
            title: AppStrings.residenceCardDocument.tr(),
            frontLabel: AppStrings.documentFront.tr(),
            backLabel: AppStrings.documentBack.tr(),
            frontFile: files.residenceCardFront,
            backFile: files.residenceCardBack,
            onPickFront: () => _pick(
              context,
              (file) => onChanged(files.copyWith(residenceCardFront: file)),
            ),
            onPickBack: () => _pick(
              context,
              (file) => onChanged(files.copyWith(residenceCardBack: file)),
            ),
            onRemoveFront: () =>
                onChanged(files.copyWith(residenceCardFront: null)),
            onRemoveBack: () =>
                onChanged(files.copyWith(residenceCardBack: null)),
          ),
        ],
      ],
    );
  }

  String _requirementsSummary(ProviderDocumentRequirements requirements) {
    if (requirements.vehicleRegistration && requirements.residenceCard) {
      return AppStrings.providerDocumentsMixedSummary.tr();
    }
    if (requirements.vehicleRegistration) {
      return AppStrings.providerDocumentsTowingSummary.tr();
    }
    if (requirements.residenceCard) {
      return AppStrings.providerDocumentsNonTowingSummary.tr();
    }
    return AppStrings.providerDocumentsIncomplete.tr();
  }

  Future<void> _pick(
    BuildContext context,
    ValueChanged<File> onPicked,
  ) async {
    final file = await DocumentImagePicker.pickAndCrop(context);
    if (file != null) onPicked(file);
  }
}

class _DocumentPairSection extends StatelessWidget {
  const _DocumentPairSection({
    required this.title,
    required this.frontLabel,
    required this.backLabel,
    required this.frontFile,
    required this.backFile,
    required this.onPickFront,
    required this.onPickBack,
    required this.onRemoveFront,
    required this.onRemoveBack,
  });

  final String title;
  final String frontLabel;
  final String backLabel;
  final File? frontFile;
  final File? backFile;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;
  final VoidCallback onRemoveFront;
  final VoidCallback onRemoveBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        10.height,
        Row(
          children: [
            Expanded(
              child: _DocumentSlot(
                label: frontLabel,
                file: frontFile,
                onTap: onPickFront,
                onRemove: onRemoveFront,
              ),
            ),
            12.width,
            Expanded(
              child: _DocumentSlot(
                label: backLabel,
                file: backFile,
                onTap: onPickBack,
                onRemove: onRemoveBack,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocumentSlot extends StatelessWidget {
  const _DocumentSlot({
    required this.label,
    required this.file,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final File? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.commentColor,
          ),
        ),
        6.height,
        AspectRatio(
          aspectRatio: 4 / 3,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.greyBG,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: file != null
                      ? AppColors.primaryColor
                      : AppColors.greyBG,
                ),
              ),
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.primaryColor,
                          size: 28.r,
                        ),
                        6.height,
                        Padding(
                          padding: REdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            AppStrings.addDocumentPhoto.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.commentColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            file!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6.h,
                          right: 6.w,
                          child: Material(
                            color: Colors.black54,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onRemove,
                              child: Padding(
                                padding: REdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
