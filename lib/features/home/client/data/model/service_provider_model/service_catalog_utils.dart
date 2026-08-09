import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';

List<ServiceCategoryCatalogModel> groupServiceTypesByCategory(
  List<ServiceTypeModel> types,
) {
  final buckets = <String, List<ServiceTypeModel>>{};
  final labels = <String, String>{};
  final codes = <String, String>{};
  final ids = <String, String>{};

  for (final type in types) {
    final key = type.categoryId ?? type.categoryCode ?? 'OTHER';
    buckets.putIfAbsent(key, () => []).add(type);
    labels[key] = type.categoryName ?? _labelForCode(type.categoryCode);
    codes[key] = type.categoryCode ?? key;
    if (type.categoryId != null) {
      ids[key] = type.categoryId!;
    }
  }

  const order = ['TOWING', 'OTHER'];
  final keys = buckets.keys.toList()
    ..sort((a, b) {
      final ai = order.indexOf(codes[a] ?? a);
      final bi = order.indexOf(codes[b] ?? b);
      final safeAi = ai >= 0 ? ai : 99;
      final safeBi = bi >= 0 ? bi : 99;
      if (safeAi != safeBi) return safeAi.compareTo(safeBi);
      return (labels[a] ?? a).compareTo(labels[b] ?? b);
    });

  return keys
      .map(
        (key) => ServiceCategoryCatalogModel(
          id: ids[key],
          code: codes[key],
          name: labels[key],
          serviceTypes: buckets[key] ?? const [],
        ),
      )
      .where((c) => c.serviceTypes.isNotEmpty)
      .toList();
}

String _labelForCode(String? code) {
  switch (code) {
    case 'TOWING':
      return 'سحب';
    case 'OTHER':
      return 'خدمات أخرى';
    default:
      return code ?? 'خدمات';
  }
}
