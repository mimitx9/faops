import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../widgets/common/fa_button.dart';
import '../widgets/common/fa_bubble_chip.dart';
import '../widgets/common/function_page_layout.dart';
import '../providers/upgrade_provider.dart';
import '../providers/profile_provider.dart';
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

  void _handleSendMessage(String message) {
    // TODO: Xử lý gửi message
  }

  void _handleHelpBubbleTap(String label, String inputText) {
    // Tạo message dạng "Soi {{sđt}}" hoặc "Tạo QR {{sđt}}"...
    final message = '$label $inputText';
    _handleSendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(upgradePlansNotifierProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.valueOrNull;
    final hasAllRoles = profile?.roles.contains(RoleConstants.roleAll) ?? false;

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

    return FunctionPageLayout(
      placeholderText: 'Viết yêu cầu',
      onSendMessage: _handleSendMessage,
      showTabs: true,
      showInputBox: true,
      showSendButton: false,
      tabLabels: ['Khác', 'Thủ công'],
      enableClipboardPaste: true,
      onHelpBubbleTap: _handleHelpBubbleTap,
      helpBubbles: [
        HelpBubble(
          label: 'Tạo QR',
        ),
        HelpBubble(
          label: 'Soi',
        ),
        HelpBubble(
          label: 'Reset',
        ),
        HelpBubble(
          label: 'Block',
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: plansState.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return SizedBox.shrink();
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

