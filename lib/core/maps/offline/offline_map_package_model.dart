class OfflineMapPackageModel {
  const OfflineMapPackageModel({
    required this.governorateId,
    required this.governorateNameAr,
    required this.governorateNameEn,
    required this.mapSlug,
    required this.version,
    required this.fileSizeBytes,
    required this.downloadUrl,
    required this.minZoom,
    required this.maxZoom,
    required this.priority,
    this.sha256,
    this.bboxSouth,
    this.bboxNorth,
    this.bboxWest,
    this.bboxEast,
  });

  final String governorateId;
  final String governorateNameAr;
  final String governorateNameEn;
  final String mapSlug;
  final int version;
  final int fileSizeBytes;
  final String downloadUrl;
  final int minZoom;
  final int maxZoom;
  final int priority;
  final String? sha256;
  final double? bboxSouth;
  final double? bboxNorth;
  final double? bboxWest;
  final double? bboxEast;

  factory OfflineMapPackageModel.fromJson(Map<String, dynamic> json) {
    return OfflineMapPackageModel(
      governorateId: json['governorateId']?.toString() ?? '',
      governorateNameAr: json['governorateNameAr']?.toString() ?? '',
      governorateNameEn: json['governorateNameEn']?.toString() ?? '',
      mapSlug: json['mapSlug']?.toString() ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      minZoom: (json['minZoom'] as num?)?.toInt() ?? 10,
      maxZoom: (json['maxZoom'] as num?)?.toInt() ?? 14,
      priority: (json['priority'] as num?)?.toInt() ?? 99,
      sha256: json['sha256']?.toString(),
      bboxSouth: (json['bboxSouth'] as num?)?.toDouble(),
      bboxNorth: (json['bboxNorth'] as num?)?.toDouble(),
      bboxWest: (json['bboxWest'] as num?)?.toDouble(),
      bboxEast: (json['bboxEast'] as num?)?.toDouble(),
    );
  }

  bool contains(double lat, double lng) {
    if (bboxSouth == null ||
        bboxNorth == null ||
        bboxWest == null ||
        bboxEast == null) {
      return false;
    }
    return lat >= bboxSouth! &&
        lat <= bboxNorth! &&
        lng >= bboxWest! &&
        lng <= bboxEast!;
  }
}

enum OfflineMapLocalStatus {
  pending,
  downloading,
  ready,
  failed,
}

class OfflineMapLocalRecord {
  const OfflineMapLocalRecord({
    required this.governorateId,
    required this.mapSlug,
    required this.version,
    required this.status,
    this.localPath,
    this.downloadedBytes = 0,
    this.updatedAt,
  });

  final String governorateId;
  final String mapSlug;
  final int version;
  final OfflineMapLocalStatus status;
  final String? localPath;
  final int downloadedBytes;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'governorateId': governorateId,
        'mapSlug': mapSlug,
        'version': version,
        'status': status.name,
        'localPath': localPath,
        'downloadedBytes': downloadedBytes,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory OfflineMapLocalRecord.fromJson(Map<String, dynamic> json) {
    return OfflineMapLocalRecord(
      governorateId: json['governorateId']?.toString() ?? '',
      mapSlug: json['mapSlug']?.toString() ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      status: OfflineMapLocalStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => OfflineMapLocalStatus.pending,
      ),
      localPath: json['localPath']?.toString(),
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  OfflineMapLocalRecord copyWith({
    int? version,
    OfflineMapLocalStatus? status,
    String? localPath,
    int? downloadedBytes,
    DateTime? updatedAt,
  }) {
    return OfflineMapLocalRecord(
      governorateId: governorateId,
      mapSlug: mapSlug,
      version: version ?? this.version,
      status: status ?? this.status,
      localPath: localPath ?? this.localPath,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OfflineMapsSummary {
  const OfflineMapsSummary({
    required this.readyCount,
    required this.totalCount,
    required this.totalBytes,
    this.lastUpdatedAt,
  });

  final int readyCount;
  final int totalCount;
  final int totalBytes;
  final DateTime? lastUpdatedAt;
}
