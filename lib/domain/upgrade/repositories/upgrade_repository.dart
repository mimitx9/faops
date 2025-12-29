import '../entities/upgrade_entity.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class UpgradeRepository {
  Future<Either<Failure, List<UpgradePlanEntity>>> getPlans();
  Future<Either<Failure, UpgradeStatusEntity>> getStatus();
  Future<Either<Failure, void>> purchase(PurchaseRequest request);
  Future<Either<Failure, List<UpgradeHistoryEntity>>> getHistory();
}

class UpgradeHistoryEntity {
  final String id;
  final String planName;
  final double amount;
  final DateTime purchaseDate;
  final bool isActive;

  const UpgradeHistoryEntity({
    required this.id,
    required this.planName,
    required this.amount,
    required this.purchaseDate,
    this.isActive = false,
  });
}



