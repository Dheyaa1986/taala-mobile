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

class FilterProvidersModel {
  String? serviceTypeId;
  bool? active;
  String? cityId;
  String? governanceId;
  String? regionId;

  FilterProvidersModel({
    this.serviceTypeId,
    this.active,
    this.cityId,
    this.governanceId,
    this.regionId,
  });
}

class ProvidersPaginationOptions extends PaginationOptions {
  final FilterProvidersModel? filter;
  final double? clientLatitude;
  final double? clientLongitude;

  const ProvidersPaginationOptions({
    super.page = 1,
    super.limit = 10,
    super.search,
    super.sendLang,
    this.filter,
    this.clientLatitude,
    this.clientLongitude,
  });
}
