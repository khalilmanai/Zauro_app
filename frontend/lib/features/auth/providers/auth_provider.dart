import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// Auth State Notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _initializeAuth();
    return AuthState.initial();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    state = AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final isAuth = await repository.isAuthenticated();

      if (isAuth) {
        final user = await repository.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = AuthState.unauthenticated();
        }
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  // Register new user
  Future<void> register({
    required String email,
    String? phone,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.register(
        email: email,
        phone: phone,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Login user
  Future<void> login({required String email, required String password}) async {
    state = AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(email: email, password: password);

      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Clear error state
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getCurrentUser();

      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      // Don't change state on refresh error
    }
  }
}

// Password Reset State Notifier
@riverpod
class PasswordResetNotifier extends _$PasswordResetNotifier {
  @override
  PasswordResetState build() {
    return PasswordResetState.initial();
  }

  // Request password reset OTP
  Future<void> requestPasswordReset({String? email, String? phone}) async {
    state = PasswordResetState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final message = await repository.forgotPasswordRequest(
        email: email,
        phone: phone,
      );

      state = PasswordResetState.otpSent(message);
    } catch (e) {
      state = PasswordResetState.error(e.toString());
    }
  }

  // Verify OTP
  Future<void> verifyOtp({
    required String code,
    String? email,
    String? phone,
  }) async {
    state = PasswordResetState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final message = await repository.verifyOtp(
        code: code,
        email: email,
        phone: phone,
      );

      state = PasswordResetState.otpVerified(message);
    } catch (e) {
      state = PasswordResetState.error(e.toString());
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String code,
    required String newPassword,
    String? email,
    String? phone,
  }) async {
    state = PasswordResetState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final message = await repository.resetPassword(
        code: code,
        newPassword: newPassword,
        email: email,
        phone: phone,
      );

      state = PasswordResetState.passwordReset(message);
    } catch (e) {
      state = PasswordResetState.error(e.toString());
    }
  }

  // Clear state
  void clearState() {
    state = PasswordResetState.initial();
  }

  // Clear error
  void clearError() {
    if (state.hasError) {
      state = PasswordResetState.initial();
    }
  }
}

// Password Reset State
enum PasswordResetStatus {
  initial,
  loading,
  otpSent,
  otpVerified,
  passwordReset,
  error,
}

class PasswordResetState {
  final PasswordResetStatus status;
  final String? message;
  final String? error;
  final bool isLoading;

  const PasswordResetState({
    required this.status,
    this.message,
    this.error,
    this.isLoading = false,
  });

  factory PasswordResetState.initial() {
    return const PasswordResetState(
      status: PasswordResetStatus.initial,
      isLoading: false,
    );
  }

  factory PasswordResetState.loading() {
    return const PasswordResetState(
      status: PasswordResetStatus.loading,
      isLoading: true,
    );
  }

  factory PasswordResetState.otpSent(String message) {
    return PasswordResetState(
      status: PasswordResetStatus.otpSent,
      message: message,
      isLoading: false,
    );
  }

  factory PasswordResetState.otpVerified(String message) {
    return PasswordResetState(
      status: PasswordResetStatus.otpVerified,
      message: message,
      isLoading: false,
    );
  }

  factory PasswordResetState.passwordReset(String message) {
    return PasswordResetState(
      status: PasswordResetStatus.passwordReset,
      message: message,
      isLoading: false,
    );
  }

  factory PasswordResetState.error(String error) {
    return PasswordResetState(
      status: PasswordResetStatus.error,
      error: error,
      isLoading: false,
    );
  }

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    String? message,
    String? error,
    bool? isLoading,
  }) {
    return PasswordResetState(
      status: status ?? this.status,
      message: message ?? this.message,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasError => status == PasswordResetStatus.error && error != null;
  bool get isOtpSent => status == PasswordResetStatus.otpSent;
  bool get isOtpVerified => status == PasswordResetStatus.otpVerified;
  bool get isPasswordReset => status == PasswordResetStatus.passwordReset;
}
