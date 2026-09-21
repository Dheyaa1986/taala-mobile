import 'dart:io';

import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';

class ProviderDocumentRequirements {
  const ProviderDocumentRequirements({
    required this.nationalId,
    required this.vehicleRegistration,
    required this.residenceCard,
  });

  final bool nationalId;
  final bool vehicleRegistration;
  final bool residenceCard;

  bool get isEmpty =>
      !nationalId && !vehicleRegistration && !residenceCard;
}

class ProviderRegistrationDocumentFiles {
  const ProviderRegistrationDocumentFiles({
    this.nationalIdFront,
    this.nationalIdBack,
    this.vehicleRegFront,
    this.vehicleRegBack,
    this.residenceCardFront,
    this.residenceCardBack,
  });

  final File? nationalIdFront;
  final File? nationalIdBack;
  final File? vehicleRegFront;
  final File? vehicleRegBack;
  final File? residenceCardFront;
  final File? residenceCardBack;

  static const Object _unset = Object();

  ProviderRegistrationDocumentFiles copyWith({
    Object? nationalIdFront = _unset,
    Object? nationalIdBack = _unset,
    Object? vehicleRegFront = _unset,
    Object? vehicleRegBack = _unset,
    Object? residenceCardFront = _unset,
    Object? residenceCardBack = _unset,
  }) {
    return ProviderRegistrationDocumentFiles(
      nationalIdFront: identical(nationalIdFront, _unset)
          ? this.nationalIdFront
          : nationalIdFront as File?,
      nationalIdBack: identical(nationalIdBack, _unset)
          ? this.nationalIdBack
          : nationalIdBack as File?,
      vehicleRegFront: identical(vehicleRegFront, _unset)
          ? this.vehicleRegFront
          : vehicleRegFront as File?,
      vehicleRegBack: identical(vehicleRegBack, _unset)
          ? this.vehicleRegBack
          : vehicleRegBack as File?,
      residenceCardFront: identical(residenceCardFront, _unset)
          ? this.residenceCardFront
          : residenceCardFront as File?,
      residenceCardBack: identical(residenceCardBack, _unset)
          ? this.residenceCardBack
          : residenceCardBack as File?,
    );
  }

  bool satisfies(ProviderDocumentRequirements requirements) {
    if (requirements.nationalId) {
      if (nationalIdFront == null || nationalIdBack == null) return false;
    }
    if (requirements.vehicleRegistration) {
      if (vehicleRegFront == null || vehicleRegBack == null) return false;
    }
    if (requirements.residenceCard) {
      if (residenceCardFront == null || residenceCardBack == null) {
        return false;
      }
    }
    return true;
  }
}

class ProviderRegistrationDocuments {
  ProviderRegistrationDocuments._();

  static bool isTowingCategory(String? code) {
    final normalized = code?.toUpperCase();
    return normalized == 'CRANE' || normalized == 'TOWING';
  }

  static List<ServiceTypeModel> selectedTypes(
    Set<String> selectedIds,
    List<ServiceCategoryCatalogModel> catalog,
  ) {
    return catalog
        .expand((category) => category.serviceTypes)
        .where((type) => type.id != null && selectedIds.contains(type.id))
        .toList();
  }

  static ProviderDocumentRequirements resolveRequirements(
    Set<String> selectedIds,
    List<ServiceCategoryCatalogModel> catalog,
  ) {
    final selected = selectedTypes(selectedIds, catalog);
    var vehicleRegistration = false;
    var residenceCard = false;

    for (final type in selected) {
      if (isTowingCategory(type.categoryCode)) {
        vehicleRegistration = true;
      } else {
        residenceCard = true;
      }
    }

    return ProviderDocumentRequirements(
      nationalId: selected.isNotEmpty,
      vehicleRegistration: vehicleRegistration,
      residenceCard: residenceCard,
    );
  }
}
