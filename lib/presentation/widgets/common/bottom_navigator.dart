import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/role_constants.dart';

class BottomNavigator extends StatelessWidget {
  final bool hasAllRoles;
  final String? currentRoute;

  const BottomNavigator({
    super.key,
    required this.hasAllRoles,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    String currentLocation;
    
    if (currentRoute != null) {
      currentLocation = currentRoute!;
    } else {
      try {
        // Sử dụng GoRouterState để lấy route hiện tại - cách này sẽ tự động rebuild khi route thay đổi
        final state = GoRouterState.of(context);
        currentLocation = state.matchedLocation;
      } catch (e) {
        try {
          final router = GoRouter.of(context);
          currentLocation = router.routerDelegate.currentConfiguration.uri.path;
        } catch (e2) {
          currentLocation = '';
        }
      }
    }

    return Container(
      color: hasAllRoles ? Colors.black : Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(
            context,
            RoleConstants.iconTask,
            RoleConstants.routeTask,
            () => context.push(RoleConstants.routeTask),
            hasAllRoles,
            currentLocation,
          ),
          _buildBottomNavItem(
            context,
            RoleConstants.iconMoney,
            RoleConstants.routeBusiness,
            () => context.push(RoleConstants.routeBusiness),
            hasAllRoles,
            currentLocation,
          ),
          _buildBottomNavItem(
            context,
            'assets/svg/chat.svg',
            '/chat',
            () => context.push('/chat'),
            hasAllRoles,
            currentLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    String iconPath,
    String route,
    VoidCallback onTap,
    bool hasAllRoles,
    String currentLocation,
  ) {
    // So sánh route với currentLocation, sử dụng startsWith để xử lý các route con
    final isSelected = currentLocation == route || currentLocation.startsWith('$route/');
    final selectedColor = Color(0xFF85E14C);
    
    Color iconColor;
    if (isSelected) {
      iconColor = selectedColor;
    } else {
      iconColor = hasAllRoles ? Colors.white : Colors.black;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}


