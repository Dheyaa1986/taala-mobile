import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/routes/app_router.dart';
import '../app_config/app_strings.dart';
import '../helpers/messages.dart';
import '../helpers/phone_launcher_helper.dart';
import '../maps/map_app_picker.dart';

class CustomLauncher {
  void _showErrorToast(String message) {
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context != null) {
      AppMessages.showError(context, message);
    }
  }

  BuildContext? get _context => AppRouter.appNavigatorKey.currentContext;

  Future<AvailableMap?> _pickMapApp() async {
    final context = _context;
    if (context == null) return null;

    final maps = await MapLauncher.installedMaps;
    if (maps.isEmpty) {
      _showErrorToast(AppStrings.noMapsInstalled.tr());
      return null;
    }
    if (maps.length == 1) return maps.first;

    final refreshedContext = _context;
    if (refreshedContext == null || !refreshedContext.mounted) return null;

    return MapAppPicker.pick(refreshedContext);
  }

  Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorToast("Can't open link");
      }
    } catch (_) {
      _showErrorToast("Can't open link");
    }
  }

  Future<void> openMaps(
    double lat,
    double lng,
    String address,
  ) async {
    try {
      final map = await _pickMapApp();
      if (map == null) return;

      await map.showMarker(
        coords: Coords(lat, lng),
        title: address,
      );
    } catch (_) {
      _showErrorToast(AppStrings.cantOpenMaps.tr());
    }
  }

  Future<void> openDirections({
    required double destinationLat,
    required double destinationLng,
    String? destinationTitle,
    double? originLat,
    double? originLng,
    String? originTitle,
  }) async {
    try {
      final map = await _pickMapApp();
      if (map == null) return;

      await map.showDirections(
        destination: Coords(destinationLat, destinationLng),
        destinationTitle: destinationTitle,
        origin: originLat != null && originLng != null
            ? Coords(originLat, originLng)
            : null,
        originTitle: originTitle,
        directionsMode: DirectionsMode.driving,
      );
    } catch (_) {
      _showErrorToast(AppStrings.cantOpenMaps.tr());
    }
  }

  Future<void> openFacebookPage(String username) async {
    try {
      await _launchUrl(
        Uri.parse('https://www.facebook.com/$username'),
      );
    } on Exception {
      _showErrorToast("Can't open facebook");
    }
  }

  Future<void> call(String phoneNumber, String clientName) async {
    try {
      final normalized = PhoneLauncherHelper.forTel(phoneNumber);
      final call = Uri.parse('tel:$normalized');
      if (await canLaunchUrl(call)) {
        await launchUrl(call, mode: LaunchMode.externalApplication);
      } else {
        throw clientName;
      }
    } on Exception {
      _showErrorToast("Can't call $clientName");
    }
  }

  Future<void> sendMessage(String phoneNumber, String clientName) async {
    try {
      final normalized = PhoneLauncherHelper.forTel(phoneNumber);
      final message = Uri.parse('sms:$normalized');
      if (await canLaunchUrl(message)) {
        await launchUrl(message, mode: LaunchMode.externalApplication);
      } else {
        throw clientName;
      }
    } on Exception {
      _showErrorToast("Can't send message to $clientName");
    }
  }

  Future<void> openWhatsApp(String phone) async {
    final digits = PhoneLauncherHelper.forWhatsApp(phone);
    if (digits.isEmpty) {
      _showErrorToast("Can't open whatsapp");
      return;
    }

    final webUrl = Uri.parse('https://wa.me/$digits');
    final appUrl = Uri.parse('whatsapp://send?phone=$digits');

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(appUrl)) {
          await launchUrl(appUrl, mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        if (await canLaunchUrl(appUrl)) {
          await launchUrl(appUrl, mode: LaunchMode.externalApplication);
          return;
        }
      }

      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        _showErrorToast("Can't open whatsapp");
      }
    }
  }

  Future<void> lunchUrl(String url) async {
    try {
      await _launchUrl(Uri.parse(url));
    } on Exception {
      _showErrorToast("Can't open $url");
    }
  }

  Future<void> _launchUrl(Uri uri) async {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw Exception('launch failed');
    }
  }
}
