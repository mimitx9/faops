class UpgradePlanEntity {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final bool isPopular;

  const UpgradePlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.isPopular = false,
  });
}

class UpgradeStatusEntity {
  final String currentPlan;
  final bool isPro;
  final bool isPremium;
  final DateTime? expiresAt;
  final bool isActive;

  const UpgradeStatusEntity({
    required this.currentPlan,
    this.isPro = false,
    this.isPremium = false,
    this.expiresAt,
    this.isActive = false,
  });
}

class PurchaseRequest {
  final String planId;
  final bool isYearly;

  const PurchaseRequest({
    required this.planId,
    this.isYearly = false,
  });
}





