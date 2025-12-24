import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../domain/upgrade/entities/upgrade_entity.dart';
import '../../../domain/upgrade/repositories/upgrade_repository.dart';
import '../../../core/error/failures.dart';
import '../datasources/upgrade_remote_datasource.dart';
import '../models/upgrade_model.dart';

@LazySingleton(as: UpgradeRepository)
class UpgradeRepositoryImpl implements UpgradeRepository {
  final UpgradeRemoteDataSource _remoteDataSource;

  UpgradeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<UpgradePlanEntity>>> getPlans() async {
    try {
      final models = await _remoteDataSource.getPlans();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UpgradeStatusEntity>> getStatus() async {
    try {
      final model = await _remoteDataSource.getStatus();
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> purchase(PurchaseRequest request) async {
    try {
      await _remoteDataSource.purchase(request.planId, request.isYearly);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<UpgradeHistoryEntity>>> getHistory() async {
    try {
      final models = await _remoteDataSource.getHistory();
      return Right(models.map((model) => model.toEntity()).toList());
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

