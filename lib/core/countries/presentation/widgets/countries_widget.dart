import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/app_strings.dart';
import '../../../../core/widgets/bottom_sheets/custom_bottom_sheet.dart';
import '../../../../core/widgets/fields/custom_text_field.dart';
import '../../data/model/country_model.dart';
import '../cubit/countries_cubit.dart';

showCountriesSheet(context, CountriesCubit cubit) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.hardEdge,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: const CustomBottomSheet(
          child: CountriesWidget(),
        ),
      );
    },
  );
}

class CountriesWidget extends StatefulWidget {
  const CountriesWidget({
    super.key,
  });

  @override
  State<CountriesWidget> createState() => _CountriesWidgetState();
}

class _CountriesWidgetState extends State<CountriesWidget> {
  List<CountryModel> _filteredList = [];
  List<CountryModel> countries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.removeListener(_searchListener);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    countries = context.read<CountriesCubit>().countries;
    _searchController.addListener(_searchListener);
    super.initState();
  }

  void _searchListener() {
    setState(() {
      _filteredList = List.from(countries.where((country) {
        if (_searchController.text.isEmpty) return true;
        return country.name
            .toLowerCase()
            .startsWith(_searchController.text.toLowerCase().trim());
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scrollbarTheme: const ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(AppColors.borderColor),
          trackColor: WidgetStatePropertyAll(Colors.black),
          radius: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
        child: Column(
          children: [
            20.height,
            CustomTextField(
              // label: '',
              hint: AppStrings.search.tr(),
              textStyle: Theme.of(context).textTheme.headlineSmall,
              controller: _searchController,
            ),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8,
                child: ListView.builder(
                  itemCount: _searchController.text.trim().isEmpty
                      ? countries.length
                      : _filteredList.length,
                  itemBuilder: (_, index) {
                    final CountryModel country =
                        _searchController.text.trim().isNotEmpty
                            ? _filteredList[index]
                            : countries[index];
                    return ListTile(
                      onTap: () {
                        context
                            .read<CountriesCubit>()
                            .selectCountry(country.code);
                        context.pop();
                      },
                      leading: CircleAvatar(
                        foregroundImage: CachedNetworkImageProvider(
                          country.flagPng,
                        ),
                        // radius: 32,
                      ),
                      title: Text(
                        country.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
