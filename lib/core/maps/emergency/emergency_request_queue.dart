import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EmergencyRequestPayload {
  EmergencyRequestPayload({
    required this.clientRequestId,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.serviceTypeId,
    required this.latitude,
    required this.longitude,
    this.address,
    this.profileAddress,
    this.description,
    this.providerId,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now().toUtc();

  final String clientRequestId;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String serviceTypeId;
  final double latitude;
  final double longitude;
  final String? address;
  final String? profileAddress;
  final String? description;
  final String? providerId;
  final DateTime queuedAt;

  Map<String, dynamic> toJson() => {
        'clientRequestId': clientRequestId,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'serviceTypeId': serviceTypeId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'profileAddress': profileAddress,
        'description': description,
        'providerId': providerId,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory EmergencyRequestPayload.fromJson(Map<String, dynamic> json) {
    return EmergencyRequestPayload(
      clientRequestId: json['clientRequestId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      serviceTypeId: json['serviceTypeId']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString(),
      profileAddress: json['profileAddress']?.toString(),
      description: json['description']?.toString(),
      providerId: json['providerId']?.toString(),
      queuedAt: DateTime.tryParse(json['queuedAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toHelpRequestBody() => {
        'clientRequestId': clientRequestId,
        'queuedAt': queuedAt.toIso8601String(),
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'serviceTypeId': serviceTypeId,
        'clientLatitude': latitude,
        'clientLongitude': longitude,
        if (profileAddress != null && profileAddress!.trim().isNotEmpty)
          'address': profileAddress,
        if (address != null && address!.trim().isNotEmpty)
          'clientAddress': address,
        if (description != null && description!.trim().isNotEmpty)
          'description': description,
        if (providerId != null && providerId!.isNotEmpty)
          'providerId': providerId,
      };

  static EmergencyRequestPayload create({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String serviceTypeId,
    required double latitude,
    required double longitude,
    String? address,
    String? profileAddress,
    String? description,
    String? providerId,
  }) {
    return EmergencyRequestPayload(
      clientRequestId: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      password: password,
      serviceTypeId: serviceTypeId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      profileAddress: profileAddress,
      description: description,
      providerId: providerId,
    );
  }
}

class EmergencyRequestQueue {
  static const _fileName = 'emergency_request_queue.json';

  Future<List<EmergencyRequestPayload>> loadAll() async {
    try {
      final file = await _queueFile();
      if (!await file.exists()) return [];
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return raw
          .map(
            (item) => EmergencyRequestPayload.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueue(EmergencyRequestPayload payload) async {
    final items = await loadAll();
    if (items.any((item) => item.clientRequestId == payload.clientRequestId)) {
      return;
    }
    items.add(payload);
    await _saveAll(items);
  }

  Future<void> remove(String clientRequestId) async {
    final items = await loadAll();
    items.removeWhere((item) => item.clientRequestId == clientRequestId);
    await _saveAll(items);
  }

  Future<void> _saveAll(List<EmergencyRequestPayload> items) async {
    final file = await _queueFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<File> _queueFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'offline_emergency', _fileName));
  }
}
