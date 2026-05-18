import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  late final Dio _dio;
  String? _authToken;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  // ============= Auth Endpoints =============

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String phone,
    required String name,
    String? gender,
    String? avatarUrl,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'phone': phone,
        'name': name,
        'gender': gender,
        'avatar_url': avatarUrl,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get('/users/me');
    return response.data;
  }

  // ============= User Endpoints =============

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/me', data: data);
    return response.data;
  }

  // ============= Ping / Ride Endpoints =============

  Future<Map<String, dynamic>> createPing(Map<String, dynamic> data) async {
    final response = await _dio.post('/pings', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getNearbyPings({
    required double lat,
    required double lng,
    double radius = 500.0,
    String? gender,
  }) async {
    final queryParams = {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radius.toString(),
    };
    if (gender != null) queryParams['gender'] = gender;
    final response = await _dio.get(
      '/pings/nearby',
      queryParameters: queryParams,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMyPings() async {
    final response = await _dio.get('/pings/me');
    return response.data;
  }

  Future<Map<String, dynamic>> getPingDetails(String pingId) async {
    final response = await _dio.get('/pings/$pingId');
    return response.data;
  }

  Future<Map<String, dynamic>> updatePing(
    String pingId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch('/pings/$pingId', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> cancelPing(String pingId) async {
    final response = await _dio.post('/pings/$pingId/cancel');
    return response.data;
  }

  Future<Map<String, dynamic>> deleteExpiredPings() async {
    final response = await _dio.delete('/pings/expired');
    return response.data;
  }

  Future<Map<String, dynamic>> findRides({
    required double currentLat,
    required double currentLng,
    required double destinationLat,
    required double destinationLng,
    double radius = 500.0,
  }) async {
    final response = await _dio.post(
      '/rides/find',
      data: {
        'current_lat': currentLat,
        'current_lng': currentLng,
        'destination_lat': destinationLat,
        'destination_lng': destinationLng,
        'radius': radius,
      },
    );
    return response.data;
  }

  // ============= Match Endpoints =============

  Future<Map<String, dynamic>> requestMatch(String rideId) async {
    final response = await _dio.post(
      '/matches/request',
      data: {'ride_id': rideId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMatchRequests(String rideId) async {
    final response = await _dio.get('/matches/requests/$rideId');
    return response.data;
  }

  Future<Map<String, dynamic>> respondToRequest(
    String requestId,
    String status,
  ) async {
    final response = await _dio.post('/matches/requests/$requestId/$status');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyMatches() async {
    final response = await _dio.get('/matches/my');
    return response.data;
  }

  Future<Map<String, dynamic>> getMatchDetails(String matchId) async {
    final response = await _dio.get('/matches/$matchId');
    return response.data;
  }

  Future<Map<String, dynamic>> startMatch(String matchId) async {
    final response = await _dio.post('/matches/$matchId/start');
    return response.data;
  }

  Future<Map<String, dynamic>> completeMatch(
    String matchId,
    double finalFare,
  ) async {
    final response = await _dio.post(
      '/matches/$matchId/complete',
      data: {'final_fare': finalFare},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> cancelMatch(String matchId) async {
    final response = await _dio.post('/matches/$matchId/cancel');
    return response.data;
  }

  // ============= Chat Endpoints =============

  Future<Map<String, dynamic>> sendMessage(
    String matchId,
    String content,
  ) async {
    final response = await _dio.post(
      '/chat/$matchId',
      data: {'content': content},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMessages(String matchId) async {
    final response = await _dio.get('/chat/$matchId');
    return response.data;
  }

  // ============= Notification Endpoints =============

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _dio.get('/notifications');
    return response.data;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _dio.post('/notifications/$notificationId/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.post('/notifications/read-all');
  }

  // ============= Fare Split Endpoints =============

  Future<Map<String, dynamic>> getFareSplit(String matchId) async {
    final response = await _dio.get('/fare/$matchId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateFareSplit(
    String matchId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post('/fare/$matchId', data: data);
    return response.data;
  }

  // ============= Rating Endpoints =============

  Future<Map<String, dynamic>> submitRating(
    String matchId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post('/ratings/$matchId', data: data);
    return response.data;
  }

  // ============= Report Endpoints =============

  Future<Map<String, dynamic>> submitReport(Map<String, dynamic> data) async {
    final response = await _dio.post('/reports', data: data);
    return response.data;
  }

  // ============= Geocode Endpoints =============

  Future<List<Map<String, dynamic>>> searchLocation(
    String query, {
    int limit = 5,
  }) async {
    final response = await _dio.get(
      '/geocode/search',
      queryParameters: {'q': query, 'limit': limit},
    );
    return List<Map<String, dynamic>>.from(response.data['results'] ?? []);
  }

  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final response = await _dio.get(
      '/geocode/reverse',
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
    );
    return response.data['display_name'] as String;
  }
}
