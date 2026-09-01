import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:taal/core/maps/offline/offline_map_package_model.dart';

class MapOfflineRepository {
  static const _recordsFileName = 'offline_map_records.json';

  Future<File> _recordsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'offline_maps', _recordsFileName));
  }

  Future<Map<String, OfflineMapLocalRecord>> loadRecords() async {
    try {
      final file = await _recordsFile();
      if (!await file.exists()) {
        return {};
      }
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return raw.map(
        (key, value) => MapEntry(
          key,
          OfflineMapLocalRecord.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveRecords(Map<String, OfflineMapLocalRecord> records) async {
    final file = await _recordsFile();
    await file.parent.create(recursive: true);
    final encoded = records.map((key, value) => MapEntry(key, value.toJson()));
    await file.writeAsString(jsonEncode(encoded));
  }

  Future<File> mapFileForSlug(String mapSlug, int version) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'offline_maps'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File(p.join(folder.path, '$mapSlug-v$version.mbtiles'));
  }

  Future<String?> findReadyMapPathForLocation(double lat, double lng) async {
    final records = await loadRecords();
    for (final record in records.values) {
      if (record.status != OfflineMapLocalStatus.ready ||
          record.localPath == null) {
        continue;
      }
      if (await File(record.localPath!).exists()) {
        return record.localPath;
      }
    }
    return null;
  }

  Future<OfflineMapsSummary> summary(List<OfflineMapPackageModel> manifest) async {
    final records = await loadRecords();
    var readyCount = 0;
    var totalBytes = 0;
    DateTime? lastUpdatedAt;

    for (final record in records.values) {
      if (record.status == OfflineMapLocalStatus.ready &&
          record.localPath != null &&
          await File(record.localPath!).exists()) {
        readyCount++;
        totalBytes += await File(record.localPath!).length();
        if (record.updatedAt != null &&
            (lastUpdatedAt == null || record.updatedAt!.isAfter(lastUpdatedAt))) {
          lastUpdatedAt = record.updatedAt;
        }
      }
    }

    return OfflineMapsSummary(
      readyCount: readyCount,
      totalCount: manifest.length,
      totalBytes: totalBytes,
      lastUpdatedAt: lastUpdatedAt,
    );
  }
}
