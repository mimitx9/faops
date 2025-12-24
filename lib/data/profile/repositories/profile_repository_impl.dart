import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../domain/profile/entities/profile_entity.dart';
import '../../../domain/profile/repositories/profile_repository.dart';
import '../../../core/error/failures.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final model = await _remoteDataSource.getProfile();
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    UpdateProfileRequest request,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (request.fullName != null) data['full_name'] = request.fullName;
      if (request.phoneNumber != null) {
        data['phone_number'] = request.phoneNumber;
      }
      if (request.address != null) data['address'] = request.address;
      if (request.dateOfBirth != null) {
        data['date_of_birth'] = request.dateOfBirth!.toIso8601String();
      }
      if (request.gender != null) data['gender'] = request.gender;

      final model = await _remoteDataSource.updateProfile(data);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      await _remoteDataSource.changePassword(
        request.currentPassword,
        request.newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String imagePath) async {
    try {
      final avatarUrl = await _remoteDataSource.uploadAvatar(imagePath);
      return Right(avatarUrl);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return const Failure.unauthorized(message: 'Unauthorized');
        case 403:
          return const Failure.forbidden(message: 'Forbidden');
        case 404:
          return const Failure.notFound(message: 'Not Found');
        case 408:
          return const Failure.timeout(message: 'Request Timeout');
        case 422:
          return Failure.validation(
            message: error.response?.data['message'] ?? 'Validation Error',
            errors: error.response?.data['errors'],
          );
        default:
          return Failure.server(
            message: error.response?.data['message'] ?? 'Server Error',
            statusCode: error.response?.statusCode,
          );
      }
    }
    return Failure.network(message: error.toString());
  }
}

