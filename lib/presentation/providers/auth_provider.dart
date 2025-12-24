import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/auth/entities/auth_entity.dart';
import '../../../domain/auth/usecases/login_usecase.dart';
import '../../../domain/auth/usecases/logout_usecase.dart';
import '../../../domain/auth/usecases/check_auth_usecase.dart';
import '../../../core/error/failures.dart';
import 'providers_setup.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  LoginUseCase? _loginUseCase;
  LogoutUseCase? _logoutUseCase;
  CheckAuthUseCase? _checkAuthUseCase;

  @override
  Future<bool> build() async {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _checkAuthUseCase = ref.read(checkAuthUseCaseProvider);

    final result = await _checkAuthUseCase!();
    return result.fold(
      (failure) => false,
      (isAuthenticated) => isAuthenticated,
    );
  }

  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    final request = LoginRequest(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    final result = await _loginUseCase!(request);
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (authEntity) {
        state = const AsyncValue.data(true);
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final result = await _logoutUseCase!();
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (_) {
        state = const AsyncValue.data(false);
      },
    );
  }
}


