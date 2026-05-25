import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../core/countries/data/model/country_model.dart';
import '../../../../../core/countries/presentation/cubit/countries_cubit.dart';
import '../../../../../core/countries/presentation/widgets/countries_widget.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';

class PhoneField extends StatelessWidget {
  PhoneField({
    super.key,
    required TextEditingController phoneController,
    this.country,
  }) : _phoneController = phoneController;
  final TextEditingController _phoneController;
  CountryModel? country;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountriesCubit, CountriesState>(
      builder: (context, state) {
        country = state is CountriesLoaded ? state.country : null;
        return CustomTextField(
          prefix: country == null
              ? null
              : GestureDetector(
                  onTap: () {
                    showCountriesSheet(context, context.read<CountriesCubit>());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      16.width,
                      CircleAvatar(
                        foregroundImage:
                            CachedNetworkImageProvider(country!.flagPng),
                        radius: 16,
                      ),
                      8.width,
                      Text(
                        country?.code ?? '',
                        style: FontStyles.textStyle14,
                      ),
                      8.width,
                    ],
                  ),
                ),
          controller: _phoneController,
          label: AppStrings.phone.tr(),
          hint: AppStrings.enterPhone.tr(),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11)
          ],
          // 🎯 التعديل هنا: فحص الخانات بحيث لا تقل ولا تزيد عن 11 رقماً
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.enterPhone.tr();
            }
            if (value.length != 11) {
              return 'رقم الهاتف يجب أن يتكون من 11 رقماً';
            }
            return null;
          },
        );
      },
    );
  }
}
