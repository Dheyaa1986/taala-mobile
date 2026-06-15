import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/alerts/app_alert_monitor.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';

class ProviderOrdersIconButton extends StatefulWidget {
  const ProviderOrdersIconButton({super.key});

  @override
  State<ProviderOrdersIconButton> createState() =>
      _ProviderOrdersIconButtonState();
}

class _ProviderOrdersIconButtonState extends State<ProviderOrdersIconButton> {
  final _repository = getIt<ServiceOrderRepository>();
  final _alertMonitor = getIt<AppAlertMonitor>();
  int _pendingUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _alertMonitor.ordersRefreshTick.addListener(_onOrdersRefreshTick);
    _loadCount();
  }

  void _onOrdersRefreshTick() {
    if (mounted) _loadCount();
  }

  @override
  void dispose() {
    _alertMonitor.ordersRefreshTick.removeListener(_onOrdersRefreshTick);
    super.dispose();
  }

  Future<void> _loadCount() async {
    final result = await _repository.getMyOrders(limit: 20);
    if (!mounted) return;

    result.fold((_) {}, (orders) {
      final count = orders.where((order) {
        final id = order.id;
        return order.status == 'pending' &&
            id != null &&
            !ServiceOrderLocalStateHelper.isRead(id) &&
            !ServiceOrderLocalStateHelper.isDismissed(id);
      }).length;

      setState(() => _pendingUnreadCount = count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.providerIncomingOrders.tr(),
      onPressed: () => context.pushNamed(Routes.serviceOrders),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.assignment_outlined,
            color: AppColors.primaryColor,
            size: 24.sp,
          ),
          if (_pendingUnreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16.r,
                  minHeight: 16.r,
                ),
                child: Text(
                  _pendingUnreadCount > 9 ? '9+' : '$_pendingUnreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
