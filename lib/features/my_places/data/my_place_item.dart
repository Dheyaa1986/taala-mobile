class MyPlaceItem {
  const MyPlaceItem({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.details,
    this.address,
    required this.createdAtMs,
  });

  final String id;
  final String kind;
  final String category;
  final String title;
  final double latitude;
  final double longitude;
  final String? details;
  final String? address;
  final int createdAtMs;

  bool get isAlert => kind == MyPlaceKinds.alert;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'category': category,
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        if (details != null) 'details': details,
        if (address != null) 'address': address,
        'createdAtMs': createdAtMs,
      };

  factory MyPlaceItem.fromJson(Map<String, dynamic> json) {
    return MyPlaceItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? MyPlaceKinds.place,
      category: json['category']?.toString() ?? MyPlaceCategories.other,
      title: json['title']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      details: json['details']?.toString(),
      address: json['address']?.toString(),
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class MyPlaceKinds {
  static const place = 'place';
  static const alert = 'alert';
}

class MyPlaceCategories {
  static const home = 'home';
  static const work = 'work';
  static const other = 'other';
  static const traffic = 'traffic';
  static const accident = 'accident';
  static const closure = 'closure';
  static const hazard = 'hazard';
  static const speedBump = 'speedBump';
  static const police = 'police';
  static const trafficLight = 'trafficLight';
  static const sign = 'sign';
  static const camera = 'camera';
  static const note = 'note';

  static const placeOptions = [home, work, other];
  static const alertOptions = [
    traffic,
    accident,
    speedBump,
    police,
    trafficLight,
    sign,
    camera,
    closure,
    hazard,
    note,
  ];
}
