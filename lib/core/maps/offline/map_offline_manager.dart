import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/helpers/connectivity_helper.dart';
import 'package:taal/core/maps/offline/map_offline_repository.dart';
import 'package:taal/core/maps/offline/offline_map_package_model.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/network/network_request.dart';

class MapOfflineManager {
  MapOfflineManager(this._dioService, this._repository);

  final DioService _dioService;
  final MapOfflineRepository _repository;

  List<OfflineMapPackageModel> _manifest = [];
  bool _syncInProgress = false;

  List<OfflineMapPackageModel> get manifest => List.unmodifiable(_manifest);

  Future<void> _loadManifest() async {
    final json = await _dioService.callApi<Map<String, dynamic>>(
      NetworkRequest(
        AppUrls.offlineMapsManifest,
        method: RequestMethod.get,
        requestWithOutToken: true,
      ),
    );
    final response = json['response'] as Map<String, dynamic>? ?? json;
    final packages = (response['packages'] as List<dynamic>? ?? [])
        .map(
          (item) => OfflineMapPackageModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    _manifest = packages;
    await _ensureRecordsForManifest(packages);
  }

  Future<void> syncWhenOnline({String? priorityGovernorateId}) async {
    if (_syncInProgress || !await ConnectivityHelper.connected) {
      return;
    }
    _syncInProgress = true;
    try {
      await _loadManifest();
      final packages = _manifest;

      if (priorityGovernorateId != null) {
        final priority = packages.where(
          (item) => item.governorateId == priorityGovernorateId,
        );
        for (final pkg in priority) {
          await _downloadIfNeeded(pkg);
        }
      }

      for (final pkg in packages) {
        if (!await ConnectivityHelper.connected) break;
        await _downloadIfNeeded(pkg);
      }
    } catch (_) {
      // Silent background sync — online tiles remain available.
    } finally {
      _syncInProgress = false;
    }
  }

  Future<List<String>> readyMapPaths() async {
    final records = await _repository.loadRecords();
    final paths = <String>[];
    for (final record in records.values) {
      final path = record.localPath;
      if (record.status != OfflineMapLocalStatus.ready || path == null) {
        continue;
      }
      if (await File(path).exists()) {
        paths.add(path);
      }
    }
    return paths;
  }

  Future<void> downloadAllIraqMaps({
    void Function(int done, int total, String name)? onProgress,
  }) async {
    if (!await ConnectivityHelper.connected) {
      throw StateError('offline');
    }
    while (_syncInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    _syncInProgress = true;
    try {
      await _loadManifest();
      final packages = _manifest;
      if (packages.isEmpty) {
        throw StateError('No Iraq map packages available');
      }
      var done = 0;
      for (final pkg in packages) {
        final name = pkg.governorateNameAr.isEmpty
            ? pkg.mapSlug
            : pkg.governorateNameAr;
        onProgress?.call(done, packages.length, name);
        await _downloadIfNeeded(pkg);
        done++;
        onProgress?.call(done, packages.length, name);
      }
    } finally {
      _syncInProgress = false;
    }
  }

  Future<String?> localMapPathFor(double lat, double lng) async {
    final records = await _repository.loadRecords();
    for (final pkg in _manifest) {
      if (!pkg.contains(lat, lng)) continue;
      final record = records[pkg.governorateId];
      if (record?.status == OfflineMapLocalStatus.ready &&
          record?.localPath != null) {
        return record!.localPath;
      }
    }

    for (final record in records.values) {
      if (record.status == OfflineMapLocalStatus.ready &&
          record.localPath != null) {
        return record.localPath;
      }
    }
    return null;
  }

  Future<OfflineMapsSummary> getSummary() async {
    if (_manifest.isEmpty) {
      await syncWhenOnline();
    }
    return _repository.summary(_manifest);
  }

  Future<void> _ensureRecordsForManifest(
    List<OfflineMapPackageModel> packages,
  ) async {
    final records = await _repository.loadRecords();
    for (final pkg in packages) {
      final existing = records[pkg.governorateId];
      if (existing == null) {
        records[pkg.governorateId] = OfflineMapLocalRecord(
          governorateId: pkg.governorateId,
          mapSlug: pkg.mapSlug,
          version: pkg.version,
          status: OfflineMapLocalStatus.pending,
        );
        continue;
      }
      if (existing.version < pkg.version) {
        records[pkg.governorateId] = existing.copyWith(
          version: pkg.version,
          status: OfflineMapLocalStatus.pending,
          localPath: null,
          downloadedBytes: 0,
        );
      }
    }
    await _repository.saveRecords(records);
  }

  Future<void> _downloadIfNeeded(OfflineMapPackageModel pkg) async {
    final records = await _repository.loadRecords();
    final current = records[pkg.governorateId];
    if (current == null) return;

    final targetFile =
        await _repository.mapFileForSlug(pkg.mapSlug, pkg.version);
    if (current.status == OfflineMapLocalStatus.ready &&
        current.localPath != null &&
        await targetFile.exists() &&
        current.version >= pkg.version) {
      return;
    }

    records[pkg.governorateId] = current.copyWith(
      status: OfflineMapLocalStatus.downloading,
      version: pkg.version,
    );
    await _repository.saveRecords(records);

    try {
      final dio = Dio(
        BaseOptions(
          headers: const {
            'Accept-Language': 'ar',
            'time-zone': 'Asia/Baghdad',
          },
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      var startByte = 0;
      if (await targetFile.exists()) {
        startByte = await targetFile.length();
      }

      final response = await dio.get<List<int>>(
        pkg.downloadUrl,
        options: Options(
          headers: startByte > 0 ? {'Range': 'bytes=$startByte-'} : null,
          validateStatus: (status) =>
              status != null && (status == 200 || status == 206),
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Empty offline map response');
      }

      if (startByte > 0) {
        await targetFile.writeAsBytes(bytes, mode: FileMode.append);
      } else {
        await targetFile.writeAsBytes(bytes, flush: true);
      }

      records[pkg.governorateId] = current.copyWith(
        status: OfflineMapLocalStatus.ready,
        version: pkg.version,
        localPath: targetFile.path,
        downloadedBytes: await targetFile.length(),
        updatedAt: DateTime.now().toUtc(),
      );
      await _repository.saveRecords(records);
    } catch (_) {
      records[pkg.governorateId] = current.copyWith(
        status: OfflineMapLocalStatus.failed,
      );
      await _repository.saveRecords(records);
    }
  }
}
