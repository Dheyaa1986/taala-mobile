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
    final merged = <String, MyPlaceItem>{};
    for (final key in await _candidateKeys()) {
      for (final item in await _readKey(key)) {
        if (item.id.isNotEmpty) merged[item.id] = item;
      }
    }
    final items = merged.values.toList()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return items;
  }

  Future<void> saveAll(List<MyPlaceItem> items) async {
    final payload = jsonEncode(items.map((item) => item.toJson()).toList());
    final key = await _primaryKey();
    await SecureLocalStorage.write(key, payload);
    await _prefs.set(key: key, value: payload);
  }

  Future<List<MyPlaceItem>> add(MyPlaceItem item) async {
    final items = await loadAll();
    items.removeWhere((entry) => entry.id == item.id);
    items.insert(0, item);
    await saveAll(items);
    return items;
  }

  Future<List<MyPlaceItem>> upsert(MyPlaceItem item) async {
    final items = await loadAll();
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      final sameCategory = items.indexWhere(
        (entry) =>
            !item.isAlert &&
            (item.category == MyPlaceCategories.home ||
                item.category == MyPlaceCategories.work) &&
            entry.category == item.category,
      );
      if (sameCategory >= 0) {
        items[sameCategory] = item;
      } else {
        items.insert(0, item);
      }
    }
    await saveAll(items);
    return items;
  }

  Future<List<MyPlaceItem>> remove(String id) async {
    final items = await loadAll();
    items.removeWhere((item) => item.id == id);
    await saveAll(items);
    return items;
  }

  Future<List<MyPlaceItem>> _readKey(String key) async {
    String? raw = await SecureLocalStorage.read(key);
    raw ??= _prefs.get(key: key) is String ? _prefs.get(key: key) as String : null;
    if (raw == null || raw.isEmpty) return [];
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

  Future<String> _primaryKey() async =>
      '${PrefsKeys.myPlacesPrefix}${await _ownerId()}';

  Future<List<String>> _candidateKeys() async {
    final owner = await _ownerId();
    return {
      '${PrefsKeys.myPlacesPrefix}$owner',
      '${PrefsKeys.myPlacesPrefix}local',
    }.toList();
  }

  Future<String> _ownerId() async {
    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token == null || token.isEmpty) return 'local';
    try {
      final payload = JwtDecoder.decode(token);
      final id = payload['sub'] ?? payload['id'] ?? payload['userId'];
      if (id != null && id.toString().isNotEmpty) return id.toString();
    } catch (_) {}
    return 'local';
  }
}
