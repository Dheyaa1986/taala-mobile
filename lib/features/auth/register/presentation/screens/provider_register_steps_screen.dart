import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'package:taal/core/widgets/buttons/back_button.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/fields/map_location_picker_field.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/features/auth/register/data/model/register_options.dart';
import 'package:taal/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:taal/features/auth/widgets/auth_header_widget.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';

class ProviderRegisterStepsScreen extends StatefulWidget {
  const ProviderRegisterStepsScreen({super.key, required this.options});

  final RegisterOptions options;

  @override
  State<ProviderRegisterStepsScreen> createState() =>
      _ProviderRegisterStepsScreenState();
}

class _ProviderRegisterStepsScreenState
    extends State<ProviderRegisterStepsScreen> {
  final _pageController = PageController();
  final _descriptionController = TextEditingController();
  final _locationsRepository = getIt<LocationsRepository>();
  PickedLocation? _pickedLocation;
  int _step = 0;
  Set<String> _selectedServiceTypeIds = {};
  List<ServiceTypeModel> _serviceTypes = [];
  bool _loadingServiceTypes = true;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    final result = await _locationsRepository.getServiceTypes();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingServiceTypes = false),
      (data) => setState(() {
        _serviceTypes = data;
        _loadingServiceTypes = false;
      }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _stepSubtitle() {
    switch (_step) {
      case 0:
        return AppStrings.providerRegisterStepServices.tr();
      case 1:
        return AppStrings.providerRegisterStep1.tr();
      default:
        return AppStrings.providerRegisterStep2.tr();
    }
  }

  void _nextStep() {
    if (_step == 0) {
      if (_selectedServiceTypeIds.isEmpty) {
        AppMessages.showError(context, AppStrings.selectServiceType.tr());
        return;
      }
    }
    if (_step == 1) {
      final description = _descriptionController.text.trim();
      if (description.isEmpty) {
        AppMessages.showError(context, AppStrings.requiredField.tr());
        return;
      }
    }
    if (_step == 2) {
      final locationError =
          CustomValidators.validatePickedLocation(_pickedLocation);
      if (locationError != null) {
        AppMessages.showError(context, locationError);
        return;
      }
      _submit(context);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() => _step += 1);
  }

  void _submit(BuildContext context) {
    final description = _descriptionController.text.trim();
    final mapLink = _pickedLocation!.googleMapsUrl;
    final fullAddress =
        '${widget.options.address}\n$description\n${AppStrings.mapLink.tr()}: $mapLink';

    final options = RegisterOptions(
      username: widget.options.username,
      phone: widget.options.phone,
      email: widget.options.email,
      password: widget.options.password,
      address: fullAddress,
      confirmPassword: widget.options.confirmPassword,
      country: widget.options.country,
      countryImageSvg: widget.options.countryImageSvg,
      image: widget.options.image,
      type: 'provider',
      serviceTypesIds: _selectedServiceTypeIds.toList(),
    );

    context.read<RegisterCubit>().registerClient(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) async {
          if (state is RegisterLoadingState) {
            AppMessages.showLoading(context);
          } else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            if (state is RegisterSuccessState) {
              if (!state.response.requiresApproval) {
                context.read<BottomNavigationCubit>().isProvider = true;
                await getIt<SharedPref>().set(
                  key: PrefsKeys.isProviderAccount,
                  value: true,
                );
              }
              AppMessages.showSuccess(
                context,
                state.response.message ?? AppStrings.signUp.tr(),
              );
              context.goNamed(Routes.login, extra: true);
            }
            if (state is RegisterErrorState) {
              AppMessages.showError(context, state.error);
            }
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: CustomBackButton(
                      onPressed: () => context.pop(),
                    ),
                  ),
                  16.height,
                  AuthHeaderWidget(
                    title: AppStrings.providerRegisterTitle.tr(),
                    subTitle: _stepSubtitle(),
                  ),
                  12.height,
                  Row(
                    children: List.generate(3, (index) {
                      final active = index <= _step;
                      return Expanded(
                        child: Container(
                          height: 4.h,
                          margin: REdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryColor
                                : AppColors.greyBG,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      );
                    }),
                  ),
                  24.height,
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _loadingServiceTypes
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: ServiceTypeSelectorGrid(
                                  items: _serviceTypes,
                                  selectedIds: _selectedServiceTypeIds,
                                  onChanged: (ids) => setState(
                                    () => _selectedServiceTypeIds = ids,
                                  ),
                                ),
                              ),
                        CustomTextField(
                          controller: _descriptionController,
                          label: AppStrings.providerServiceDescription.tr(),
                          hint: AppStrings.enterDescription.tr(),
                          maxLines: 5,
                        ),
                        MapLocationPickerField(
                          value: _pickedLocation,
                          onChanged: (value) =>
                              setState(() => _pickedLocation = value),
                          validator: CustomValidators.validatePickedLocation,
                        ),
                      ],
                    ),
                  ),
                  CustomButton.filled(
                    text: _step == 2
                        ? AppStrings.signUp.tr()
                        : AppStrings.continueKey.tr(),
                    onTap: () => _nextStep(),
                  ),
                  16.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
