import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

// User Model
@JsonSerializable()
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isVerified;
  final String? avatarUrl;
  final String? country;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isVerified,
    this.avatarUrl,
    this.country,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    bool? isVerified,
    String? avatarUrl,
    String? country,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

// Auth Response
@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

// Register Request
@JsonSerializable()
class RegisterRequest {
  final String email;
  final String? phone;
  final String password;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? country;

  const RegisterRequest({
    required this.email,
    this.phone,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.country,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

// Login Request
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

// Refresh Token Response
@JsonSerializable()
class RefreshTokenResponse {
  final String accessToken;

  const RefreshTokenResponse({required this.accessToken});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}

// Forgot Password Request
@JsonSerializable()
class ForgotPasswordRequest {
  final String? email;
  final String? phone;

  const ForgotPasswordRequest({this.email, this.phone});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

// Verify OTP Request
@JsonSerializable()
class VerifyOtpRequest {
  final String code;
  final String? email;
  final String? phone;

  const VerifyOtpRequest({required this.code, this.email, this.phone});

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

// Reset Password Request
@JsonSerializable()
class ResetPasswordRequest {
  final String code;
  final String newPassword;
  final String? email;
  final String? phone;

  const ResetPasswordRequest({
    required this.code,
    required this.newPassword,
    this.email,
    this.phone,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.isLoading = false,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial, isLoading: false);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading, isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: false,
    );
  }

  factory AuthState.error(String error) {
    return AuthState(status: AuthStatus.error, error: error, isLoading: false);
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error && error != null;
}

// Avatar Model
@JsonSerializable()
class Avatar {
  final String id;
  final String name;
  final String imageUrl;
  final String category;

  const Avatar({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarToJson(this);
}

// Registration Step Enum
enum RegistrationStep {
  personalInfo,
  avatarSelection,
  accountDetails,
  termsAndConditions,
}

// Registration State
class RegistrationState {
  final RegistrationStep currentStep;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? country;
  final String? password;
  final String? confirmPassword;
  final Avatar? selectedAvatar;
  final bool agreeToTerms;
  final bool isLoading;

  const RegistrationState({
    this.currentStep = RegistrationStep.personalInfo,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.country,
    this.password,
    this.confirmPassword,
    this.selectedAvatar,
    this.agreeToTerms = false,
    this.isLoading = false,
  });

  RegistrationState copyWith({
    RegistrationStep? currentStep,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? country,
    String? password,
    String? confirmPassword,
    Avatar? selectedAvatar,
    bool? agreeToTerms,
    bool? isLoading,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get canProceedToNextStep {
    switch (currentStep) {
      case RegistrationStep.personalInfo:
        return firstName != null &&
            firstName!.isNotEmpty &&
            lastName != null &&
            lastName!.isNotEmpty;
      case RegistrationStep.avatarSelection:
        return selectedAvatar != null;
      case RegistrationStep.accountDetails:
        return email != null &&
            email!.isNotEmpty &&
            password != null &&
            password!.isNotEmpty &&
            confirmPassword != null &&
            confirmPassword!.isNotEmpty &&
            password == confirmPassword;
      case RegistrationStep.termsAndConditions:
        return agreeToTerms;
    }
  }

  bool get canGoToPreviousStep {
    return currentStep != RegistrationStep.personalInfo;
  }
}
