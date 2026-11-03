import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/design_system/components/taala_button.dart';
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
  bool _submitting = false;

  bool get _isProvider => widget.options.type == 'provider';
  bool get _canSubmit =>
      _otpSent && _otpController.text.trim().length == 6;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      if (mounted) setState(() {});
    });
  }

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

    _submitWithSecret(otp);
  }

  void _submitWithSecret(String secret) {
    if (_submitting) return;
    if (!_isProvider) {
      setState(() => _submitting = true);
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
      otp: secret,
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

  Future<void> _enterAfterRegistration() async {
    final phone = widget.options.phone.trim();
    final email = widget.options.email.trim();
    final identifier = phone.isNotEmpty ? phone : email;
    final entered = await AuthSessionHelper.signInAndEnter(
      identifier: identifier,
      password: widget.options.password,
      isProvider: _isProvider,
    );
    if (entered) return;
    if (await AuthSessionHelper.hasActiveSession()) {
      if (!mounted) return;
      await AuthSessionHelper.openAuthenticatedApp(context);
      return;
    }
    await AuthSessionHelper.goToLoginAfterRegistration(
      isProvider: _isProvider,
      loginIdentifier: identifier,
    );
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
            return;
          }

          AppMessages.hideLoading();

          if (state is RegisterSuccessState) {
            await _enterAfterRegistration();
            return;
          }

          if (state is RegisterErrorState) {
            if (mounted) setState(() => _submitting = false);
            if (AuthSessionHelper.isExistingAccountError(state.error)) {
              await _enterAfterRegistration();
              return;
            }
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
                    PhoneOtpVerificationSection(
                      phone: widget.options.phone,
                      otpController: _otpController,
                      otpFocusNode: _otpFocusNode,
                      onSendOtp: _sendOtp,
                      autoSendOnMount: true,
                      showIntroHint: false,
                    ),
                    32.height,
                    TaalaButton(
                      label: _isProvider
                          ? AppStrings.next.tr()
                          : AppStrings.signUp.tr(),
                      onPressed:
                          _canSubmit && !_submitting ? _continue : null,
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
