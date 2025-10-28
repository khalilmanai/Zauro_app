import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> execute(String email, String password) async {
    final authResponse =
        await repository.login(email: email, password: password);
    return UserModel(
      id: authResponse.user.id,
      email: authResponse.user.email,
      firstName: authResponse.user.firstName,
      lastName: authResponse.user.lastName,
      role: authResponse.user.role,
      isVerified: authResponse.user.isVerified,
      lastLoginAt: authResponse.user.lastLoginAt,
      country: authResponse.user.country,
    );
  }
}
