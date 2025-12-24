import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/api_response.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<String> uploadAvatar(String imagePath);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _dioClient.get(ApiEndpoints.profile);
    final apiResponse = ApiResponse<ProfileModel>.fromJson(
      response.data,
      (json) => ProfileModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data;
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.put(
      ApiEndpoints.updateProfile,
      data: data,
    );
    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _dioClient.post(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<String> uploadAvatar(String imagePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imagePath),
    });
    final response = await _dioClient.post(
      ApiEndpoints.uploadAvatar,
      data: formData,
    );
    return response.data['avatar_url'] as String;
  }
}

