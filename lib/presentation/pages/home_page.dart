import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/asset_helper.dart';
import '../widgets/common/fa_avatar.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasNavigated = false;
  List<String>? _previousRoles;
  bool _profileLoaded = false;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    // Đảm bảo profile được load khi vào trang home (chỉ một lần)
    if (!_profileLoaded) {
      _profileLoaded = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(profileNotifierProvider.notifier).loadProfile();
        }
      });
    }

    return profileState.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kiểm tra nếu user có role "*"
        final hasAllRoles = profile.roles.contains(RoleConstants.roleAll);
        
        // Xử lý tự động điều hướng nếu chỉ có 1 role (chỉ gọi một lần)
        final currentRoles = profile.roles;
        if (!_hasNavigated && _previousRoles != currentRoles) {
          _previousRoles = currentRoles;
          // Delay navigation ra khỏi build cycle
          Future.microtask(() {
            if (mounted && !_hasNavigated) {
              _handleAutoNavigation(context, currentRoles);
            }
          });
        }

        // Lấy danh sách card cần hiển thị
        final cards = _getAvailableCards(profile.roles, hasAllRoles);

        return Scaffold(
          backgroundColor: hasAllRoles ? Colors.black : AppColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 60, // Space for logo and avatar
                    left: DesignSystem.spacingLG,
                    right: DesignSystem.spacingLG,
                    bottom: DesignSystem.spacingLG,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: DesignSystem.spacingXL),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: DesignSystem.spacingSM,
                        mainAxisSpacing: DesignSystem.spacingSM,
                        childAspectRatio: 0.85,
                        children: cards,
                      ),
                    ],
                  ),
                ),
                // Top header với logo và avatar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingXL,
                      vertical: DesignSystem.spacingMD,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar ở góc trên bên trái
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: profile.avatarUrl!,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 32,
                                      height: 32,
                                      color: AppColors.background,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      return SvgPicture.asset(
                                        AssetHelper.svgUser,
                                        width: 32,
                                        height: 32,
                                        colorFilter: hasAllRoles
                                            ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                                            : null,
                                      );
                                    },
                                  ),
                                )
                              : SvgPicture.asset(
                                  AssetHelper.svgUser,
                                  width: 32,
                                  height: 32,
                                  colorFilter: hasAllRoles
                                      ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                                      : null,
                                ),
                        ),
                        // Logo ở giữa
                        Image.asset(
                          AssetHelper.imageLogoWhite,
                          width: 134,
                          height: 39,
                        ),
                        // Action buttons ở góc trên bên phải
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.logout,
                                color: hasAllRoles ? Colors.white38 : null,
                              ),
                              onPressed: () async {
                                await ref.read(authNotifierProvider.notifier).logout();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigator(context, hasAllRoles),
        );
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Lỗi: ${error.toString()}'),
        ),
      ),
    );
  }

  void _handleAutoNavigation(BuildContext context, List<String> roles) {
    // Lọc các role hợp lệ (không tính role "*")
    final validRoles = roles
        .where((role) =>
            role != RoleConstants.roleAll &&
            (role == RoleConstants.roleUpgrade ||
                role == RoleConstants.roleMedia ||
                role == RoleConstants.roleEditContent ||
                role == RoleConstants.roleTask ||
                role == RoleConstants.roleRole))
        .toList();

    // Nếu chỉ có 1 role hợp lệ, tự động điều hướng
    if (validRoles.length == 1) {
      _hasNavigated = true;
      final role = validRoles.first;
      String? route;

      switch (role) {
        case RoleConstants.roleUpgrade:
          route = RoleConstants.routeBusiness;
          break;
        case RoleConstants.roleMedia:
          route = RoleConstants.routeMedia;
          break;
        case RoleConstants.roleEditContent:
          route = RoleConstants.routeContent;
          break;
        case RoleConstants.roleTask:
          route = RoleConstants.routeTask;
          break;
        case RoleConstants.roleRole:
          route = RoleConstants.routeRole;
          break;
      }

      if (route != null) {
        final routeToPush = route;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.push(routeToPush);
          }
        });
      }
    }
  }

  List<Widget> _getAvailableCards(List<String> roles, bool hasAllRoles) {
    final cards = <Widget>[];

    if (hasAllRoles) {
      cards.addAll([
        _buildActionCard(
          context,
          RoleConstants.cardBusiness,
          RoleConstants.iconMoney,
          () => context.push(RoleConstants.routeBusiness),
          hasAllRoles,
          iconColor: Color(0xFF85E14C), // Vàng cho Business
        ),
        _buildActionCard(
          context,
          RoleConstants.cardTaskList,
          RoleConstants.iconTask,
          () => context.push(RoleConstants.routeTask),
          hasAllRoles,
          iconColor: Color(0xFFC74EFF), // Xanh dương cho Task
        ),
        _buildActionCard(
          context,
          RoleConstants.cardContent,
          RoleConstants.iconContent,
          () => context.push(RoleConstants.routeContent),
          hasAllRoles,
          iconColor: Color(0xFFFF4A4A), // Tím cho Content
        ),
        _buildActionCard(
          context,
          RoleConstants.cardMedia,
          RoleConstants.iconMedia,
          () => context.push(RoleConstants.routeMedia),
          hasAllRoles,
          iconColor: Color(0xFFFFC11C), // Đỏ cho Media
        ),
        _buildActionCard(
          context,
          RoleConstants.cardRole,
          RoleConstants.iconUser,
          () => context.push(RoleConstants.routeRole),
          hasAllRoles,
          iconColor: Color(0xFF4EE6FD), // Xanh lá cho Role
        ),
      ]);
    } else {
      // Hiển thị card dựa trên từng role
      if (roles.contains(RoleConstants.roleUpgrade)) {
        cards.add(
          _buildActionCard(
            context,
            RoleConstants.cardBusiness,
            RoleConstants.iconMoney,
            () => context.push(RoleConstants.routeBusiness),
            hasAllRoles,
            iconColor: Color(0xFFFFD700), // Vàng cho Business
          ),
        );
      }

      if (roles.contains(RoleConstants.roleTask)) {
        cards.add(
          _buildActionCard(
            context,
            RoleConstants.cardTaskList,
            RoleConstants.iconTask,
            () => context.push(RoleConstants.routeTask),
            hasAllRoles,
            iconColor: Color(0xFF4A90E2), // Xanh dương cho Task
          ),
        );
      }

      if (roles.contains(RoleConstants.roleEditContent)) {
        cards.add(
          _buildActionCard(
            context,
            RoleConstants.cardContent,
            RoleConstants.iconContent,
            () => context.push(RoleConstants.routeContent),
            hasAllRoles,
            iconColor: Color(0xFF9B59B6), // Tím cho Content
          ),
        );
      }

      if (roles.contains(RoleConstants.roleMedia)) {
        cards.add(
          _buildActionCard(
            context,
            RoleConstants.cardMedia,
            RoleConstants.iconMedia,
            () => context.push(RoleConstants.routeMedia),
            hasAllRoles,
            iconColor: Color(0xFFE74C3C), // Đỏ cho Media
          ),
        );
      }

      if (roles.contains(RoleConstants.roleRole)) {
        cards.add(
          _buildActionCard(
            context,
            RoleConstants.cardRole,
            RoleConstants.iconUser,
            () => context.push(RoleConstants.routeRole),
            hasAllRoles,
            iconColor: Color(0xFF2ECC71), // Xanh lá cho Role
          ),
        );
      }
    }

    return cards;
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String iconPath,
    VoidCallback onTap,
    bool hasAllRoles, {
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SvgPicture.asset(
                  iconPath,
                  width: DesignSystem.iconSizeXL,
                  height: DesignSystem.iconSizeXL,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.spacingLG),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildBottomNavigator(BuildContext context, bool hasAllRoles) {
    return Container(
      color: hasAllRoles ? Colors.black : Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(
            context,
            RoleConstants.iconTask,
            () => context.push(RoleConstants.routeTask),
            hasAllRoles,
          ),
          _buildBottomNavItem(
            context,
            RoleConstants.iconMoney,
            () => context.push(RoleConstants.routeBusiness),
            hasAllRoles,
          ),
          _buildBottomNavItem(
            context,
            'assets/svg/chat.svg',
            () => context.push('/chat'),
            hasAllRoles,
          ),
          if (hasAllRoles)
            _buildBottomNavItem(
              context,
              null, // Icon dấu 3 chấm ngang
              () {
                // Xử lý khi click vào dấu 3 chấm
              },
              hasAllRoles,
              isMoreIcon: true,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    String? iconPath,
    VoidCallback onTap,
    bool hasAllRoles, {
    bool isMoreIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        child: isMoreIcon
            ? Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 24,
              )
            : SvgPicture.asset(
                iconPath!,
                width: 24,
                height: 24,
                colorFilter: hasAllRoles
                    ? ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
      ),
    );
  }
}

