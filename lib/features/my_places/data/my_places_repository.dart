import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/secure_local_storage.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/my_places/data/my_place_item.dart';

class MyPlacesRepository {
  MyPlacesRepository(this._prefs);

  final SharedPref _prefs;

  Future<List<MyPlaceItem>> loadAll() async {
    final raw = _prefs.get(key: await _storageKey());
    if (raw is! String || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => MyPlaceItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<MyPlaceItem> items) async {
    final payload = jsonEncode(items.map((item) => item.toJson()).toList());
    await _prefs.set(key: await _storageKey(), value: payload);
  }

  Future<List<MyPlaceItem>> add(MyPlaceItem item) async {
    final items = await loadAll();
    items.add(item);
    await saveAll(items);
    return items;
  }

  Future<List<MyPlaceItem>> remove(String id) async {
    final items = await loadAll();
    items.removeWhere((item) => item.id == id);
    await saveAll(items);
    return items;
  }

  Future<String> _storageKey() async {
    final token = await SecureLocalStorage.read(PrefsKeys.token);
    var owner = 'local';
    if (token != null && token.isNotEmpty) {
      try {
        final payload = JwtDecoder.decode(token);
        final id = payload['sub'] ?? payload['id'] ?? payload['userId'];
        if (id != null && id.toString().isNotEmpty) {
          owner = id.toString();
        }
      } catch (_) {}
    }
    return '${PrefsKeys.myPlacesPrefix}$owner';
  }
}
