import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureLocalStorage {
  static const AndroidOptions _android = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const IOSOptions _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  static const FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: _android,
    iOptions: _ios,
  );

  static Future<void> write(String key, String value) async {
    await storage.write(
      key: key,
      value: value,
      aOptions: _android,
      iOptions: _ios,
    );
  }

  static Future<String?> read(String key) async {
    return storage.read(
      key: key,
      aOptions: _android,
      iOptions: _ios,
    );
  }

  static Future<void> delete(String key) async {
    await storage.delete(
      key: key,
      aOptions: _android,
      iOptions: _ios,
    );
  }
}
