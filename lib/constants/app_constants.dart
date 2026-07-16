class AppConstants {
  static const String appName = 'LetzGo';
  static const String appVersion = '1.0.0';

  /// Base URL for API requests.
  ///
  /// Defaults to the production VPS. Override at build time for local dev via
  /// `--dart-define=BASE_URL=http://192.168.x.x:8000/api/v1/` (use your
  /// machine's LAN IP for physical Android devices, or `http://10.0.2.2:8000/api/v1/`
  /// for the Android emulator).
  static String get baseUrl {
    const override = String.fromEnvironment('BASE_URL');
    if (override.isNotEmpty) return override;
    return 'http://159.198.39.126/api/v1/';
    // return 'http://10.0.2.2:8000/api/v1/';
  }

  /// Server origin (scheme://host:port) derived from [baseUrl], used to
  /// resolve server-relative media paths like `/uploads/avatars/x.jpg`.
  static String get serverOrigin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  /// Resolve a media path returned by the API into a full URL.
  /// Absolute URLs (e.g. Cloudinary) pass through unchanged.
  static String? resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$serverOrigin$path';
  }

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const double defaultSearchRadiusMeters = 500;
  static const int maxPingExpiryMinutes = 120;
  static const int defaultPingExpiryMinutes = 30;
  static const int maxPassengerLimit = 5;
  static const double maxFare = 5000;
}
