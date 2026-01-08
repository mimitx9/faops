import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangePasswordUseCase {
  final ProfileRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(ChangePasswordRequest request) {
    return _repository.changePassword(request);
  }
}





