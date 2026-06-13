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

class ServiceOrdersScreen extends StatefulWidget {
  const ServiceOrdersScreen({super.key});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  final _repository = getIt<ServiceOrderRepository>();
  List<ServiceOrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
      (orders) => setState(() {
        _orders = orders;
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
      case 'completed':
        return AppStrings.orderStatusCompleted.tr();
      case 'cancelled':
        return AppStrings.orderStatusCancelled.tr();
      default:
        return AppStrings.orderStatusPending.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myServiceOrders.tr()),
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
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: AppColors.brandBorder),
                        ),
                        tileColor: AppColors.textFieldFillColor,
                        title: Text(
                          order.serviceType?.name ??
                              AppStrings.serviceOrder.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                        subtitle: Text(
                          '${_statusLabel(order.status)}\n${order.description ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          if (order.id == null) return;
                          context.pushNamed(
                            Routes.serviceOrderDetail,
                            pathParameters: {'id': order.id!},
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
