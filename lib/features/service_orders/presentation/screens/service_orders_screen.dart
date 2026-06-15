import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';
import 'package:taal/features/service_orders/presentation/widgets/service_order_card.dart';

class ServiceOrdersScreen extends StatefulWidget {
  const ServiceOrdersScreen({super.key});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  final _repository = getIt<ServiceOrderRepository>();
  List<ServiceOrderModel> _orders = [];
  Set<String> _readIds = {};
  Set<String> _dismissedIds = {};
  bool _loading = true;
  bool _isProvider = false;
  String? _acceptingOrderId;

  @override
  void initState() {
    super.initState();
    _isProvider =
        getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
    _load();
  }

  Future<void> _load() async {
    final result = await _repository.getMyOrders();
    if (!mounted) return;

    result.fold(
      (error) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      (orders) {
        final dismissed = ServiceOrderLocalStateHelper.dismissedIds();
        final visibleOrders = orders
            .where(
              (order) => order.id == null || !dismissed.contains(order.id),
            )
            .toList();

        final readIds = visibleOrders
            .where(
              (order) =>
                  order.id != null &&
                  ServiceOrderLocalStateHelper.isRead(order.id!),
            )
            .map((order) => order.id!)
            .toSet();

        if (!mounted) return;
        setState(() {
          _dismissedIds = dismissed;
          _readIds = readIds;
          _orders = visibleOrders;
          _loading = false;
        });
      },
    );
  }

  Future<void> _openOrder(ServiceOrderModel order) async {
    final id = order.id;
    if (id == null) return;

    if (_isProvider) {
      await ServiceOrderLocalStateHelper.markRead(id);
      if (!mounted) return;
      setState(() => _readIds = {..._readIds, id});
      ServiceOrderNavigation.openDetail(id, openChat: true);
      return;
    }

    ServiceOrderNavigation.openDetail(id);
  }

  Future<void> _acceptOrder(ServiceOrderModel order) async {
    final id = order.id;
    if (id == null || _acceptingOrderId != null) return;

    setState(() => _acceptingOrderId = id);
    final result = await _repository.updateStatus(
      orderId: id,
      status: 'accepted',
    );
    if (!mounted) return;

    await result.fold(
      (error) async {
        setState(() => _acceptingOrderId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      (_) async {
        await ServiceOrderLocalStateHelper.markRead(id);
        if (!mounted) return;
        setState(() {
          _acceptingOrderId = null;
          _readIds = {..._readIds, id};
        });
        ServiceOrderNavigation.openDetail(id, openChat: true);
        await _load();
      },
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isProvider
              ? AppStrings.providerIncomingOrders.tr()
              : AppStrings.myServiceOrders.tr(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text(AppStrings.noServiceOrders.tr()))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: REdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => 12.height,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isRead = !_isProvider ||
                          (order.id != null && _readIds.contains(order.id));

                      return ServiceOrderCard(
                        order: order,
                        isRead: isRead,
                        showCounterpartyAsTitle: _isProvider,
                        onTap: () => _openOrder(order),
                        onAccept: _isProvider && order.status == 'pending'
                            ? () => _acceptOrder(order)
                            : null,
                        acceptEnabled: _acceptingOrderId != order.id,
                        onDelete: () => _confirmDelete(order),
                      );
                    },
                  ),
                ),
    );
  }
}
