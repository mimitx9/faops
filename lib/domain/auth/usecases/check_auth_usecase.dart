import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class CheckAuthUseCase {
  final AuthRepository _repository;

  CheckAuthUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.isAuthenticated();
  }
}



