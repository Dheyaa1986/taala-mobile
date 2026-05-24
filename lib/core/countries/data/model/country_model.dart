class CountryModel {
  final String flagPng;
  final String flagSvg;
  final String code;
  final String name;

  CountryModel({
    required this.flagPng,
    required this.flagSvg,
    required this.code,
    required this.name,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final idd = json['idd'];
    final root = idd['root'] ?? '';
    final suffixes = (idd['suffixes'] as List?)?.join() ?? '';

    return CountryModel(
      flagPng: json['flags']['png'] ?? '',
      flagSvg: json['flags']['svg'] ?? '',
      code: '$root$suffixes',
      name: json['name']['common'] ?? '',
    );
  }
}
