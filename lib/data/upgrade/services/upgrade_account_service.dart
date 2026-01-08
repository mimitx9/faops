import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/device_info.dart';

@lazySingleton
class UpgradeAccountService {
  final Dio _dio;

  UpgradeAccountService() : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Basic dGF0YTpvbml0bzE=',
            },
          ),
        );

  // Upgrade account cho Streak, VSTEP, Class, Hack
  Future<UpgradeResponse> upgradeAccount({
    required String phone,
    required int numberOfDay,
    required String plan,
    required String action, // 'streak', 'vstep', 'class', 'hack'
  }) async {
    try {
      final response = await _dio.post(
        '/fai/v1/internal/upgrade-account',
        data: {
          'phone': phone,
          'numberOfDay': numberOfDay,
          'plan': plan,
          'action': action,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>;
      
      return UpgradeResponse(
        code: meta['code'] as int,
        message: meta['message'] as String? ?? '',
      );
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    }
  }

  // Upgrade Quiz
  Future<UpgradeResponse> upgradeQuiz({
    required String phone,
    required int numberOfDay,
    required int amount,
    required String actualDay, // 'PRO' or 'MAX'
  }) async {
    try {
      final response = await _dio.post(
        '/faquiz/app/tata/update-user-payment',
        data: {
          'numberOfDay': numberOfDay,
          'amount': amount,
          'phone': phone,
          'actualDay': actualDay,
          'serviceType': 'FA_PAY',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'auth-token': 'Tata',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>?;
      
      if (meta != null) {
        return UpgradeResponse(
          code: meta['code'] as int,
          message: meta['message'] as String? ?? '',
        );
      }
      
      // Nếu không có meta, coi như thành công
      return UpgradeResponse(
        code: 200,
        message: 'Thành công',
      );
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    }
  }

  // Apply key cho Streak
  Future<UpgradeResponse> applyKeyStreak({
    required String username,
    required int amount,
  }) async {
    try {
      final response = await _dio.post(
        '/fai/v1/public/apply-key-streak',
        data: {
          'amount': amount,
          'username': username,
          'item': 'key',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'os-type': DeviceInfo.osType,
            'device-name': DeviceInfo.deviceName,
            'os-version': DeviceInfo.osVersion,
            'build-number': DeviceInfo.buildNumber,
            'build-version': DeviceInfo.buildVersion,
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>?;
      
      if (meta != null) {
        return UpgradeResponse(
          code: meta['code'] as int,
          message: meta['message'] as String? ?? '',
        );
      }
      
      return UpgradeResponse(
        code: 200,
        message: 'Thành công',
      );
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    }
  }

  // Tạo transaction
  Future<UpgradeResponse> createTransaction({
    required String staffPhone,
    required String customerPhone,
    required int price,
    required int extendDay,
    required int keys,
    required String type,
    required String note,
  }) async {
    try {
      final response = await _dio.post(
        '/fai/v1/public/transaction',
        data: {
          'price': price,
          'extendDay': extendDay,
          'keys': keys,
          'type': type,
          'note': note,
          'customerPhone': customerPhone,
          'staffPhone': staffPhone,
        },
        options: Options(
          headers: {
            'Authorization': 'Basic dGF0YTpvbml0bzE=',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>?;
      
      if (meta != null) {
        return UpgradeResponse(
          code: meta['code'] as int,
          message: meta['message'] as String? ?? '',
        );
      }
      
      return UpgradeResponse(
        code: 200,
        message: 'Thành công',
      );
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối: ${e.message}');
    }
  }
}

class UpgradeResponse {
  final int code;
  final String message;

  UpgradeResponse({
    required this.code,
    required this.message,
  });

  bool get isSuccess => code == 200;
}



