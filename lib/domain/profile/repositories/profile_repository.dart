import '../entities/profile_entity.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(UpdateProfileRequest request);
  Future<Either<Failure, void>> changePassword(ChangePasswordRequest request);
  Future<Either<Failure, String>> uploadAvatar(String imagePath);
}



