import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/alerts/alert_delivery_bootstrap.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/core/alerts/app_alert_monitor.dart';
import 'package:taal/features/guest/data/repository/guest_repository.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';

import '../../../../core/helpers/auth_session_helper.dart';

Future<bool?> showGuestHelpRequestSheet(
  BuildContext context, {
  required PickedLocation location,
  String? providerId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => GuestHelpRequestSheet(
      location: location,
      providerId: providerId,
    ),
  );
}

class GuestHelpRequestSheet extends StatefulWidget {
  const GuestHelpRequestSheet({
    super.key,
    required this.location,
    this.providerId,
  });

  final PickedLocation location;
  final String? providerId;

  @override
  State<GuestHelpRequestSheet> createState() => _GuestHelpRequestSheetState();
}

class _GuestHelpRequestSheetState extends State<GuestHelpRequestSheet> {
  final _contactFormKey = GlobalKey<FormState>();
  final _requestFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _guestRepository = GuestRepository();

  List<ServiceTypeModel> _serviceTypes = [];
  String? _selectedServiceTypeId;
  bool _loadingTypes = true;
  bool _continuing = false;
  bool _sendingOtp = false;
  bool _submitting = false;
  bool _otpSent = false;
  int _step = 0;
  int _otpCooldown = 0;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceTypes() async {
    final result = await getIt<LocationsRepository>().getServiceTypes();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingTypes = false),
      (data) => setState(() {
        _serviceTypes = data;
        _loadingTypes = false;
      }),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ApiErrorMessage.from(message))),
    );
  }

  Future<bool> _sendOtp({required bool showSuccessMessage}) async {
    final phone = _phoneController.text.trim();
    final phoneError = CustomValidators.validatePhone(phone);
    if (phoneError != null) {
      _showError(phoneError);
      return false;
    }

    setState(() => _sendingOtp = true);
    final result = await _guestRepository.sendOtp(phone);
    if (!mounted) return false;
    setState(() => _sendingOtp = false);

    return result.fold(
      (error) {
        _showError(error.displayMessage);
        return false;
      },
      (result) {
        if (showSuccessMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.otpSent.tr())),
          );
        }
        ClientProfileGuard.showDebugOtp(context, result.debugOtp);
        setState(() {
          _otpSent = true;
          _otpCooldown = 60;
        });
        _tickOtpCooldown();
        return true;
      },
    );
  }

  void _tickOtpCooldown() {
    if (_otpCooldown <= 0 || !mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _otpCooldown -= 1);
      if (_otpCooldown > 0) {
        _tickOtpCooldown();
      }
    });
  }

  Future<void> _continueContact() async {
    if (!_contactFormKey.currentState!.validate()) return;

    setState(() {
      _continuing = true;
      _step = 1;
    });

    await _sendOtp(showSuccessMessage: true);

    if (mounted) {
      setState(() => _continuing = false);
    }
  }

  Future<void> _submit() async {
    if (!_requestFormKey.currentState!.validate()) return;
    if (_selectedServiceTypeId == null) {
      _showError(AppStrings.selectServiceType.tr());
      return;
    }

    setState(() => _submitting = true);
    final result = await _guestRepository.requestHelp(
      name: _nameController.text,
      phone: _phoneController.text,
      otp: _otpController.text,
      serviceTypeId: _selectedServiceTypeId!,
      latitude: widget.location.latitude,
      longitude: widget.location.longitude,
      address: widget.location.address,
      description: _descriptionController.text,
      providerId: widget.providerId,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    await result.fold(
      (error) async => _showError(error.displayMessage),
      (response) async {
        await AuthSessionHelper.establishClientSession(
          token: response.token,
          refreshToken: response.refreshToken,
        );

        final prefs = getIt<SharedPref>();
        await prefs.set(
          key: PrefsKeys.clientLocationLat,
          value: widget.location.lat,
        );
        await prefs.set(
          key: PrefsKeys.clientLocationLng,
          value: widget.location.lng,
        );
        if (widget.location.address != null) {
          await prefs.set(
            key: PrefsKeys.clientLocationAddress,
            value: widget.location.address!,
          );
        }

        await getIt<ProfileCubit>().loadProfile();
        await getIt<NotificationCubit>().refreshInbox(reloadList: true);
        getIt<AppAlertMonitor>().start();
        await AlertDeliveryBootstrap.ensureReady();
        getIt<ActiveOrderRefreshNotifier>().notifyChanged();

        if (!mounted) return;
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.guestHelpOrderSent.tr())),
        );

        if (response.isNewAccount) {
          await ClientProfileGuard.promptAfterFirstOrder(context);
        }

        final orderId = response.order.id;
        if (orderId != null && orderId.isNotEmpty) {
          ServiceOrderNavigation.openDetail(orderId, openChat: true);
        }
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepDot(active: _step >= 0, label: '1'),
        Expanded(child: Divider(color: Colors.grey.shade300)),
        _StepDot(active: _step >= 1, label: '2'),
      ],
    );
  }

  Widget _buildContactStep() {
    return Form(
      key: _contactFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.guestHelpContactStepHint.tr(),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
          ),
          12.height,
          CustomTextField(
            controller: _nameController,
            label: AppStrings.name.tr(),
            hint: AppStrings.name.tr(),
            validator: CustomValidators.validateEmpty,
          ),
          12.height,
          CustomTextField(
            controller: _phoneController,
            label: AppStrings.phone.tr(),
            hint: AppStrings.phone.tr(),
            keyboardType: TextInputType.phone,
            validator: CustomValidators.validatePhone,
          ),
          20.height,
          _continuing || _sendingOtp
              ? const Center(child: CircularProgressIndicator())
              : CustomButton.filled(
                  text: AppStrings.continueKey.tr(),
                  onTap: _continueContact,
                ),
        ],
      ),
    );
  }

  Widget _buildRequestStep() {
    return Form(
      key: _requestFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.guestHelpVerifyStepHint.tr(),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
          ),
          8.height,
          Text(
            _phoneController.text.trim(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          12.height,
          if (_sendingOtp && !_otpSent)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  8.width,
                  Text(
                    AppStrings.sendOtp.tr(),
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _otpController,
                  label: AppStrings.otpCode.tr(),
                  hint: AppStrings.otpCode.tr(),
                  keyboardType: TextInputType.number,
                  validator: CustomValidators.validateEmpty,
                ),
              ),
              8.width,
              CustomButton.outlined(
                text: _otpCooldown > 0
                    ? '${_otpCooldown}s'
                    : AppStrings.resendOtp.tr(),
                onTap: (_sendingOtp || _otpCooldown > 0)
                    ? null
                    : () => _sendOtp(showSuccessMessage: true),
              ),
            ],
          ),
          16.height,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppStrings.selectServiceType.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          12.height,
          if (_loadingTypes)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
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
          12.height,
          CustomTextField(
            controller: _descriptionController,
            label: AppStrings.description.tr(),
            hint: AppStrings.enterDescription.tr(),
            maxLines: 3,
          ),
          20.height,
          _submitting
              ? const Center(child: CircularProgressIndicator())
              : CustomButton.filled(
                  text: AppStrings.requestHelp.tr(),
                  onTap: _submit,
                ),
          8.height,
          CustomButton.outlined(
            text: AppStrings.back.tr(),
            onTap: _submitting ? null : () => setState(() => _step = 0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: context.safeBottomInset + context.keyboardInset + 20.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: AppStrings.requestHelp.tr()),
            12.height,
            _buildStepIndicator(),
            16.height,
            if (_step == 0) _buildContactStep() else _buildRequestStep(),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
