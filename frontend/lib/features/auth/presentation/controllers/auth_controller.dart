import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/network_exceptions.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginUseCase(repo);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  return AuthController(loginUseCase);
});

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;

  AuthController(this.loginUseCase) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await loginUseCase.execute(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      if (e is NetworkExceptions) {
        state = AuthError(e.message);
      } else {
        state = AuthError('Unknown error');
      }
    }
  }
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
