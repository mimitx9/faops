import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../core/error/failures.dart';
import '../../../domain/task/repositories/task_repository.dart';
import '../../../domain/task/entities/task_entity.dart';
import '../../../domain/task/entities/task_comment_entity.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

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
            message: error.response?.data?['meta']?['message'] ?? 
                     error.response?.data?['message'] ?? 
                     'Server Error',
            statusCode: error.response?.statusCode,
          );
      }
    }
    return Failure.network(message: error.toString());
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    int? startDate,
    int? endDate,
    String? status,
  }) async {
    try {
      final models = await _remoteDataSource.getTasks(
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskByCode(String taskCode) async {
    try {
      final model = await _remoteDataSource.getTaskByCode(taskCode);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTaskStatus({
    required String taskCode,
    required String status,
  }) async {
    try {
      final model = await _remoteDataSource.updateTaskStatus(
        taskCode: taskCode,
        status: status,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<TaskCommentEntity>>> getTaskComments({
    required String taskCode,
  }) async {
    try {
      final models = await _remoteDataSource.getTaskComments(
        taskCode: taskCode,
      );
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TaskCommentEntity>> createTaskComment({
    required String taskCode,
    required String content,
    List<TaskCommentAttachment>? attachments,
  }) async {
    try {
      final model = await _remoteDataSource.createTaskComment(
        taskCode: taskCode,
        content: content,
        attachments: attachments
            ?.map(
              (a) => TaskCommentAttachmentModel(
                type: a.type,
                link: a.link,
              ),
            )
            .toList(),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}

