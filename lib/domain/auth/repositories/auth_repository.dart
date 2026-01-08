import '../entities/auth_entity.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login(LoginRequest request);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken);
  Future<Either<Failure, bool>> isAuthenticated();
}





