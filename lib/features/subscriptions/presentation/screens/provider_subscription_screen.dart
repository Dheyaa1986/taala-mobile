import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/subscriptions/data/models/provider_subscription_model.dart';
import 'package:taal/features/subscriptions/data/repository/subscription_repository.dart';
import 'package:taal/features/subscriptions/presentation/utils/provider_subscription_gate.dart';
import 'package:taal/features/subscriptions/presentation/widgets/subscription_card_widget.dart';
import 'package:taal/features/subscriptions/presentation/widgets/wayl_checkout_screen.dart';
import 'package:taal/features/subscriptions/presentation/widgets/wayl_payment_url.dart';

class ProviderSubscriptionScreen extends StatefulWidget {
  const ProviderSubscriptionScreen({
    super.key,
    this.isRequiredGate = false,
  });

  final bool isRequiredGate;

  @override
  State<ProviderSubscriptionScreen> createState() =>
      _ProviderSubscriptionScreenState();
}

class _ProviderSubscriptionScreenState extends State<ProviderSubscriptionScreen> {
  final _repository = SubscriptionRepository();
  String? _checkingOutPlanId;
  late Future<({
    ProviderSubscriptionModel? subscription,
    List<SubscriptionPlanModel> plans,
    String? subscriptionError,
    String? plansError,
  })> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<({
    ProviderSubscriptionModel? subscription,
    List<SubscriptionPlanModel> plans,
    String? subscriptionError,
    String? plansError,
  })> _load() async {
    final subscriptionResult = await _repository.getMySubscription();
    final plansResult = await _repository.getPlans();

    var plans = <SubscriptionPlanModel>[];
    String? plansError;
    plansResult.fold(
      (error) => plansError = error.displayMessage,
      (value) => plans = value,
    );

    return subscriptionResult.fold(
      (error) => (
        subscription: null,
        plans: plans,
        subscriptionError: error.displayMessage,
        plansError: plansError,
      ),
      (subscription) => (
        subscription: subscription,
        plans: plans,
        subscriptionError: null,
        plansError: plansError,
      ),
    );
  }

  String _planSubtitle(SubscriptionPlanModel plan) {
    if (plan.billingType == 'order_based') {
      return '${AppStrings.orderBasedPlan.tr()} · ${plan.orderQuota ?? 0}';
    }
    return AppStrings.timeBasedPlan.tr();
  }

  String _priceLabel(double price, String currency) {
    if (price <= 0) {
      return AppStrings.freePlan.tr();
    }
    return '${price.toStringAsFixed(0)} $currency';
  }

  bool _canPayOnline(SubscriptionPlanModel plan) => plan.price >= 1000;

  Future<void> _subscribeToPlan(SubscriptionPlanModel plan) async {
    if (_checkingOutPlanId != null) return;

    setState(() => _checkingOutPlanId = plan.id);

    final checkoutResult = await _repository.createCheckout(plan.id);
    if (!mounted) return;

    await checkoutResult.fold(
      (error) async {
        AppMessages.showError(context, error.displayMessage);
      },
      (checkout) async {
        if (checkout.paymentUrl.trim().isEmpty) {
          AppMessages.showError(context, AppStrings.paymentFailed.tr());
          return;
        }

        final paymentUrl = WaylPaymentUrl.withProviderPhone(
          checkout.paymentUrl,
          checkout.providerPhone,
        );

        final paid = await WaylCheckoutScreen.open(
          context,
          paymentUrl: paymentUrl,
          referenceId: checkout.referenceId,
          checkPaid: (referenceId) async {
            final statusResult = await _repository.getPaymentStatus(referenceId);
            return statusResult.fold((_) => false, (status) => status.paid);
          },
        );

        if (!mounted) return;

        if (paid) {
          AppMessages.showSuccess(context, AppStrings.paymentSuccess.tr());
          ProviderSubscriptionGate.invalidate();
          if (widget.isRequiredGate) {
            if (mounted) {
              context.goNamed(Routes.home);
            }
            return;
          }
          setState(() => _loadFuture = _load());
          await _loadFuture;
          return;
        }

        final statusResult =
            await _repository.getPaymentStatus(checkout.referenceId);
        final stillPending =
            statusResult.fold((_) => true, (status) => !status.paid);
        if (stillPending && mounted) {
          AppMessages.showError(context, AppStrings.paymentFailed.tr());
        }
      },
    );

    if (mounted) {
      setState(() => _checkingOutPlanId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return PopScope(
      canPop: !widget.isRequiredGate,
      child: Scaffold(
        appBar: widget.isRequiredGate
            ? CustomAppBar(
                centerTitle: true,
                title: AppStrings.subscriptions.tr(),
                actions: [
                  TextButton(
                    onPressed: () => getIt<DioService>().logout(),
                    child: Text(
                      AppStrings.logout.tr(),
                      style: TextStyle(
                        color: AppColors.redColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : CustomAppBar.backAppBar(
                title: AppStrings.subscriptions.tr(),
                centerTitle: true,
              ),
        body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final subscription = data.subscription;

          if (widget.isRequiredGate &&
              subscription?.canReceiveOrders == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.goNamed(Routes.home);
              }
            });
          }

          if (data.subscriptionError != null && subscription == null) {
            return Center(child: Text(data.subscriptionError!));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _loadFuture = _load());
              await _loadFuture;
            },
            child: ListView(
              padding: REdgeInsets.all(16),
              children: [
                if (widget.isRequiredGate) ...[
                  Text(
                    AppStrings.subscriptionRequiredMessage.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  16.height,
                ],
                if (subscription != null &&
                    !subscription.canReceiveOrders &&
                    subscription.message != null &&
                    !widget.isRequiredGate) ...[
                  Container(
                    width: double.infinity,
                    padding: REdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.redColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.redColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      subscription.message!,
                      style: TextStyle(
                        color: AppColors.redColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  16.height,
                ],
                Text(
                  AppStrings.availablePlans.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                12.height,
                if (data.plansError != null)
                  Text(
                    data.plansError!,
                    style: TextStyle(color: AppColors.redColor),
                  )
                else if (data.plans.isEmpty)
                  Text(AppStrings.noPlansAvailable.tr())
                else
                  ...data.plans.map(
                    (plan) {
                      final isCurrent = subscription?.planId == plan.id &&
                          (subscription?.canReceiveOrders ?? false);
                      final canPay = _canPayOnline(plan) && !isCurrent;

                      return SubscriptionCardWidget(
                        title: isArabic ? plan.nameAr : plan.nameEn,
                        subtitle: _planSubtitle(plan),
                        priceLabel: _priceLabel(plan.price, plan.currency),
                        cardColor: SubscriptionCardWidget.parseHexColor(
                          plan.cardColor,
                        ),
                        cardStyle: plan.cardStyle,
                        isCurrent: isCurrent,
                        currentLabel: AppStrings.currentPlanBadge.tr(),
                        actionLabel:
                            canPay ? AppStrings.subscribeNow.tr() : null,
                        onAction:
                            canPay ? () => _subscribeToPlan(plan) : null,
                        actionLoading: _checkingOutPlanId == plan.id,
                      );
                    },
                  ),
                if (data.plans.any((plan) => plan.price > 0 && plan.price < 1000))
                  Padding(
                    padding: REdgeInsets.only(top: 12),
                    child: Text(
                      AppStrings.paymentMinAmountHint.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
