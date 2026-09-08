import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/otp/phone_otp_verification_section.dart';
import 'package:taal/features/auth/register/data/model/register_options.dart';
import 'package:taal/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:taal/features/auth/widgets/auth_header_widget.dart';
import 'package:taal/features/guest/data/repository/guest_otp_repository.dart';

class RegistrationOtpScreen extends StatefulWidget {
  const RegistrationOtpScreen({super.key, required this.options});

  final RegisterOptions options;

  @override
  State<RegistrationOtpScreen> createState() => _RegistrationOtpScreenState();
}

class _RegistrationOtpScreenState extends State<RegistrationOtpScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  final _otpRepository = GuestOtpRepository();
  late final RegisterCubit _registerCubit = getIt<RegisterCubit>();
  bool _otpSent = false;

  bool get _isProvider => widget.options.type == 'provider';

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<({String? debugOtp, String? error})> _sendOtp(String phone) async {
    final result = await _otpRepository.sendRegistrationOtp(phone);
    return result.fold(
      (error) {
        if (mounted) {
          setState(() => _otpSent = false);
        }
        return (debugOtp: null, error: error.displayMessage);
      },
      (payload) {
        if (mounted) {
          setState(() => _otpSent = true);
        }
        return (debugOtp: payload.debugOtp, error: null);
      },
    );
  }

  void _continue() {
    if (!_otpSent) {
      AppMessages.showError(context, AppStrings.sendOtpFirst.tr());
      return;
    }

    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      AppMessages.showError(context, AppStrings.otpCode.tr());
      return;
    }

    final optionsWithOtp = RegisterOptions(
      countryImageSvg: widget.options.countryImageSvg,
      confirmPassword: widget.options.confirmPassword,
      password: widget.options.password,
      username: widget.options.username,
      phone: widget.options.phone,
      email: widget.options.email,
      address: widget.options.address,
      image: widget.options.image,
      country: widget.options.country,
      type: widget.options.type ?? 'client',
      otp: otp,
    );

    if (_isProvider) {
      GoRouter.of(context).pushNamed(
        Routes.providerRegisterSteps,
        extra: optionsWithOtp,
      );
      return;
    }

    _registerCubit.registerClient(options: optionsWithOtp);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _registerCubit,
      child: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (previous, current) =>
            current is RegisterLoadingState ||
            current is RegisterSuccessState ||
            current is RegisterErrorState,
        listener: (context, state) async {
          if (state is RegisterLoadingState) {
            AppMessages.showLoading(context);
            return;
          }

          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          if (state is RegisterSuccessState) {
            await getIt<SharedPref>().set(
              key: PrefsKeys.isProviderAccount,
              value: false,
            );
            AppMessages.showSuccess(
              context,
              state.response.message ?? AppStrings.signUp.tr(),
            );
            if (context.mounted) {
              context.goNamed(Routes.login, extra: false);
            }
            return;
          }

          if (state is RegisterErrorState) {
            AppMessages.showError(context, state.error);
          }
        },
        child: Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    40.height,
                    Center(
                      child: AuthHeaderWidget(
                        subTitle: AppStrings.registrationOtpSubtitle.tr(),
                        title: AppStrings.registrationOtpTitle.tr(),
                      ),
                    ),
                    24.height,
                    Text(
                      AppStrings.providerPhoneVerifyHint.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    24.height,
                    PhoneOtpVerificationSection(
                      phone: widget.options.phone,
                      otpController: _otpController,
                      otpFocusNode: _otpFocusNode,
                      onSendOtp: _sendOtp,
                      autoSendOnMount: true,
                    ),
                    32.height,
                    CustomButton.filled(
                      text: _isProvider
                          ? AppStrings.next.tr()
                          : AppStrings.signUp.tr(),
                      isBackgroundGradient: false,
                      onTap: _continue,
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
