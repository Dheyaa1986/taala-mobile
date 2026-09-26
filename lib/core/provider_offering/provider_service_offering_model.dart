import 'package:taal/core/provider_offering/provider_offering_mode.dart';
import 'package:taal/core/provider_offering/working_hours_model.dart';

class ProviderServiceOfferingInput {
  ProviderServiceOfferingInput({
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.categoryCode,
    this.mode = ProviderOfferingMode.mobile,
    List<WorkingHoursDayModel>? workingHours,
    this.shopLatitude,
    this.shopLongitude,
    this.shopGoogleMapsUrl,
  }) : workingHours = workingHours ?? WorkingHoursDayModel.defaultWeek();

  final String serviceTypeId;
  final String serviceTypeName;
  final String? categoryCode;
  ProviderOfferingMode mode;
  List<WorkingHoursDayModel> workingHours;
  double? shopLatitude;
  double? shopLongitude;
  String? shopGoogleMapsUrl;

  bool get isCraneCategory => isMobileOnlyServiceCategory(categoryCode);

  bool get requiresShop => !isCraneCategory && mode.requiresShop;

  Map<String, dynamic> toRegistrationJson() {
    return {
      'serviceTypeId': serviceTypeId,
      'offeringMode': mode.apiValue,
      if (requiresShop) 'workingHours': workingHours.map((e) => e.toJson()).toList(),
      if (requiresShop && shopLatitude != null) 'shopLatitude': shopLatitude,
      if (requiresShop && shopLongitude != null) 'shopLongitude': shopLongitude,
      if (requiresShop && shopGoogleMapsUrl != null)
        'shopGoogleMapsUrl': shopGoogleMapsUrl,
    };
  }
}

class ProviderServiceOfferingModel {
  const ProviderServiceOfferingModel({
    required this.id,
    required this.serviceTypeId,
    required this.offeringMode,
    this.workingHours = const [],
    this.shopGoogleMapsUrl,
    this.shopLatitude,
    this.shopLongitude,
    this.isOpenNow = false,
  });

  final String id;
  final String serviceTypeId;
  final ProviderOfferingMode? offeringMode;
  final List<WorkingHoursDayModel> workingHours;
  final String? shopGoogleMapsUrl;
  final double? shopLatitude;
  final double? shopLongitude;
  final bool isOpenNow;

  bool get supportsVisitShop =>
      offeringMode == ProviderOfferingMode.fixed ||
      offeringMode == ProviderOfferingMode.both;

  bool get supportsMobile =>
      offeringMode == ProviderOfferingMode.mobile ||
      offeringMode == ProviderOfferingMode.both;

  factory ProviderServiceOfferingModel.fromJson(Map<String, dynamic> json) {
    final hoursRaw = json['workingHours'];
    final hours = <WorkingHoursDayModel>[];
    if (hoursRaw is List) {
      for (final item in hoursRaw) {
        if (item is! Map) continue;
        hours.add(
          WorkingHoursDayModel(
            day: int.tryParse(item['day']?.toString() ?? '') ?? 0,
            isOpen: item['isOpen'] == true,
            openTime: item['openTime']?.toString() ?? '08:00',
            closeTime: item['closeTime']?.toString() ?? '18:00',
          ),
        );
      }
    }

    return ProviderServiceOfferingModel(
      id: json['id']?.toString() ?? '',
      serviceTypeId: json['serviceTypeId']?.toString() ?? '',
      offeringMode: ProviderOfferingModeX.fromApi(json['offeringMode']?.toString()),
      workingHours: hours,
      shopGoogleMapsUrl: json['shopGoogleMapsUrl']?.toString(),
      shopLatitude: (json['shopLatitude'] as num?)?.toDouble(),
      shopLongitude: (json['shopLongitude'] as num?)?.toDouble(),
      isOpenNow: json['isOpenNow'] == true,
    );
  }
}
