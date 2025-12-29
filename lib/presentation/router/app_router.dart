import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/upgrade_pro_page.dart';
import '../pages/chat_page.dart';
import '../pages/task_page.dart';
import '../pages/role_page.dart';
import '../pages/media_page.dart';
import '../pages/content_page.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull ?? false;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (isAuthenticated && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/upgrade',
        name: 'upgrade',
        builder: (context, state) => const UpgradeProPage(),
      ),
      GoRoute(
        path: '/business',
        name: 'business',
        builder: (context, state) => const UpgradeProPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/task',
        name: 'task',
        builder: (context, state) => const TaskPage(),
      ),
      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RolePage(),
      ),
      GoRoute(
        path: '/media',
        name: 'media',
        builder: (context, state) => const MediaPage(),
      ),
      GoRoute(
        path: '/content',
        name: 'content',
        builder: (context, state) => const ContentPage(),
      ),
    ],
  );
});

