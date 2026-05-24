import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoHelper {
  static int buildNumber = -1;

  static Future<void> initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buildNumber = int.tryParse(packageInfo.buildNumber) ?? -1;
  }
}