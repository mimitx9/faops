import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://api.facourse.com';
  }

  // Auth Endpoints
  static const String login = '/fai/v1/account/auth-mini';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Profile Endpoints
  static const String profile = '/fai/v1/user/profile-quiz';
  static const String updateProfile = '/profile/update';
  static const String changePassword = '/profile/change-password';
  static const String uploadAvatar = '/profile/avatar';

  // Upgrade Endpoints
  static const String upgradePlans = '/upgrade/plans';
  static const String upgradePurchase = '/upgrade/purchase';
  static const String upgradeStatus = '/upgrade/status';
  static const String upgradeHistory = '/upgrade/history';

  // Chat Endpoints
  static const String chatMessages = '/chat/messages';
  static const String chatSend = '/chat/send';
  static const String chatConversations = '/chat/conversations';
  static const String chatMarkRead = '/chat/mark-read';
  static const String chatDelete = '/chat/delete';
}

