import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/upgrade/entities/upgrade_entity.dart';
import '../../../domain/upgrade/usecases/get_plans_usecase.dart';
import '../../../domain/upgrade/usecases/get_status_usecase.dart';
import '../../../domain/upgrade/usecases/purchase_usecase.dart';
import '../../../core/error/failures.dart';
import 'providers_setup.dart';

part 'upgrade_provider.g.dart';

@riverpod
class UpgradePlansNotifier extends _$UpgradePlansNotifier {
  GetPlansUseCase? _getPlansUseCase;

  @override
  Future<List<UpgradePlanEntity>> build() async {
    _getPlansUseCase = ref.read(getPlansUseCaseProvider);
    await loadPlans();
    return [];
  }

  Future<void> loadPlans() async {
    state = const AsyncValue.loading();
    final result = await _getPlansUseCase!();
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (plans) {
        state = AsyncValue.data(plans);
      },
    );
  }
}

@riverpod
class UpgradeStatusNotifier extends _$UpgradeStatusNotifier {
  GetStatusUseCase? _getStatusUseCase;

  @override
  Future<UpgradeStatusEntity?> build() async {
    _getStatusUseCase = ref.read(getStatusUseCaseProvider);
    await loadStatus();
    return null;
  }

  Future<void> loadStatus() async {
    state = const AsyncValue.loading();
    final result = await _getStatusUseCase!();
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (status) {
        state = AsyncValue.data(status);
      },
    );
  }
}

@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  PurchaseUseCase? _purchaseUseCase;

  @override
  Future<void> build() async {
    _purchaseUseCase = ref.read(purchaseUseCaseProvider);
  }

  Future<void> purchase(PurchaseRequest request) async {
    state = const AsyncValue.loading();
    final result = await _purchaseUseCase!(request);
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (_) {
        state = const AsyncValue.data(null);
      },
    );
  }
}


