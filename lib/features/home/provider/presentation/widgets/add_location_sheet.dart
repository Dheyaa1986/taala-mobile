import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/data/iraq_governorates.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/core/widgets/fields/map_location_picker_field.dart';
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
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: AddLocationSheet(model: model),
    ),
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
  final _repository = getIt<LocationsRepository>();

  IraqGovernorate? selectedGovernorate;
  PickedLocation? _pickedLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillGovernorate();
    _prefillMapLocation();
  }

  void _prefillGovernorate() {
    final name = widget.model?.governorateName ?? widget.model?.governance?.name;
    if (name == null || name.isEmpty) return;
    for (final governorate in iraqGovernorates) {
      if (governorate.nameAr == name || governorate.nameEn == name) {
        selectedGovernorate = governorate;
        break;
      }
    }
  }

  void _prefillMapLocation() {
    final link = widget.model?.mapLink;
    if (link == null || link.isEmpty) return;
    try {
      _pickedLocation = PickedLocation.fromGoogleMapsUrl(link);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    if (selectedGovernorate == null || _pickedLocation == null) return;

    setState(() => _isSubmitting = true);
    AppMessages.showLoading(context);

    final result = await _repository.resolveCityIdForIraqGovernorate(
      selectedGovernorate!.nameAr,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isSubmitting = false);

    result.fold(
      (error) => AppMessages.showError(context, error.message),
      (cityId) {
        final location = widget.model ?? LocationModel();
        location.cityId = cityId;
        location.city = CityModel(
          name: selectedGovernorate!.nameAr,
          id: cityId,
        );
        location.governance = GovernanceModel(
          name: selectedGovernorate!.nameAr,
          id: null,
        );
        location.governorateName = selectedGovernorate!.nameAr;
        location.mapLink = _pickedLocation!.googleMapsUrl;
        location.lat = _pickedLocation!.lat;
        location.lng = _pickedLocation!.lng;
        context.pop(location);
      },
    );
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
            CustomDropDownField<IraqGovernorate?>(
              value: selectedGovernorate,
              label: AppStrings.governorate.tr(),
              hint: AppStrings.governorate.tr(),
              validator: CustomValidators.validateDropDown,
              onChanged: (value) => setState(() => selectedGovernorate = value),
              items: iraqGovernorates
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g.nameAr),
                    ),
                  )
                  .toList(),
            ),
            20.height,
            MapLocationPickerField(
              value: _pickedLocation,
              onChanged: (value) => setState(() => _pickedLocation = value),
              validator: CustomValidators.validatePickedLocation,
            ),
            24.height,
            CustomButton.filled(
              width: 168.w,
              onTap: _isSubmitting ? null : _submit,
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
