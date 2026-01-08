import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../utils/device_info.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final Logger _logger;

  AuthInterceptor(this._prefs, this._logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add device headers
    options.headers['os-type'] = DeviceInfo.osType;
    options.headers['device-name'] = DeviceInfo.deviceName;
    options.headers['os-version'] = DeviceInfo.osVersion;
    options.headers['build-number'] = DeviceInfo.buildNumber;
    options.headers['build-version'] = DeviceInfo.buildVersion;

    // Check if this is a Task API request
    final isTaskApi = options.path.contains('/fai/faquiz/v1/tasks') || 
                      options.path.contains('/faquiz/v1/tasks');
    
    if (isTaskApi) {
      // Task API uses bearer token from login (stored as auth_token)
      final bearerToken = _prefs.getString('auth_token');
      if (bearerToken != null && bearerToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $bearerToken';
        _logger.d('AuthInterceptor: Bearer token added to Task API request ${options.path}');
      } else {
        _logger.w('AuthInterceptor: No bearer token found for Task API request ${options.path}');
      }
    } else {
      // Other APIs use auth_token
      final token = _prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.d('AuthInterceptor: Token added to request ${options.path}');
      } else {
        _logger.w('AuthInterceptor: No token found for request ${options.path}');
      }
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (err.response?.statusCode == 401) {
      _prefs.remove('auth_token');
      _prefs.remove('refresh_token');
    }
    handler.next(err);
  }
}

