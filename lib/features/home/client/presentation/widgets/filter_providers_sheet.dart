import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/features/home/client/presentation/widgets/filter_status.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';

import '../../../../../core/options/pagination_options.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../data/model/service_provider_model/service_type_model.dart';

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
  final linkController = TextEditingController();

  GovernanceModel? selectedGovernorate;
  final _selectedCityKey =  GlobalKey<FormFieldState>();
  final _selectedRegionKey =  GlobalKey<FormFieldState>();
  final _selectedGovernorateKey =  GlobalKey<FormFieldState>();
  final _selectedServiceTypeKey =  GlobalKey<FormFieldState>();
  CityModel? selectedCity;

  RegionModel? selectedRegion;
  ServiceTypeModel? selectedServiceType;
  StatusType? selectedStatus;
  final List<ServiceTypeModel> serviceTypes = List.generate(5, (index) {
    return ServiceTypeModel(
      id: '${index + 1}',
      name: 'Service Type ${index + 1}',
      image: 'https://example.com/images/service_type_${index + 1}.png',
    );
  });
  List<GovernanceModel> governorates = [
    const GovernanceModel(name: 'Cairo', id: '1'),
    const GovernanceModel(name: 'Giza', id: '2'),
    const GovernanceModel(name: 'Alexandria', id: '3'),
    const GovernanceModel(name: 'Aswan', id: '4'),
    const GovernanceModel(name: 'Luxor', id: '5'),
  ];

  List<CityModel> cities = [
    const CityModel(name: 'Nasr City', id: '101'),
    const CityModel(name: '6th of October', id: '102'),
    const CityModel(name: 'Smouha', id: '103'),
    const CityModel(name: 'Aswan City', id: '104'),
    const CityModel(name: 'East Luxor', id: '105'),
  ];

  List<RegionModel> regions = [
    const RegionModel(name: 'First District', id: '1001'),
    const RegionModel(name: 'Second District', id: '1002'),
    const RegionModel(name: 'Downtown', id: '1003'),
    const RegionModel(name: 'El Mahatta', id: '1004'),
    const RegionModel(name: 'Karnak Area', id: '1005'),
  ];
  @override
  void initState() {
    if (widget.model != null) {
      if(widget.model?.governanceId!= null){
        selectedGovernorate = governorates
            .firstWhere((element) => element.id == widget.model?.governanceId);
      }
      if(widget.model?.cityId!= null){
        selectedCity =
            cities.firstWhere((element) => element.id == widget.model?.cityId);
      }
      if(widget.model?.regionId!= null){
        selectedRegion =
            regions.firstWhere((element) => element.id == widget.model?.regionId);
      }
     if(widget.model?.serviceTypeId!= null){
       selectedServiceType = serviceTypes
           .firstWhere((element) => element.id == widget.model?.serviceTypeId);
     }
     if(widget.model?.active!= null){
       selectedStatus = widget.model?.active== true ? StatusType.active : StatusType.inactive;

     }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(title: AppStrings.filter.tr()),
          24.height,
          CustomDropDownField(
            key: UniqueKey(),
            value: selectedServiceType,
            label: AppStrings.serviceType.tr(),
            hint: AppStrings.serviceType.tr(),
            validator: CustomValidators.validateDropDown,
            onChanged: ( p0) {
              setState(() {
                selectedServiceType = p0;
                widget.model?.serviceTypeId = p0?.id;
              });
            },
            items: serviceTypes
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name ?? ''),
                    ))
                .toList(),
          ),
          20.height,
          StatusSelectableChips(
              options: StatusType.values,
              selected: selectedStatus,
              title: AppStrings.status,
              onSelectionChanged: (value) {
                setState(() {
                  selectedStatus = value;
                  widget.model?.active = selectedStatus == StatusType.active;
                });
              }),
          20.height,
          CustomDropDownField(
            key: UniqueKey(),
            value: selectedGovernorate,
            label: AppStrings.governance.tr(),
            hint: AppStrings.governance.tr(),
            validator: CustomValidators.validateDropDown,
            onChanged: ( p0) {
              setState(() {
                selectedGovernorate = p0;
                widget.model?.governanceId = p0?.id;
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
          CustomDropDownField(
            key: UniqueKey(),
            onChanged: ( p0) {
              setState(() {
                selectedCity = p0;
                widget.model?.cityId = p0?.id;
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
          CustomDropDownField(
            key: _selectedRegionKey,
            onChanged: ( p0) {
              setState(() {
                selectedRegion = p0;
                widget.model?.regionId = p0?.id;
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
          24.height,
          Row(
            children: [
              Expanded(
                child: CustomButton.filled(
                  width: 168.w,
                  onTap: () {
                    FilterProvidersModel filter = FilterProvidersModel(
                      serviceTypeId: selectedServiceType?.id,
                      active: selectedStatus == StatusType.active,
                      governanceId: selectedGovernorate?.id,
                      cityId: selectedCity?.id,
                      regionId: selectedRegion?.id,
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
                    FilterProvidersModel filter = FilterProvidersModel(
                      serviceTypeId: null,
                      active: null,
                      governanceId:null,
                      cityId: null,
                      regionId: null,
                    );
                    context.pop(filter);
                  },
                  text: AppStrings.reset.tr(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  reset() {
    setState(() {
      selectedGovernorate = null;
      selectedCity = null;
      selectedRegion = null;
      selectedServiceType = null;
      selectedStatus = null;
      widget.model = FilterProvidersModel();
      _selectedCityKey.currentState?.reset();
      _selectedRegionKey.currentState?.reset();
      _selectedGovernorateKey.currentState?.reset();
      _selectedServiceTypeKey.currentState?.reset();
    });
  }
}
