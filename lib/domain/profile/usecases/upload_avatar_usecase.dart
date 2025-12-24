import '../repositories/profile_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class UploadAvatarUseCase {
  final ProfileRepository _repository;

  UploadAvatarUseCase(this._repository);

  Future<Either<Failure, String>> call(String imagePath) {
    return _repository.uploadAvatar(imagePath);
  }
}

