import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/features/home/client/presentation/widgets/filter_status.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';

import '../../../../../core/options/pagination_options.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';

Future showFilterProvidersSheet(BuildContext context,
    {FilterProvidersModel? model}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => FilterProvidersSheet(
      model: model,
    ),
  );
}

class FilterProvidersSheet extends StatefulWidget {
  FilterProvidersSheet({super.key, this.model});
  FilterProvidersModel? model;

  @override
  State<FilterProvidersSheet> createState() => _FilterProvidersSheetState();
}

class _FilterProvidersSheetState extends State<FilterProvidersSheet> {
  final _repository = getIt<LocationsRepository>();

  List<ServiceTypeModel> serviceTypes = [];
  List<CountryModel> countries = [];
  List<GovernanceModel> governorates = [];
  List<CityModel> cities = [];

  CountryModel? selectedCountry;
  GovernanceModel? selectedGovernorate;
  CityModel? selectedCity;
  ServiceTypeModel? selectedServiceType;
  StatusType? selectedStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final typesResult = await _repository.getServiceTypes();
    final countriesResult = await _repository.getCountries();

    if (!mounted) return;

    typesResult.fold((_) => null, (data) => serviceTypes = data);
    countriesResult.fold((_) => null, (data) => countries = data);

    if (countries.isNotEmpty) {
      selectedCountry = countries.first;
      if (selectedCountry?.id != null) {
        await _loadGovernorates(selectedCountry!.id!);
      }
      if (widget.model?.governanceId != null) {
        for (final gov in governorates) {
          if (gov.id == widget.model?.governanceId) {
            selectedGovernorate = gov;
            break;
          }
        }
      }
      if (selectedGovernorate?.id != null) {
        await _loadCities(selectedGovernorate!.id!);
        for (final city in cities) {
          if (city.id == widget.model?.cityId) {
            selectedCity = city;
            break;
          }
        }
      }
    }

    if (widget.model?.serviceTypeId != null) {
      for (final type in serviceTypes) {
        if (type.id == widget.model?.serviceTypeId) {
          selectedServiceType = type;
          break;
        }
      }
    }

    if (widget.model?.active != null) {
      selectedStatus =
          widget.model?.active == true ? StatusType.active : StatusType.inactive;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadGovernorates(String countryId) async {
    final result = await _repository.getGovernorates(countryId);
    if (!mounted) return;
    result.fold((_) => null, (data) {
      setState(() {
        governorates = data;
      });
    });
  }

  Future<void> _loadCities(String governorateId) async {
    final result = await _repository.getCities(governorateId);
    if (!mounted) return;
    result.fold((_) => null, (data) {
      setState(() {
        cities = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SheetHeader(title: AppStrings.filter.tr()),
                24.height,
                CustomDropDownField(
                  value: selectedServiceType,
                  label: AppStrings.serviceType.tr(),
                  hint: AppStrings.serviceType.tr(),
                  onChanged: (value) {
                    setState(() => selectedServiceType = value);
                  },
                  items: serviceTypes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ),
                      )
                      .toList(),
                ),
                20.height,
                StatusSelectableChips(
                  options: StatusType.values,
                  selected: selectedStatus,
                  title: AppStrings.status,
                  onSelectionChanged: (value) {
                    setState(() => selectedStatus = value);
                  },
                ),
                20.height,
                CustomDropDownField(
                  value: selectedCountry,
                  label: AppStrings.governance.tr(),
                  hint: AppStrings.governance.tr(),
                  onChanged: (value) async {
                    setState(() {
                      selectedCountry = value;
                      selectedGovernorate = null;
                      selectedCity = null;
                      governorates = [];
                      cities = [];
                    });
                    if (value?.id != null) {
                      await _loadGovernorates(value!.id!);
                    }
                  },
                  items: countries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ),
                      )
                      .toList(),
                ),
                20.height,
                CustomDropDownField(
                  value: selectedGovernorate,
                  label: AppStrings.governance.tr(),
                  hint: AppStrings.governance.tr(),
                  onChanged: (value) async {
                    setState(() {
                      selectedGovernorate = value;
                      selectedCity = null;
                      cities = [];
                    });
                    if (value?.id != null) {
                      await _loadCities(value!.id!);
                    }
                  },
                  items: governorates
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ),
                      )
                      .toList(),
                ),
                20.height,
                CustomDropDownField(
                  value: selectedCity,
                  label: AppStrings.city.tr(),
                  hint: AppStrings.city.tr(),
                  onChanged: (value) {
                    setState(() => selectedCity = value);
                  },
                  items: cities
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ),
                      )
                      .toList(),
                ),
                24.height,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.filled(
                        width: 168.w,
                        onTap: () {
                          final filter = FilterProvidersModel(
                            serviceTypeId: selectedServiceType?.id,
                            active: selectedStatus == null
                                ? null
                                : selectedStatus == StatusType.active,
                            governanceId: selectedGovernorate?.id,
                            cityId: selectedCity?.id,
                          );
                          context.pop(filter);
                        },
                        text: AppStrings.apply.tr(),
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: CustomButton.outlined(
                        width: 168.w,
                        onTap: () {
                          context.pop(FilterProvidersModel());
                        },
                        text: AppStrings.reset.tr(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
