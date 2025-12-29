import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/upgrade/entities/upgrade_entity.dart';
import '../../../domain/upgrade/repositories/upgrade_repository.dart';

part 'upgrade_model.freezed.dart';
part 'upgrade_model.g.dart';

@freezed
class UpgradePlanModel with _$UpgradePlanModel {
  const factory UpgradePlanModel({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'monthly_price') required double monthlyPrice,
    @JsonKey(name: 'yearly_price') required double yearlyPrice,
    required List<String> features,
    @JsonKey(name: 'is_popular') @Default(false) bool isPopular,
  }) = _UpgradePlanModel;

  factory UpgradePlanModel.fromJson(Map<String, dynamic> json) =>
      _$UpgradePlanModelFromJson(json);
}

extension UpgradePlanModelX on UpgradePlanModel {
  UpgradePlanEntity toEntity() {
    return UpgradePlanEntity(
      id: id,
      name: name,
      description: description,
      monthlyPrice: monthlyPrice,
      yearlyPrice: yearlyPrice,
      features: features,
      isPopular: isPopular,
    );
  }
}

@freezed
class UpgradeStatusModel with _$UpgradeStatusModel {
  const factory UpgradeStatusModel({
    @JsonKey(name: 'current_plan') required String currentPlan,
    @JsonKey(name: 'is_pro') @Default(false) bool isPro,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
  }) = _UpgradeStatusModel;

  factory UpgradeStatusModel.fromJson(Map<String, dynamic> json) =>
      _$UpgradeStatusModelFromJson(json);
}

extension UpgradeStatusModelX on UpgradeStatusModel {
  UpgradeStatusEntity toEntity() {
    return UpgradeStatusEntity(
      currentPlan: currentPlan,
      isPro: isPro,
      isPremium: isPremium,
      expiresAt: expiresAt,
      isActive: isActive,
    );
  }
}

@freezed
class UpgradeHistoryModel with _$UpgradeHistoryModel {
  const factory UpgradeHistoryModel({
    required String id,
    @JsonKey(name: 'plan_name') required String planName,
    required double amount,
    @JsonKey(name: 'purchase_date') required DateTime purchaseDate,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
  }) = _UpgradeHistoryModel;

  factory UpgradeHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$UpgradeHistoryModelFromJson(json);
}

extension UpgradeHistoryModelX on UpgradeHistoryModel {
  UpgradeHistoryEntity toEntity() {
    return UpgradeHistoryEntity(
      id: id,
      planName: planName,
      amount: amount,
      purchaseDate: purchaseDate,
      isActive: isActive,
    );
  }
}



