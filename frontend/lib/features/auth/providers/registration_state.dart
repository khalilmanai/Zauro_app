import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_state.g.dart';

@immutable
class RegistrationState {
  final String? email;
  final String? phone;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? country;
  final bool isLoading;
  final String? error;

  const RegistrationState({
    this.email,
    this.phone,
    this.password,
    this.firstName,
    this.lastName,
    this.country,
    this.isLoading = false,
    this.error,
  });

  RegistrationState copyWith({
    String? email,
    String? phone,
    String? password,
    String? firstName,
    String? lastName,
    String? country,
    bool? isLoading,
    String? error,
  }) {
    return RegistrationState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isValid {
    return email != null &&
        email!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty &&
        firstName != null &&
        firstName!.isNotEmpty &&
        lastName != null &&
        lastName!.isNotEmpty;
  }
}

@Riverpod(keepAlive: true)
class RegistrationStateNotifier extends _$RegistrationStateNotifier {
  @override
  RegistrationState build() {
    return const RegistrationState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }

  void updateCountry(String country) {
    state = state.copyWith(country: country);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = const RegistrationState();
  }
}
