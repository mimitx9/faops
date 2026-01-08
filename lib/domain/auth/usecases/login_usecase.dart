import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthEntity>> call(LoginRequest request) {
    return _repository.login(request);
  }
}





