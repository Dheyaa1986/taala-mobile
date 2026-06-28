import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_widget.dart';

import '../../../../../core/widgets/buttons/custom_button.dart';

Future showRateProviderSheet(
  BuildContext context, {
  required String providerId,
  required String providerName,
  VoidCallback? onRated,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => RateSheet(
      providerId: providerId,
      providerName: providerName,
      onRated: onRated,
    ),
  );
}

class RateSheet extends StatefulWidget {
  const RateSheet({
    super.key,
    required this.providerId,
    required this.providerName,
    this.onRated,
  });

  final String providerId;
  final String providerName;
  final VoidCallback? onRated;

  @override
  State<RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<RateSheet> {
  final _formKey = GlobalKey<FormState>();

  double rating = 0;
  final TextEditingController descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.ratingRequired.tr())),
      );
      return;
    }

    setState(() => _submitting = true);
    EasyLoading.show(status: AppStrings.loading.tr());
    final result = await getIt<ProfileRepository>().rateProvider(
      providerId: widget.providerId,
      value: rating,
      comment: descriptionController.text,
    );
    EasyLoading.dismiss();

    if (!mounted) return;
    setState(() => _submitting = false);

    final error = result.fold((e) => e.message, (_) => null);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    widget.onRated?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.ratingSubmitted.tr())),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: AppStrings.rateProvider.tr()),
            24.height,
            Text(
              widget.providerName,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            8.height,
            Text(
              AppStrings.rateProviderRating.tr(),
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            32.height,
            Center(
              child: ProviderRatingBar(
                rating: rating,
                allowHalfRating: true,
                itemSize: 24.sp,
                onRatingUpdate: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
            ),
            48.height,
            CustomTextField(
              hint: AppStrings.description.tr(),
              label: AppStrings.description.tr(),
              controller: descriptionController,
              maxLines: 5,
            ),
            40.height,
            CustomButton.filled(
              onTap: _submitting ? null : _submit,
              text: AppStrings.submitRating.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
