import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/profile/entities/profile_entity.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    String? avatar,
    String? email,
    @JsonKey(name: 'userId') int? userId,
    String? username,
    @JsonKey(name: 'fullName') String? fullName,
    @JsonKey(name: 'rank') Map<String, dynamic>? rank,
    @JsonKey(name: 'faQuizInfo') FaQuizInfoModel? faQuizInfo,
    @JsonKey(name: 'isAdmin') @Default(false) bool isAdmin,
    @Default([]) List<String> roles,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

@freezed
class FaQuizInfoModel with _$FaQuizInfoModel {
  const factory FaQuizInfoModel({
    @JsonKey(name: 'expireTime') int? expireTime,
    @JsonKey(name: 'isPaid') @Default(false) bool isPaid,
    String? plan,
  }) = _FaQuizInfoModel;

  factory FaQuizInfoModel.fromJson(Map<String, dynamic> json) =>
      _$FaQuizInfoModelFromJson(json);
}

extension ProfileModelX on ProfileModel {
  ProfileEntity toEntity() {
    final isPro = faQuizInfo?.plan == 'PRO' || faQuizInfo?.plan == 'PREMIUM';
    final isPremium = faQuizInfo?.plan == 'PREMIUM';
    
    return ProfileEntity(
      id: userId?.toString() ?? '',
      email: email ?? '',
      fullName: fullName,
      phoneNumber: username,
      address: null,
      dateOfBirth: null,
      gender: null,
      avatarUrl: avatar,
      isPro: isPro,
      isPremium: isPremium,
      createdAt: null,
      updatedAt: null,
    );
  }
}

