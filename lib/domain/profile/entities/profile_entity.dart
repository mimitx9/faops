class ProfileEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? avatarUrl;
  final bool isPro;
  final bool isPremium;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.avatarUrl,
    this.isPro = false,
    this.isPremium = false,
    this.roles = const [],
    this.createdAt,
    this.updatedAt,
  });
}

class UpdateProfileRequest {
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;

  const UpdateProfileRequest({
    this.fullName,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
  });
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

