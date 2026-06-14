import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/service_orders/presentation/widgets/provider_contact_sheet.dart';

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
  final _locationsRepository = getIt<LocationsRepository>();
  final _providersRepository = getIt<ProviderRepository>();

  List<ServiceTypeModel> _serviceTypes = [];
  List<ServiceProviderModel> _providers = [];
  String? _selectedServiceTypeId;
  bool _loadingTypes = true;
  bool _loadingProviders = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _loadServiceTypes();
  }

  Future<void> _loadServiceTypes() async {
    final result = await _locationsRepository.getServiceTypes();
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

  Future<String?> _resolveClientId() async {
    final result = await getIt<ProfileRepository>().getMyProfile();
    return result.fold((_) => null, (profile) => profile.id);
  }

  Future<void> _goToProviderStep() async {
    if (_selectedServiceTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.selectServiceType.tr())),
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

    setState(() {
      _step = 1;
      _loadingProviders = true;
    });

    final clientId = await _resolveClientId();
    if (clientId == null) {
      if (!mounted) return;
      setState(() => _loadingProviders = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.loginRequiredForHelp.tr())),
      );
      return;
    }

    final prefs = getIt<SharedPref>();
    final lat = await prefs.get(key: PrefsKeys.clientLocationLat);
    final lng = await prefs.get(key: PrefsKeys.clientLocationLng);

    final result = await _providersRepository.getProviders(
      clientId: clientId,
      options: ProvidersPaginationOptions(
        page: 1,
        limit: 20,
        filter: FilterProvidersModel(
          serviceTypeId: _selectedServiceTypeId,
          active: true,
        ),
        clientLatitude: lat is String ? double.tryParse(lat) : null,
        clientLongitude: lng is String ? double.tryParse(lng) : null,
      ),
    );

    if (!mounted) return;
    result.fold(
      (error) {
        setState(() {
          _loadingProviders = false;
          _providers = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      (items) => setState(() {
        _providers = items;
        _loadingProviders = false;
      }),
    );
  }

  void _onProviderTap(ServiceProviderModel provider) {
    showProviderContactSheet(
      context,
      provider: provider,
      serviceTypeId: _selectedServiceTypeId!,
      description: _descriptionController.text.trim(),
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
            SheetHeader(
              title: _step == 0
                  ? AppStrings.requestHelp.tr()
                  : AppStrings.selectProvider.tr(),
            ),
            if (_step == 1) ...[
              8.height,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => setState(() => _step = 0),
                  child: Text(AppStrings.back.tr()),
                ),
              ),
            ],
            12.height,
            if (_step == 0) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppStrings.selectServiceType.tr(),
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
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
                    () => _selectedServiceTypeId =
                        ids.isEmpty ? null : ids.first,
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
              CustomButton(
                text: AppStrings.continueKey.tr(),
                onTap: _goToProviderStep,
              ),
            ] else ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppStrings.nearestProviders.tr(),
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
              12.height,
              if (_loadingProviders)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              else if (_providers.isEmpty)
                Text(
                  AppStrings.noProvidersNearby.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.commentColor,
                  ),
                )
              else
                ..._providers.map(
                  (provider) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: InkWell(
                      onTap: () => _onProviderTap(provider),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: REdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E5EA)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            CustomCachedNetworkImage(
                              url: provider.image,
                              radius: 100.r,
                              width: 48.w,
                              height: 48.h,
                            ),
                            12.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.name ?? '',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  4.height,
                                  Text(
                                    provider.services.join(', '),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.commentColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (provider.distanceKm != null)
                              Text(
                                '${provider.distanceKm!.toStringAsFixed(1)} ${AppStrings.distanceKm.tr()}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
