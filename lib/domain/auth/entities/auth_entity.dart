class AuthEntity {
  final String token;
  final String refreshToken;
  final UserEntity user;

  const AuthEntity({
    required this.token,
    required this.refreshToken,
    required this.user,
  });
}

class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isPro;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.isPro = false,
    this.isPremium = false,
    this.createdAt,
    this.updatedAt,
  });
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

