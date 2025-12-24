import 'package:injectable/injectable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/api_response.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String username, String password);
  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthModel> login(String username, String password) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );
    final apiResponse = ApiResponse<AuthModel>.fromJson(
      response.data,
      (json) => AuthModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data;
  }

  @override
  Future<void> logout() async {
    // Backend có thể không có endpoint logout, chỉ cần xóa token ở client
    // await _dioClient.post(ApiEndpoints.logout);
  }
}

