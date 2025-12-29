import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call(UpdateProfileRequest request) {
    return _repository.updateProfile(request);
  }
}



