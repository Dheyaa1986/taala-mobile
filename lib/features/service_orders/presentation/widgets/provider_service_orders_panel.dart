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
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';
import 'package:taal/features/service_orders/presentation/widgets/service_order_card.dart';

class ProviderServiceOrdersPanel extends StatefulWidget {
  const ProviderServiceOrdersPanel({super.key});

  @override
  State<ProviderServiceOrdersPanel> createState() =>
      _ProviderServiceOrdersPanelState();
}

class _ProviderServiceOrdersPanelState extends State<ProviderServiceOrdersPanel> {
  final _repository = getIt<ServiceOrderRepository>();
  List<ServiceOrderModel> _orders = [];
  Set<String> _readIds = {};
  Set<String> _dismissedIds = {};
  bool _loading = true;
  bool _routeActive = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrent && !_routeActive) {
      _load();
    }
    _routeActive = isCurrent;
  }

  Future<void> _load() async {
    final dismissed = ServiceOrderLocalStateHelper.dismissedIds();
    final result = await _repository.getMyOrders(limit: 10);
    if (!mounted) return;

    result.fold(
      (_) => setState(() => _loading = false),
      (orders) {
        final readIds = orders
            .where(
              (order) =>
                  order.id != null &&
                  ServiceOrderLocalStateHelper.isRead(order.id!),
            )
            .map((order) => order.id!)
            .toSet();

        setState(() {
          _readIds = readIds;
          _dismissedIds = dismissed;
          _orders = orders
              .where(
                (order) =>
                    order.id != null &&
                    !_dismissedIds.contains(order.id) &&
                    order.status != 'completed' &&
                    order.status != 'cancelled',
              )
              .take(5)
              .toList();
          _loading = false;
        });
      },
    );
  }

  Future<void> _openOrder(ServiceOrderModel order) async {
    final id = order.id;
    if (id == null) return;

    await ServiceOrderLocalStateHelper.markRead(id);
    if (!mounted) return;
    setState(() => _readIds = {..._readIds, id});
    ServiceOrderNavigation.openDetail(id);
  }

  Future<void> _confirmDelete(ServiceOrderModel order) async {
    final id = order.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteOrder.tr()),
        content: Text(AppStrings.deleteOrderSubtitle.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ServiceOrderLocalStateHelper.dismiss(id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              padding: EdgeInsets.only(bottom: 10.h),
              child: ServiceOrderCard(
                order: order,
                isRead: order.id != null && _readIds.contains(order.id),
                onTap: () => _openOrder(order),
                onDelete: () => _confirmDelete(order),
              ),
            ),
          ),
      ],
    );
  }
}
