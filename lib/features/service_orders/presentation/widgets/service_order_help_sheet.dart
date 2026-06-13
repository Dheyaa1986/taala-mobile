import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';

Future<void> showServiceOrderHelpSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const ServiceOrderHelpSheet(),
  );
}

class ServiceOrderHelpSheet extends StatefulWidget {
  const ServiceOrderHelpSheet({super.key});

  @override
  State<ServiceOrderHelpSheet> createState() => _ServiceOrderHelpSheetState();
}

class _ServiceOrderHelpSheetState extends State<ServiceOrderHelpSheet> {
  final _descriptionController = TextEditingController();
  final _repository = getIt<LocationsRepository>();
  final _ordersRepo = getIt<ServiceOrderRepository>();

  List<ServiceTypeModel> _serviceTypes = [];
  String? _selectedServiceTypeId;
  bool _loadingTypes = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    final result = await _repository.getServiceTypes();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingTypes = false),
      (data) => setState(() {
        _serviceTypes = data;
        _loadingTypes = false;
      }),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedServiceTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.serviceType.tr())),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.requiredField.tr())),
      );
      return;
    }

    final isProvider =
        getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
    if (isProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.helpRequestClientsOnly.tr())),
      );
      return;
    }

    final hasSession = await AuthSessionHelper.hasActiveSession();
    if (!hasSession) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.loginRequiredForHelp.tr())),
      );
      Navigator.of(context).pop();
      context.pushNamed(Routes.login, extra: false);
      return;
    }

    setState(() => _submitting = true);
    final prefs = getIt<SharedPref>();
    final address = await prefs.get(key: PrefsKeys.clientLocationAddress);
    final lat = await prefs.get(key: PrefsKeys.clientLocationLat);
    final lng = await prefs.get(key: PrefsKeys.clientLocationLng);

    final result = await _ordersRepo.createOrder(
      serviceTypeId: _selectedServiceTypeId!,
      description: _descriptionController.text.trim(),
      clientAddress: address is String ? address : null,
      clientLatitude: lat is String ? double.tryParse(lat) : null,
      clientLongitude: lng is String ? double.tryParse(lng) : null,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) {
        Navigator.of(context).pop();
        if (order.id != null) {
          context.pushNamed(
            Routes.serviceOrderDetail,
            pathParameters: {'id': order.id!},
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: AppStrings.requestHelp.tr()),
            12.height,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppStrings.selectServiceType.tr(),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
            ),
            12.height,
            if (_loadingTypes)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              ServiceTypeSelectorGrid(
                items: _serviceTypes,
                selectedIds: _selectedServiceTypeId == null
                    ? {}
                    : {_selectedServiceTypeId!},
                multiSelect: false,
                onChanged: (ids) => setState(
                  () => _selectedServiceTypeId = ids.isEmpty ? null : ids.first,
                ),
              ),
            16.height,
            CustomTextField(
              controller: _descriptionController,
              label: AppStrings.supportTicketDescription.tr(),
              hint: AppStrings.enterDescription.tr(),
              maxLines: 4,
              validator: CustomValidators.validateEmpty,
            ),
            20.height,
            _submitting
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: AppStrings.send.tr(),
                    onTap: _submit,
                  ),
          ],
        ),
      ),
    );
  }
}
