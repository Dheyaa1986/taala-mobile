import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';

class ProviderServiceOrdersPanel extends StatefulWidget {
  const ProviderServiceOrdersPanel({super.key});

  @override
  State<ProviderServiceOrdersPanel> createState() =>
      _ProviderServiceOrdersPanelState();
}

class _ProviderServiceOrdersPanelState extends State<ProviderServiceOrdersPanel> {
  final _repository = getIt<ServiceOrderRepository>();
  List<ServiceOrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _repository.getMyOrders(limit: 5);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (orders) => setState(() {
        _orders = orders
            .where((order) => order.status != 'completed' && order.status != 'cancelled')
            .toList();
        _loading = false;
      }),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'accepted':
        return AppStrings.orderStatusAccepted.tr();
      case 'en_route':
        return AppStrings.orderStatusEnRoute.tr();
      case 'arrived':
        return AppStrings.orderStatusArrived.tr();
      default:
        return AppStrings.orderStatusPending.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.textFieldFillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.brandBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.providerIncomingOrders.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightMainText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(Routes.serviceOrders),
                child: Text(AppStrings.viewAllOrders.tr()),
              ),
            ],
          ),
          8.height,
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_orders.isEmpty)
            Text(
              AppStrings.noServiceOrders.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.commentColor,
              ),
            )
          else
            ..._orders.map(
              (order) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  onTap: () {
                    if (order.id != null) {
                      ServiceOrderNavigation.openDetail(order.id!);
                    }
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: double.infinity,
                    padding: REdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName ?? AppStrings.serviceOrder.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        4.height,
                        Text(
                          order.serviceType?.name ?? order.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.commentColor,
                          ),
                        ),
                        6.height,
                        Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
