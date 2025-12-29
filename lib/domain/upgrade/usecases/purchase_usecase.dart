import '../entities/upgrade_entity.dart';
import '../repositories/upgrade_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class PurchaseUseCase {
  final UpgradeRepository _repository;

  PurchaseUseCase(this._repository);

  Future<Either<Failure, void>> call(PurchaseRequest request) {
    return _repository.purchase(request);
  }
}



