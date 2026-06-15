import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';

class ServiceOrderDetailScreen extends StatefulWidget {
  const ServiceOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<ServiceOrderDetailScreen> createState() =>
      _ServiceOrderDetailScreenState();
}

class _ServiceOrderDetailScreenState extends State<ServiceOrderDetailScreen> {
  final _messageController = TextEditingController();
  final _repository = getIt<ServiceOrderRepository>();
  final _scrollController = ScrollController();

  ServiceOrderModel? _order;
  ServiceOrderTrackingModel? _tracking;
  bool _loading = true;
  bool _sending = false;
  bool _isProvider = false;
  String? _myUserId;
  Timer? _trackingTimer;
  Timer? _messagesTimer;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
    _trackingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadTracking();
    });
    _messagesTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _messagesTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final prefs = getIt<SharedPref>();
    final isProvider =
        await prefs.get(key: PrefsKeys.isProviderAccount) == true;
    final profile = await getIt<ProfileRepository>().getMyProfile();
    if (!mounted) return;
    setState(() {
      _isProvider = isProvider;
      profile.fold((_) {}, (p) => _myUserId = p.id);
    });

    if (isProvider) {
      await ServiceOrderLocalStateHelper.markRead(widget.orderId);
    }
  }

  Future<void> _load({bool silent = false}) async {
    final result = await _repository.getOrder(widget.orderId);
    if (!mounted) return;
    result.fold(
      (error) {
        if (!silent) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message)),
          );
        }
      },
      (order) {
        setState(() {
          _order = order;
          _loading = false;
        });
        if (!silent) _loadTracking();
      },
    );
  }

  Future<void> _loadTracking() async {
    final result = await _repository.getTracking(widget.orderId);
    if (!mounted) return;
    result.fold((_) {}, (tracking) {
      setState(() => _tracking = tracking);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final result = await _repository.sendMessage(
      orderId: widget.orderId,
      message: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) {
        _messageController.clear();
        setState(() => _order = order);
      },
    );
  }

  Future<void> _updateStatus(String status, {double? agreedPrice}) async {
    final result = await _repository.updateStatus(
      orderId: widget.orderId,
      status: status,
      agreedPrice: agreedPrice,
    );
    if (!mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) => setState(() => _order = order),
    );
  }

  Future<void> _approveOrder() async {
    final priceController = TextEditingController();
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.approveOrder.tr()),
        content: CustomTextField(
          controller: priceController,
          label: AppStrings.agreedPrice.tr(),
          hint: AppStrings.enterAgreedPrice.tr(),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancelOrder.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.approveOrder.tr()),
          ),
        ],
      ),
    );
    if (agreed == true) {
      final price = double.tryParse(priceController.text.trim());
      await _updateStatus('accepted', agreedPrice: price);
    }
    priceController.dispose();
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
    final order = _order;
    final canChat = order?.status != 'cancelled' && order?.status != 'completed';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.serviceOrder.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (order != null)
                  Container(
                    width: double.infinity,
                    margin: REdgeInsets.all(12),
                    padding: REdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isProvider
                              ? (order.clientName ?? '')
                              : (order.providerName ?? ''),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                        4.height,
                        Text(
                          order.serviceType?.name ?? order.description ?? '',
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
                        if (order.agreedPrice != null) ...[
                          4.height,
                          Text(
                            '${AppStrings.agreedPrice.tr()}: ${order.agreedPrice}',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (_tracking != null &&
                    (_tracking!.distanceKm != null ||
                        _tracking!.etaMinutes != null))
                  Container(
                    width: double.infinity,
                    margin: REdgeInsets.symmetric(horizontal: 12),
                    padding: REdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.trackArrival.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                        6.height,
                        Text(
                          [
                            if (_tracking!.distanceKm != null)
                              '${_tracking!.distanceKm!.toStringAsFixed(1)} ${AppStrings.distanceKm.tr()}',
                            if (_tracking!.etaMinutes != null)
                              '${_tracking!.etaMinutes} ${AppStrings.minutes.tr()}',
                          ].join(' • '),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                8.height,
                if (_isProvider && order?.status == 'pending')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.acceptOrder.tr(),
                      onTap: () => _updateStatus('accepted'),
                    ),
                  ),
                if (_isProvider && order?.status == 'accepted')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.startTrip.tr(),
                      onTap: () => _updateStatus('en_route'),
                    ),
                  ),
                if (_isProvider && order?.status == 'en_route')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.arrived.tr(),
                      onTap: () => _updateStatus('arrived'),
                    ),
                  ),
                if (!_isProvider && order?.status == 'pending') ...[
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.approveOrder.tr(),
                      onTap: _approveOrder,
                    ),
                  ),
                  8.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.outlined(
                      text: AppStrings.cancelOrder.tr(),
                      onTap: () => _updateStatus('cancelled'),
                    ),
                  ),
                ],
                if (!_isProvider &&
                    (order?.status == 'arrived' ||
                        order?.status == 'accepted'))
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.completeOrder.tr(),
                      onTap: () => _updateStatus('completed'),
                    ),
                  ),
                8.height,
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: REdgeInsets.all(12),
                    itemCount: order?.messages.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = order!.messages[index];
                      final isMine = message.senderId == _myUserId;
                      return Align(
                        alignment: isMine
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: REdgeInsets.all(10),
                          constraints: BoxConstraints(maxWidth: 0.78.sw),
                          decoration: BoxDecoration(
                            color: isMine
                                ? AppColors.primaryColor.withValues(alpha: 0.15)
                                : AppColors.textFieldFillColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.senderName != null && !isMine)
                                Text(
                                  message.senderName!,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              Text(message.message ?? ''),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (canChat)
                  Padding(
                    padding: REdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _messageController,
                            hint: AppStrings.writeMessage.tr(),
                          ),
                        ),
                        8.width,
                        IconButton(
                          onPressed: _sending ? null : _sendMessage,
                          icon: _sending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
