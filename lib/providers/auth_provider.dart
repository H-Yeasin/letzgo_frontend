import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isNewUser;
  final User? user;
  final String? error;
  final String? pendingPhone;
  final String? debugOtp;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isNewUser = false,
    this.user,
    this.error,
    this.pendingPhone,
    this.debugOtp,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isNewUser,
    User? user,
    String? error,
    String? pendingPhone,
    String? debugOtp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isNewUser: isNewUser ?? this.isNewUser,
      user: user ?? this.user,
      error: error,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      debugOtp: debugOtp,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(const AuthState());

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final phone = prefs.getString('phone');

    if (token != null && phone != null) {
      _api.setAuthToken(token);
      try {
        final data = await _api.getMyProfile();
        final user = User.fromJson(data);
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isNewUser: !user.isOnboardingComplete,
        );
      } catch (e) {
        // Token expired or invalid
        await _clearAuth();
      }
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null, pendingPhone: phone);
    try {
      final data = await _api.sendOtp(phone);
      final debugOtp = data['debug_otp'] as String?;
      state = state.copyWith(isLoading: false, debugOtp: debugOtp);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP. Please try again.',
      );
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.verifyOtp(phone, otp);
      final token = data['access_token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final isNew = data['is_new_user'] as bool? ?? false;

      // Save auth token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('phone', phone);

      _api.setAuthToken(token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        isNewUser: isNew || !user.isOnboardingComplete,
        pendingPhone: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid OTP. Please try again.',
      );
    }
  }

  Future<void> completeProfile({
    required String name,
    String? gender,
    String? avatarUrl,
  }) async {
    final phone = state.pendingPhone ?? state.user?.phone;
    if (phone == null) {
      state = state.copyWith(error: 'Phone number not found.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.completeRegistration(
        phone: phone,
        name: name,
        gender: gender,
        avatarUrl: avatarUrl,
      );
      final token = data['access_token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _api.setAuthToken(token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isNewUser: false,
        user: user,
        pendingPhone: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create profile. Please try again.',
      );
    }
  }

  Future<bool> updateProfile({
    required String name,
    String? gender,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updateData = <String, dynamic>{
        'name': name,
        'is_onboarding_complete': true,
      };
      if (gender != null) updateData['gender'] = gender;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      final data = await _api.updateProfile(updateData);
      final updatedUser = User.fromJson(data);

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
        isNewUser: !updatedUser.isOnboardingComplete,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuth();
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('phone');
    _api.removeAuthToken();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
