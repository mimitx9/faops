import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../entities/task_comment_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    int? startDate,
    int? endDate,
    String? status,
  });
  Future<Either<Failure, TaskEntity>> getTaskByCode(String taskCode);
  Future<Either<Failure, TaskEntity>> updateTaskStatus({
    required String taskCode,
    required String status,
  });
  Future<Either<Failure, List<TaskCommentEntity>>> getTaskComments({
    required String taskCode,
  });
  Future<Either<Failure, TaskCommentEntity>> createTaskComment({
    required String taskCode,
    required String content,
    List<TaskCommentAttachment>? attachments,
  });
}


