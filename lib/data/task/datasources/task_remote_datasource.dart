import 'package:injectable/injectable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/api_response.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks({
    int? startDate,
    int? endDate,
    String? status,
  });
  Future<TaskModel> getTaskByCode(String taskCode);
  Future<TaskModel> updateTaskStatus({
    required String taskCode,
    required String status,
  });
  Future<List<TaskCommentModel>> getTaskComments({
    required String taskCode,
  });
  Future<TaskCommentModel> createTaskComment({
    required String taskCode,
    required String content,
    List<TaskCommentAttachmentModel>? attachments,
  });
}

@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final DioClient _dioClient;

  TaskRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TaskModel>> getTasks({
    int? startDate,
    int? endDate,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate;
    }
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _dioClient.get(
      ApiEndpoints.tasks,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    // Response có thể là ApiResponse hoặc trực tiếp là data
    if (response.data is Map && response.data.containsKey('data')) {
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );
      final List<dynamic> data = apiResponse.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  @override
  Future<TaskModel> getTaskByCode(String taskCode) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.tasks}/$taskCode',
    );

    // Response có thể là ApiResponse hoặc trực tiếp là data
    if (response.data is Map && response.data.containsKey('data')) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      return TaskModel.fromJson(apiResponse.data);
    } else {
      return TaskModel.fromJson(response.data);
    }
  }

  @override
  Future<TaskModel> updateTaskStatus({
    required String taskCode,
    required String status,
  }) async {
    final response = await _dioClient.put(
      '${ApiEndpoints.tasks}/$taskCode/status',
      data: {
        'status': status,
      },
    );

    if (response.data is Map && response.data.containsKey('data')) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      return TaskModel.fromJson(apiResponse.data);
    } else {
      return TaskModel.fromJson(response.data);
    }
  }

  @override
  Future<List<TaskCommentModel>> getTaskComments({
    required String taskCode,
  }) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.tasks}/comments',
      queryParameters: {
        'taskCode': taskCode,
      },
    );

    if (response.data is Map && response.data.containsKey('data')) {
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );
      final List<dynamic> data = apiResponse.data;
      return data.map((e) => TaskCommentModel.fromJson(e)).toList();
    } else if (response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((e) => TaskCommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  @override
  Future<TaskCommentModel> createTaskComment({
    required String taskCode,
    required String content,
    List<TaskCommentAttachmentModel>? attachments,
  }) async {
    final body = <String, dynamic>{
      'taskCode': taskCode,
      'content': content,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments
            .map(
              (a) => {
                'type': a.type,
                'link': a.link,
              },
            )
            .toList(),
    };

    final response = await _dioClient.post(
      '${ApiEndpoints.tasks}/comments',
      data: body,
    );

    if (response.data is Map && response.data.containsKey('data')) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      return TaskCommentModel.fromJson(apiResponse.data);
    } else {
      return TaskCommentModel.fromJson(response.data);
    }
  }
}


