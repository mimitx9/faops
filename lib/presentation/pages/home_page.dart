import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/common/fa_avatar.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.home),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSystem.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileState.when(
              data: (profile) {
                if (profile == null) {
                  return SizedBox.shrink();
                }
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(DesignSystem.spacingLG),
                    child: Row(
                      children: [
                        FAAvatar(
                          imageUrl: profile.avatarUrl,
                          name: profile.fullName,
                          size: FAAvatarSize.lg,
                        ),
                        SizedBox(width: DesignSystem.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.welcome,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: DesignSystem.spacingXS),
                              Text(
                                profile.fullName ?? profile.email,
                                style: AppTypography.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => SizedBox.shrink(),
              error: (_, __) => SizedBox.shrink(),
            ),
            SizedBox(height: DesignSystem.spacingXL),
            Text(
              AppStrings.quickActions,
              style: AppTypography.headlineSmall,
            ),
            SizedBox(height: DesignSystem.spacingMD),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: DesignSystem.spacingMD,
              mainAxisSpacing: DesignSystem.spacingMD,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  context,
                  AppStrings.profile,
                  Icons.person,
                  AppColors.primary,
                  () => context.push('/profile'),
                ),
                _buildActionCard(
                  context,
                  AppStrings.upgrade,
                  Icons.star,
                  AppColors.accent,
                  () => context.push('/upgrade'),
                ),
                _buildActionCard(
                  context,
                  AppStrings.chat,
                  Icons.chat,
                  AppColors.secondary,
                  () => context.push('/chat'),
                ),
                _buildActionCard(
                  context,
                  AppStrings.dashboard,
                  Icons.dashboard,
                  AppColors.info,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLG),
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.spacingMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: DesignSystem.iconSizeXL,
                color: color,
              ),
              SizedBox(height: DesignSystem.spacingSM),
              Text(
                title,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

