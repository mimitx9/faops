import 'package:injectable/injectable.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/upgrade_model.dart';

abstract class UpgradeRemoteDataSource {
  Future<List<UpgradePlanModel>> getPlans();
  Future<UpgradeStatusModel> getStatus();
  Future<void> purchase(String planId, bool isYearly);
  Future<List<UpgradeHistoryModel>> getHistory();
}

@LazySingleton(as: UpgradeRemoteDataSource)
class UpgradeRemoteDataSourceImpl implements UpgradeRemoteDataSource {
  final DioClient _dioClient;

  UpgradeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<UpgradePlanModel>> getPlans() async {
    final response = await _dioClient.get(ApiEndpoints.upgradePlans);
    final List<dynamic> data = response.data;
    return data.map((json) => UpgradePlanModel.fromJson(json)).toList();
  }

  @override
  Future<UpgradeStatusModel> getStatus() async {
    final response = await _dioClient.get(ApiEndpoints.upgradeStatus);
    return UpgradeStatusModel.fromJson(response.data);
  }

  @override
  Future<void> purchase(String planId, bool isYearly) async {
    await _dioClient.post(
      ApiEndpoints.upgradePurchase,
      data: {
        'plan_id': planId,
        'is_yearly': isYearly,
      },
    );
  }

  @override
  Future<List<UpgradeHistoryModel>> getHistory() async {
    final response = await _dioClient.get(ApiEndpoints.upgradeHistory);
    final List<dynamic> data = response.data;
    return data.map((json) => UpgradeHistoryModel.fromJson(json)).toList();
  }
}





