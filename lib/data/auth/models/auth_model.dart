import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/auth/entities/auth_entity.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String token,
    @Default(false) bool login,
  }) = _AuthModel;

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}

extension AuthModelX on AuthModel {
  AuthEntity toEntity() {
    return AuthEntity(
      token: token,
      refreshToken: '', // Backend không trả về refresh token trong response này
      user: const UserEntity(
        id: '',
        email: '',
      ), // User sẽ được lấy từ profile API
    );
  }
}


