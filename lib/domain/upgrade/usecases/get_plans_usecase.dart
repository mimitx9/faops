import '../entities/upgrade_entity.dart';
import '../repositories/upgrade_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPlansUseCase {
  final UpgradeRepository _repository;

  GetPlansUseCase(this._repository);

  Future<Either<Failure, List<UpgradePlanEntity>>> call() {
    return _repository.getPlans();
  }
}





