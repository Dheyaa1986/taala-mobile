/// Production API host (VPS — https://api.taal1.com).
class ApiBaseConfig {
  ApiBaseConfig._();

  static const String primaryBase = 'https://api.taal1.com';

  static String get activeBase => primaryBase;

  static String absolutePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final uri = Uri.parse(path);
      final normalizedPath = uri.hasQuery
          ? '${uri.path}?${uri.query}'
          : uri.path;
      return '$primaryBase$normalizedPath';
    }
    return path;
  }
}
