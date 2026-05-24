import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/countries/presentation/widgets/countries_widget.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';

import '../../../../../core/widgets/buttons/custom_button.dart';

Future showLocationSheet(BuildContext context, {LocationModel? model}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => AddLocationSheet(
      model: model,
    ),
  );
}

class AddLocationSheet extends StatefulWidget {
  AddLocationSheet({super.key, this.model});
  LocationModel? model;

  @override
  State<AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<AddLocationSheet> {
  final _formKey = GlobalKey<FormState>();

  final linkController = TextEditingController();

  GovernanceModel? selectedGovernorate;

  CityModel? selectedCity;

  RegionModel? selectedRegion;

  List<GovernanceModel> governorates = [
    GovernanceModel(name: 'Cairo', id: 1),
    GovernanceModel(name: 'Giza', id: 2),
    GovernanceModel(name: 'Alexandria', id: 3),
    GovernanceModel(name: 'Aswan', id: 4),
    GovernanceModel(name: 'Luxor', id: 5),
  ];

  List<CityModel> cities = [
    CityModel(name: 'Nasr City', id: 101),
    CityModel(name: '6th of October', id: 102),
    CityModel(name: 'Smouha', id: 103),
    CityModel(name: 'Aswan City', id: 104),
    CityModel(name: 'East Luxor', id: 105),
  ];

  List<RegionModel> regions = [
    RegionModel(name: 'First District', id: 1001),
    RegionModel(name: 'Second District', id: 1002),
    RegionModel(name: 'Downtown', id: 1003),
    RegionModel(name: 'El Mahatta', id: 1004),
    RegionModel(name: 'Karnak Area', id: 1005),
  ];
  @override
  void initState() {
    if (widget.model != null) {
      selectedGovernorate = widget.model!.governance;
      selectedCity = widget.model!.city;
      selectedRegion = widget.model!.region;
    }
    super.initState();
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
                    : AppStrings.editLocation.tr()),
            24.height,
            CustomDropDownField<GovernanceModel?>(
              value: selectedGovernorate,
              label: AppStrings.governance.tr(),
              hint: AppStrings.governance.tr(),
              validator: CustomValidators.validateDropDown,
              onChanged: (p0) {
                setState(() {
                  selectedGovernorate = p0;
                  selectedCity = null;
                  selectedRegion = null;
                });
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
              onChanged: (p0) {
                setState(() {
                  selectedCity = p0;
                  selectedRegion = null;
                });
              },
              value: selectedCity,
              label: AppStrings.city.tr(),
              hint: AppStrings.city.tr(),
              validator: CustomValidators.validateDropDown,
              items: cities
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name ?? ''),
                      ))
                  .toList(),
            ),
            20.height,
            CustomDropDownField<RegionModel?>(
              onChanged: (p0) {
                setState(() {
                  selectedRegion = p0;
                });
              },
              value: selectedRegion,
              label: AppStrings.region.tr(),
              hint: AppStrings.region.tr(),
              validator: CustomValidators.validateDropDown,
              items: regions
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
                if (_formKey.currentState!.validate()) {
                  widget.model ??= LocationModel();
                  widget.model?.governance = selectedGovernorate;
                  widget.model?.city = selectedCity;
                  widget.model?.region = selectedRegion;
                  widget.model?.mapLink = linkController.text.trim();

                  context.pop(widget.model);
                }
              },
              text: widget.model == null
                  ? AppStrings.addLocation.tr()
                  : AppStrings.editLocation.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
