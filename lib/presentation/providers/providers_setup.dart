import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/di/injectable.dart';
import '../../../domain/auth/usecases/login_usecase.dart';
import '../../../domain/auth/usecases/logout_usecase.dart';
import '../../../domain/auth/usecases/check_auth_usecase.dart';
import '../../../domain/profile/usecases/get_profile_usecase.dart';
import '../../../domain/profile/usecases/update_profile_usecase.dart';
import '../../../domain/profile/usecases/change_password_usecase.dart';
import '../../../domain/profile/usecases/upload_avatar_usecase.dart';
import '../../../domain/upgrade/usecases/get_plans_usecase.dart';
import '../../../domain/upgrade/usecases/get_status_usecase.dart';
import '../../../domain/upgrade/usecases/purchase_usecase.dart';
import '../../../domain/chat/usecases/get_conversations_usecase.dart';
import '../../../domain/chat/usecases/get_messages_usecase.dart';
import '../../../domain/chat/usecases/send_message_usecase.dart';
import '../../../domain/chat/usecases/mark_as_read_usecase.dart';

part 'providers_setup.g.dart';

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return getIt<LoginUseCase>();
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return getIt<LogoutUseCase>();
}

@riverpod
CheckAuthUseCase checkAuthUseCase(CheckAuthUseCaseRef ref) {
  return getIt<CheckAuthUseCase>();
}

@riverpod
GetProfileUseCase getProfileUseCase(GetProfileUseCaseRef ref) {
  return getIt<GetProfileUseCase>();
}

@riverpod
UpdateProfileUseCase updateProfileUseCase(UpdateProfileUseCaseRef ref) {
  return getIt<UpdateProfileUseCase>();
}

@riverpod
ChangePasswordUseCase changePasswordUseCase(ChangePasswordUseCaseRef ref) {
  return getIt<ChangePasswordUseCase>();
}

@riverpod
UploadAvatarUseCase uploadAvatarUseCase(UploadAvatarUseCaseRef ref) {
  return getIt<UploadAvatarUseCase>();
}

@riverpod
GetPlansUseCase getPlansUseCase(GetPlansUseCaseRef ref) {
  return getIt<GetPlansUseCase>();
}

@riverpod
GetStatusUseCase getStatusUseCase(GetStatusUseCaseRef ref) {
  return getIt<GetStatusUseCase>();
}

@riverpod
PurchaseUseCase purchaseUseCase(PurchaseUseCaseRef ref) {
  return getIt<PurchaseUseCase>();
}

@riverpod
GetConversationsUseCase getConversationsUseCase(
  GetConversationsUseCaseRef ref,
) {
  return getIt<GetConversationsUseCase>();
}

@riverpod
GetMessagesUseCase getMessagesUseCase(GetMessagesUseCaseRef ref) {
  return getIt<GetMessagesUseCase>();
}

@riverpod
SendMessageUseCase sendMessageUseCase(SendMessageUseCaseRef ref) {
  return getIt<SendMessageUseCase>();
}

@riverpod
MarkAsReadUseCase markAsReadUseCase(MarkAsReadUseCaseRef ref) {
  return getIt<MarkAsReadUseCase>();
}

