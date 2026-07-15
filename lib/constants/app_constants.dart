import 'dart:io' show Platform;

class AppConstants {
  static const String appName = 'LetzGo';
  static const String appVersion = '1.0.0';

  /// Base URL for API requests.
  ///
  /// 1. Override at build time via `--dart-define=BASE_URL=http://192.168.x.x:8000/api/v1/`
  ///    (use your machine's LAN IP for physical Android devices).
  /// 2. Defaults to [Platform]-aware fallback:
  ///    - Android emulator → `http://10.0.2.2:8000/api/v1/`
  ///    - iOS simulator / others → `http://localhost:8000/api/v1/`
  static String get baseUrl {
    const override = String.fromEnvironment('BASE_URL');
    if (override.isNotEmpty) return override;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/';
    return 'http://localhost:8000/api/v1/';
  }

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const double defaultSearchRadiusMeters = 500;
  static const int maxPingExpiryMinutes = 120;
  static const int defaultPingExpiryMinutes = 30;
  static const int maxPassengerLimit = 5;
  static const double maxFare = 5000;
}
