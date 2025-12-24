import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/device_info.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor(this._prefs);

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

    // Add authorization token
    final token = _prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
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

