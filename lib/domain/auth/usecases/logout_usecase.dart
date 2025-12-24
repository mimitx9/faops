import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}

