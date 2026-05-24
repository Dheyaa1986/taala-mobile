import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_widget.dart';

import '../../../../../core/widgets/buttons/custom_button.dart';

Future showRateAppSheet(
    BuildContext context,
    ) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => RateAppSheet(),
  );
}

class RateAppSheet extends StatefulWidget {
  RateAppSheet({super.key});

  @override
  State<RateAppSheet> createState() => _RateAppSheetState();
}

class _RateAppSheetState extends State<RateAppSheet> {
  final _formKey = GlobalKey<FormState>();

  double rating = 0;
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: AppStrings.rateApp.tr()),
            24.height,
            Text(

              AppStrings.rateAppTitle.tr(),
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
                onRatingUpdate: (p0) {
                  setState(() {
                    rating = p0;
                  });
                },
              ),
            ),
            48.height,
            CustomTextField(
              hint: AppStrings.enterDescription.tr(),
              label: AppStrings.description.tr(),
              controller: descriptionController,
              maxLines: 5,
            ),
            40.height,
            CustomButton.filled(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  context.pop();
                }
              },
              text: AppStrings.submitRating.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
