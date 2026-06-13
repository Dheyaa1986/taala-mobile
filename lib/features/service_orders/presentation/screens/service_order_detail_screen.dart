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
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';

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
  Timer? _trackingTimer;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
    _trackingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadTracking();
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final value =
        await getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount);
    if (mounted) {
      setState(() => _isProvider = value == true);
    }
  }

  Future<void> _load() async {
    final result = await _repository.getOrder(widget.orderId);
    if (!mounted) return;
    result.fold(
      (error) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      (order) {
        setState(() {
          _order = order;
          _loading = false;
        });
        _loadTracking();
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

  Future<void> _updateStatus(String status) async {
    final result = await _repository.updateStatus(
      orderId: widget.orderId,
      status: status,
    );
    if (!mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) => setState(() => _order = order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.serviceOrder.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_tracking != null &&
                    (_tracking!.distanceKm != null ||
                        _tracking!.etaMinutes != null))
                  Container(
                    width: double.infinity,
                    margin: REdgeInsets.all(12),
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
                              '${_tracking!.distanceKm!.toStringAsFixed(1)} كم',
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
                if (_isProvider && _order?.status == 'pending')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.acceptOrder.tr(),
                      onTap: () => _updateStatus('accepted'),
                    ),
                  ),
                if (_isProvider && _order?.status == 'accepted')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.startTrip.tr(),
                      onTap: () => _updateStatus('en_route'),
                    ),
                  ),
                if (_isProvider && _order?.status == 'en_route')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.arrived.tr(),
                      onTap: () => _updateStatus('arrived'),
                    ),
                  ),
                if (!_isProvider && _order?.status == 'pending')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: CustomButton.filled(
                      text: AppStrings.cancelOrder.tr(),
                      onTap: () => _updateStatus('cancelled'),
                    ),
                  ),
                8.height,
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: REdgeInsets.all(12),
                    itemCount: _order?.messages.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = _order!.messages[index];
                      return Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: REdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.textFieldFillColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.senderName != null)
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
