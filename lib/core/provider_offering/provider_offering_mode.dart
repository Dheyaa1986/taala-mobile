import 'package:flutter/material.dart';

enum ProviderOfferingMode {
  fixed,
  mobile,
  both,
}

extension ProviderOfferingModeX on ProviderOfferingMode {
  String get apiValue {
    switch (this) {
      case ProviderOfferingMode.fixed:
        return 'fixed';
      case ProviderOfferingMode.mobile:
        return 'mobile';
      case ProviderOfferingMode.both:
        return 'both';
    }
  }

  static ProviderOfferingMode? fromApi(String? value) {
    switch (value) {
      case 'fixed':
        return ProviderOfferingMode.fixed;
      case 'mobile':
        return ProviderOfferingMode.mobile;
      case 'both':
        return ProviderOfferingMode.both;
      default:
        return null;
    }
  }

  IconData get icon {
    switch (this) {
      case ProviderOfferingMode.fixed:
        return Icons.storefront_outlined;
      case ProviderOfferingMode.mobile:
        return Icons.local_shipping_outlined;
      case ProviderOfferingMode.both:
        return Icons.home_work_outlined;
    }
  }

  bool get requiresShop => this == ProviderOfferingMode.fixed || this == ProviderOfferingMode.both;
}

enum ServiceOrderVisitType {
  mobileOnSite,
  visitShop,
}

extension ServiceOrderVisitTypeX on ServiceOrderVisitType {
  String get apiValue {
    switch (this) {
      case ServiceOrderVisitType.mobileOnSite:
        return 'mobile_on_site';
      case ServiceOrderVisitType.visitShop:
        return 'visit_shop';
    }
  }
}

bool isMobileOnlyServiceCategory(String? categoryCode) {
  final code = (categoryCode ?? '').toUpperCase();
  return code == 'CRANE' || code == 'TOWING';
}
