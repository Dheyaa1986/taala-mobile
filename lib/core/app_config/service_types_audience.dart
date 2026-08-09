enum ServiceTypesAudience { guest, client, provider }

extension ServiceTypesAudienceX on ServiceTypesAudience {
  String get queryValue => name;
}
