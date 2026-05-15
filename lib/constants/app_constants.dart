class AppConstants {
  static const String appName = 'LetzGo';
  static const String appVersion = '1.0.0';
  static const String baseUrl =
      'http://10.0.2.2:8001/api/v1/'; // Android emulator
  static const String iosBaseUrl = 'http://localhost:8001/api/v1/';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const double defaultSearchRadiusMeters = 500;
  static const int maxPingExpiryMinutes = 120;
  static const int defaultPingExpiryMinutes = 30;
  static const int maxPassengerLimit = 5;
  static const double maxFare = 5000;
}
