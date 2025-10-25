// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'669cfc05aec095e95b4cd2f6612ca8082fd40069';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AuthState>;
String _$passwordResetNotifierHash() =>
    r'ff44fa0cb35ebe74094f3085ca8eba71bb93a9eb';

/// See also [PasswordResetNotifier].
@ProviderFor(PasswordResetNotifier)
final passwordResetNotifierProvider = AutoDisposeNotifierProvider<
    PasswordResetNotifier, PasswordResetState>.internal(
  PasswordResetNotifier.new,
  name: r'passwordResetNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$passwordResetNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PasswordResetNotifier = AutoDisposeNotifier<PasswordResetState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
