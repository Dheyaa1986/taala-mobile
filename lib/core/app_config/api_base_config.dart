/// Runtime API host selection with Railway fallback when the custom domain fails.
class ApiBaseConfig {
  ApiBaseConfig._();

  static const String primaryBase = 'https://api.taal1.com';
  static const String fallbackBase =
      'https://taala-back-production.up.railway.app';

  static String _activeBase = primaryBase;

  static String get activeBase => _activeBase;

  static String? activateFallback() {
    if (_activeBase == primaryBase) {
      _activeBase = fallbackBase;
      return _activeBase;
    }
    return null;
  }

  static String absolutePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final uri = Uri.parse(path);
      final normalizedPath = uri.hasQuery
          ? '${uri.path}?${uri.query}'
          : uri.path;
      return '$_activeBase$normalizedPath';
    }
    return path;
  }
}
