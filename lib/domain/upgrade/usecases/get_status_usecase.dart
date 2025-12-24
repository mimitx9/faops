import '../entities/upgrade_entity.dart';
import '../repositories/upgrade_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetStatusUseCase {
  final UpgradeRepository _repository;

  GetStatusUseCase(this._repository);

  Future<Either<Failure, UpgradeStatusEntity>> call() {
    return _repository.getStatus();
  }
}

