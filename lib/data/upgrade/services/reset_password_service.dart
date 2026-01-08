import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/api_endpoints.dart';

@lazySingleton
class ResetPasswordService {
  final Dio _dio;

  ResetPasswordService() : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'auth-token': 'Muadong4',
            },
          ),
        );

  Future<ResetPasswordResponse> resetPassword(String phone) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'phone': phone,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return ResetPasswordResponse(
        code: data['code'] as int,
        message: data['message'] as String? ?? '',
        data: data['data'],
      );
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    }
  }

  /// Parse message từ format {option1|option2|option3} và trả về một message ngẫu nhiên
  static String parseRandomMessage(String message) {
    // Kiểm tra xem message có format {option1|option2|option3} không
    if (message.startsWith('{') && message.endsWith('}')) {
      final content = message.substring(1, message.length - 1);
      final options = content.split('|');
      if (options.isNotEmpty) {
        // Chọn ngẫu nhiên một option
        final random = DateTime.now().millisecondsSinceEpoch % options.length;
        return options[random].trim();
      }
    }
    // Nếu không đúng format, trả về message gốc
    return message;
  }
}

class ResetPasswordResponse {
  final int code;
  final String message;
  final dynamic data;

  ResetPasswordResponse({
    required this.code,
    required this.message,
    this.data,
  });
}



