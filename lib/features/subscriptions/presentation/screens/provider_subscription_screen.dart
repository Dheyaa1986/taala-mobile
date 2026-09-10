import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/subscriptions/data/models/provider_subscription_model.dart';
import 'package:taal/features/subscriptions/data/repository/subscription_repository.dart';

class ProviderSubscriptionScreen extends StatefulWidget {
  const ProviderSubscriptionScreen({super.key});

  @override
  State<ProviderSubscriptionScreen> createState() =>
      _ProviderSubscriptionScreenState();
}

class _ProviderSubscriptionScreenState extends State<ProviderSubscriptionScreen> {
  final _repository = SubscriptionRepository();
  late Future<({
    ProviderSubscriptionModel? subscription,
    List<SubscriptionPlanModel> plans,
    String? error,
  })> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<({
    ProviderSubscriptionModel? subscription,
    List<SubscriptionPlanModel> plans,
    String? error,
  })> _load() async {
    final subscriptionResult = await _repository.getMySubscription();
    final plansResult = await _repository.getPlans();

    var plans = <SubscriptionPlanModel>[];
    plansResult.fold((_) {}, (value) => plans = value);

    return subscriptionResult.fold(
      (error) => (
        subscription: null,
        plans: plans,
        error: error.displayMessage,
      ),
      (subscription) => (
        subscription: subscription,
        plans: plans,
        error: null,
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'trial':
        return AppStrings.subscriptionStatusTrial.tr();
      case 'active':
        return AppStrings.subscriptionStatusActive.tr();
      case 'expired':
        return AppStrings.subscriptionStatusExpired.tr();
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.mySubscription.tr(),
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

          if (data.error != null && subscription == null) {
            return Center(child: Text(data.error!));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _loadFuture = _load());
              await _loadFuture;
            },
            child: ListView(
              padding: REdgeInsets.all(16),
              children: [
                if (subscription != null) ...[
                  _InfoCard(
                    title: AppStrings.currentPlan.tr(),
                    children: [
                      Text(
                        subscription.planName ??
                            _statusLabel(subscription.status),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      8.height,
                      Text(
                        '${AppStrings.subscriptionStatus.tr()}: ${_statusLabel(subscription.status)}',
                      ),
                      if (subscription.expiresAt != null) ...[
                        4.height,
                        Text(
                          '${AppStrings.subscriptionExpires.tr()}: ${DateFormat.yMMMd(isArabic ? 'ar' : 'en').add_jm().format(subscription.expiresAt!.toLocal())}',
                        ),
                      ],
                      if (subscription.ordersRemaining != null) ...[
                        4.height,
                        Text(
                          '${AppStrings.ordersRemaining.tr()}: ${subscription.ordersRemaining}',
                        ),
                      ],
                      4.height,
                      Text(
                        '${AppStrings.ordersUsed.tr()}: ${subscription.ordersUsed}',
                      ),
                      if (!subscription.canReceiveOrders &&
                          subscription.message != null) ...[
                        12.height,
                        Text(
                          subscription.message!,
                          style: TextStyle(
                            color: AppColors.redColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
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
                if (data.plans.isEmpty)
                  Text(AppStrings.noPlansAvailable.tr())
                else
                  ...data.plans.map(
                    (plan) => Card(
                      margin: REdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(isArabic ? plan.nameAr : plan.nameEn),
                        subtitle: Text(
                          plan.billingType == 'order_based'
                              ? AppStrings.orderBasedPlan.tr()
                              : AppStrings.timeBasedPlan.tr(),
                        ),
                        trailing: Text(
                          '${plan.price.toStringAsFixed(0)} ${plan.currency}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                12.height,
                Text(
                  AppStrings.paymentComingSoon.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: REdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
            12.height,
            ...children,
          ],
        ),
      ),
    );
  }
}
