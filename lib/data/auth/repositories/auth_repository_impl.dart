import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../domain/auth/entities/auth_entity.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../core/error/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../profile/datasources/profile_remote_datasource.dart';
import '../../profile/models/profile_model.dart';
import '../models/auth_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final ProfileRemoteDataSource _profileDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._profileDataSource,
    this._prefs,
  );

  @override
  Future<Either<Failure, AuthEntity>> login(LoginRequest request) async {
    try {
      // Login với username (phone number)
      final model = await _remoteDataSource.login(
        request.email, // Sử dụng email field để chứa username/phone
        request.password,
      );
      
      // Lưu token
      await _prefs.setString('auth_token', model.token);

      // Lấy profile sau khi login thành công
      final profileModel = await _profileDataSource.getProfile();
      // Convert ProfileModel to UserEntity
      final isPro = profileModel.faQuizInfo?.plan == 'PRO' || 
                    profileModel.faQuizInfo?.plan == 'PREMIUM';
      final isPremium = profileModel.faQuizInfo?.plan == 'PREMIUM';
      final userEntity = UserEntity(
        id: profileModel.userId?.toString() ?? '',
        email: profileModel.email ?? '',
        fullName: profileModel.fullName,
        phoneNumber: profileModel.username,
        avatarUrl: profileModel.avatar,
        isPro: isPro,
        isPremium: isPremium,
        createdAt: null,
        updatedAt: null,
      );

      // Tạo AuthEntity với thông tin từ profile
      final entity = AuthEntity(
        token: model.token,
        refreshToken: '', // Backend không trả về refresh token
        user: userEntity,
      );

      return Right(entity);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _prefs.remove('auth_token');
      await _prefs.remove('refresh_token');
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken) async {
    // Backend không có endpoint refresh token, trả về error
    return const Left(Failure.server(message: 'Refresh token not supported'));
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = _prefs.getString('auth_token');
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      
      // Xử lý lỗi 400 với code 40000108 (sai mật khẩu hoặc số điện thoại)
      if (statusCode == 400 && responseData != null) {
        try {
          // Thử parse response theo format ApiResponse
          final meta = responseData['meta'];
          if (meta != null && meta['code'] == 40000108) {
            return Failure.server(
              message: meta['message'] ?? 'Thử đăng nhập bằng TK khác hoặc kiểm lại SĐT và mật khẩu',
              statusCode: statusCode,
            );
          }
          // Nếu không phải code 40000108, lấy message từ meta nếu có
          if (meta != null && meta['message'] != null) {
            return Failure.server(
              message: meta['message'],
              statusCode: statusCode,
            );
          }
        } catch (e) {
          // Nếu không parse được, fallback về message mặc định
        }
        // Fallback: lấy message từ response nếu có
        final message = responseData['message'] ?? 
                       responseData['error'] ?? 
                       'Đã xảy ra lỗi. Vui lòng thử lại.';
        return Failure.server(
          message: message.toString(),
          statusCode: statusCode,
        );
      }
      
      switch (statusCode) {
        case 401:
          return const Failure.unauthorized(message: 'Unauthorized');
        case 403:
          return const Failure.forbidden(message: 'Forbidden');
        case 404:
          return const Failure.notFound(message: 'Not Found');
        case 408:
          return const Failure.timeout(message: 'Request Timeout');
        default:
          // Thử lấy message từ meta nếu có
          try {
            final meta = responseData?['meta'];
            if (meta != null && meta['message'] != null) {
              return Failure.server(
                message: meta['message'],
                statusCode: statusCode,
              );
            }
          } catch (e) {
            // Ignore
          }
          return Failure.server(
            message: responseData?['message'] ?? 'Server Error',
            statusCode: statusCode,
          );
      }
    }
    return Failure.network(message: error.toString());
  }
}

