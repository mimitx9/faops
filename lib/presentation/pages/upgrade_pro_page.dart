import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/common/fa_button.dart';
import '../widgets/common/fa_bubble_chip.dart';
import '../providers/upgrade_provider.dart';
import '../../domain/upgrade/entities/upgrade_entity.dart';

class UpgradeProPage extends ConsumerStatefulWidget {
  const UpgradeProPage({super.key});

  @override
  ConsumerState<UpgradeProPage> createState() => _UpgradeProPageState();
}

class _UpgradeProPageState extends ConsumerState<UpgradeProPage> {
  bool _isYearly = false;

  Future<void> _handlePurchase(String planId) async {
    final request = PurchaseRequest(
      planId: planId,
      isYearly: _isYearly,
    );
    await ref.read(purchaseNotifierProvider.notifier).purchase(request);
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(upgradePlansNotifierProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);

    ref.listen<AsyncValue<void>>(purchaseNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.upgradeSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.upgradeToPro),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(DesignSystem.spacingLG),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FABubbleChip(
                  label: AppStrings.monthly,
                  isSelected: !_isYearly,
                  onTap: () => setState(() => _isYearly = false),
                ),
                SizedBox(width: DesignSystem.spacingMD),
                FABubbleChip(
                  label: AppStrings.yearly,
                  isSelected: _isYearly,
                  onTap: () => setState(() => _isYearly = true),
                ),
              ],
            ),
          ),
          Expanded(
            child: plansState.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return Center(
                    child: Text(AppStrings.noData),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(DesignSystem.spacingMD),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final price = _isYearly
                        ? plan.yearlyPrice
                        : plan.monthlyPrice;
                    return Card(
                      margin: EdgeInsets.only(bottom: DesignSystem.spacingMD),
                      child: Padding(
                        padding: EdgeInsets.all(DesignSystem.spacingLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan.name,
                                  style: AppTypography.titleLarge,
                                ),
                                if (plan.isPopular)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DesignSystem.spacingSM,
                                      vertical: DesignSystem.spacingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(
                                        DesignSystem.radiusSM,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.bestValue,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: DesignSystem.spacingSM),
                            Text(
                              plan.description,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: DesignSystem.spacingMD),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: DesignSystem.spacingMD),
                            Text(
                              AppStrings.features,
                              style: AppTypography.labelLarge,
                            ),
                            SizedBox(height: DesignSystem.spacingSM),
                            ...plan.features.map(
                              (feature) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: DesignSystem.spacingXS,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: DesignSystem.iconSizeSM,
                                      color: AppColors.success,
                                    ),
                                    SizedBox(width: DesignSystem.spacingSM),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: DesignSystem.spacingLG),
                            purchaseState.isLoading
                                ? FAButton(
                                    text: AppStrings.loading,
                                    isLoading: true,
                                    isFullWidth: true,
                                  )
                                : FAButton(
                                    text: AppStrings.upgradeNow,
                                    onPressed: () => _handlePurchase(plan.id),
                                    isFullWidth: true,
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error.toString(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacingMD),
                    FAButton(
                      text: AppStrings.retry,
                      onPressed: () {
                        ref
                            .read(upgradePlansNotifierProvider.notifier)
                            .loadPlans();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

