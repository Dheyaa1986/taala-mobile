import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';

Future showLocationSheet(BuildContext context, {LocationModel? model}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => AddLocationSheet(model: model),
  );
}

class AddLocationSheet extends StatefulWidget {
  const AddLocationSheet({super.key, this.model});
  final LocationModel? model;

  @override
  State<AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<AddLocationSheet> {
  final _formKey = GlobalKey<FormState>();
  final linkController = TextEditingController();
  final _repository = getIt<LocationsRepository>();

  List<CountryModel> countries = [];
  List<GovernanceModel> governorates = [];
  List<CityModel> cities = [];
  CountryModel? selectedCountry;
  GovernanceModel? selectedGovernorate;
  CityModel? selectedCity;
  bool _isLoadingGeo = true;

  @override
  void initState() {
    super.initState();
    if (widget.model?.mapLink != null) {
      linkController.text = widget.model!.mapLink!;
    }
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final result = await _repository.getCountries();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _isLoadingGeo = false),
      (data) {
        setState(() {
          countries = data;
          _isLoadingGeo = false;
        });
      },
    );
  }

  Future<void> _loadGovernorates(String countryId) async {
    final result = await _repository.getGovernorates(countryId);
    if (!mounted) return;
    result.fold((_) => null, (data) {
      setState(() {
        governorates = data;
        selectedGovernorate = null;
        selectedCity = null;
        cities = [];
      });
    });
  }

  Future<void> _loadCities(String governorateId) async {
    final result = await _repository.getCities(governorateId);
    if (!mounted) return;
    result.fold((_) => null, (data) {
      setState(() {
        cities = data;
        selectedCity = null;
      });
    });
  }

  @override
  void dispose() {
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: widget.model == null
                  ? AppStrings.addNewLocation.tr()
                  : AppStrings.editLocation.tr(),
            ),
            24.height,
            if (_isLoadingGeo)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else ...[
              CustomDropDownField<CountryModel?>(
                value: selectedCountry,
                label: AppStrings.governance.tr(),
                hint: AppStrings.governance.tr(),
                validator: CustomValidators.validateDropDown,
                onChanged: (value) {
                  setState(() => selectedCountry = value);
                  if (value?.id != null) _loadGovernorates(value!.id!);
                },
                items: countries
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ))
                    .toList(),
              ),
              20.height,
              CustomDropDownField<GovernanceModel?>(
                value: selectedGovernorate,
                label: AppStrings.governance.tr(),
                hint: AppStrings.governance.tr(),
                validator: CustomValidators.validateDropDown,
                onChanged: (value) {
                  setState(() => selectedGovernorate = value);
                  if (value?.id != null) _loadCities(value!.id!);
                },
                items: governorates
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ))
                    .toList(),
              ),
              20.height,
              CustomDropDownField<CityModel?>(
                value: selectedCity,
                label: AppStrings.city.tr(),
                hint: AppStrings.city.tr(),
                validator: CustomValidators.validateDropDown,
                onChanged: (value) => setState(() => selectedCity = value),
                items: cities
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name ?? ''),
                        ))
                    .toList(),
              ),
              20.height,
              CustomTextField(
                label: AppStrings.mapLink.tr(),
                hint: AppStrings.mapLink.tr(),
                validator: CustomValidators.isValidGoogleMapLink,
                controller: linkController,
              ),
              24.height,
              CustomButton.filled(
                width: 168.w,
                onTap: () {
                  if (!_formKey.currentState!.validate()) return;
                  final location = widget.model ?? LocationModel();
                  location.cityId = selectedCity?.id;
                  location.city = selectedCity;
                  location.governance = selectedGovernorate;
                  location.mapLink = linkController.text.trim();
                  context.pop(location);
                },
                text: widget.model == null
                    ? AppStrings.addLocation.tr()
                    : AppStrings.editLocation.tr(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
