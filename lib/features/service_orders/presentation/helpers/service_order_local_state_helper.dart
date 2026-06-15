import 'package:taal/core/helpers/shared_pref_local_storage.dart';

class ServiceOrderLocalStateHelper {
  static const _readIdsKey = 'read_service_order_ids';
  static const _dismissedIdsKey = 'dismissed_service_order_ids';

  static Set<String> _getIdSet(String key) {
    final list = SharedPref.sharedPreferences.getStringList(key);
    return list?.toSet() ?? {};
  }

  static Future<void> _saveIdSet(String key, Set<String> ids) async {
    await SharedPref.sharedPreferences.setStringList(key, ids.toList());
  }

  static bool isRead(String orderId) {
    return _getIdSet(_readIdsKey).contains(orderId);
  }

  static Future<void> markRead(String orderId) async {
    final ids = _getIdSet(_readIdsKey);
    ids.add(orderId);
    await _saveIdSet(_readIdsKey, ids);
  }

  static bool isDismissed(String orderId) {
    return _getIdSet(_dismissedIdsKey).contains(orderId);
  }

  static Future<void> dismiss(String orderId) async {
    final ids = _getIdSet(_dismissedIdsKey);
    ids.add(orderId);
    await _saveIdSet(_dismissedIdsKey, ids);
  }

  static Set<String> dismissedIds() => _getIdSet(_dismissedIdsKey);
}
