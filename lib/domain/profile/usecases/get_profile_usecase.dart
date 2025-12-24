import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call() {
    return _repository.getProfile();
  }
}

