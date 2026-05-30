import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:map_launcher/map_launcher.dart';


import 'package:url_launcher/url_launcher.dart';

import '../../config/routes/app_router.dart';
import '../helpers/messages.dart';

class CustomLauncher {

  _showErrorToast(String message) {
    AppMessages.showError(AppRouter.appNavigatorKey.currentContext!,message);

  }
  openMaps(double lat, double lng, String address) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isEmpty) {
        _showErrorToast("No maps installed");
        return;
      }
      await availableMaps.first.showMarker(
        coords: Coords(lat, lng),
        title: address,
      );
    } catch (e) {
      _showErrorToast("Can't open maps");
    }
  }
  Future openFacebookPage(String username) async {
    try {
      await _launchSocialMediaAppIfInstalled(
        url: 'https://www.facebook.com/$username', //FaceBook
      );
    } on Exception {
      _showErrorToast("Can't open facebook");
    }
  }
  Future call(String phoneNumber,String clientName) async {
    try {
      final call = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(call)) {
        launchUrl(call);
      } else {
        throw clientName;
      }
    } on Exception {
      _showErrorToast("Can't call $clientName");
    }
  }
  Future sendMessage(String phoneNumber,String clientName) async {
    try {
      final message = Uri.parse('sms:$phoneNumber');
      if (await canLaunchUrl(message)) {
        launchUrl(message);
      } else {
        throw clientName;
      }
    } on Exception {
      _showErrorToast("Can't send message to $clientName");
    }
  }



  Future openWhatsApp(String phone) async {
    var androidUrl = "whatsapp://send?phone=$phone";
    var iosUrl = "https://wa.me/$phone";

    try {
      if (Platform.isIOS) {
        await _launchSocialMediaAppIfInstalled(url: iosUrl);
      } else {
        await _launchSocialMediaAppIfInstalled(url: androidUrl);
      }
    } on Exception {
      _showErrorToast("Can't open  whatsapp");
    }
  }
  Future lunchUrl(String url) async {
    try {
      await _launchSocialMediaAppIfInstalled(
        url: url,
      );
    } on Exception {
      _showErrorToast("Can't open $url");
    }
  }


  Future _launchSocialMediaAppIfInstalled({
    required String url,
  }) async {
    final uri = Uri.parse(url);
    try {
      bool launched = await launchUrl(uri,
          mode: LaunchMode.platformDefault); // Launch the app if installed!

      if (!launched) {
        launchUrl(uri); // Launch web view if app is not installed!
      }
    } catch (e) {
      rethrow; // Launch web view if app is not installed!
    }
  }


}
