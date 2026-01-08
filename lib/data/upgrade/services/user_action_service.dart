import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/api_endpoints.dart';

@lazySingleton
class UserActionService {
  final Dio _dio;

  UserActionService() : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Basic b25pdG86b25pdG8=',
            },
          ),
        );

  Future<UserActionResponse> processUserAction(String phoneNumber, String action) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.processUserAction,
        data: {
          'phoneNumber': phoneNumber,
          'action': action,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      
      return UserActionResponse(
        code: meta['code'] as int,
        message: meta['message'] as String? ?? '',
        data: data['data'],
      );
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    }
  }
}

class UserActionResponse {
  final int code;
  final String message;
  final dynamic data;

  UserActionResponse({
    required this.code,
    required this.message,
    this.data,
  });
}



