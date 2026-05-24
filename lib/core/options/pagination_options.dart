import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class PaginationOptions {
  final int page;
  final int limit;
  final String? search;


  final bool? sendLang;
  const PaginationOptions({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.sendLang,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': limit,
      if (search != null) 'search': search,
    };
  }
}
class FilterProvidersModel{
   int? serviceTypeId;
   bool? active;
   int? cityId;
    int? governanceId;
    int? regionId;
   FilterProvidersModel({
    this.serviceTypeId,
    this.active,
    this.cityId,
    this.governanceId,
    this.regionId
  });

    toJson() {
      return {
        if (serviceTypeId != null) 'service_type_id': serviceTypeId,
        if (active != null) 'active': active,
        if (cityId != null) 'city_id': cityId,
        if (governanceId != null) 'governance_id': governanceId,
        if (regionId != null) 'region_id': regionId
      };
    }
}
class ProvidersPaginationOptions  extends PaginationOptions {
 final FilterProvidersModel ? filter;
  const ProvidersPaginationOptions({
    super.page = 1,
    super.limit = 10,
    super.search,
    super.sendLang,
    this.filter,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': limit,
      if (search != null) 'search': search,
      if (filter != null) 'filter': filter!.toJson(),
    };
  }
}



