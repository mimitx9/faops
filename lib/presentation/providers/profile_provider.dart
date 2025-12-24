import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/profile/entities/profile_entity.dart';
import '../../../domain/profile/usecases/get_profile_usecase.dart';
import '../../../domain/profile/usecases/update_profile_usecase.dart';
import '../../../domain/profile/usecases/change_password_usecase.dart';
import '../../../domain/profile/usecases/upload_avatar_usecase.dart';
import '../../../core/error/failures.dart';
import 'providers_setup.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  GetProfileUseCase? _getProfileUseCase;
  UpdateProfileUseCase? _updateProfileUseCase;
  ChangePasswordUseCase? _changePasswordUseCase;
  UploadAvatarUseCase? _uploadAvatarUseCase;

  @override
  Future<ProfileEntity?> build() async {
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);
    _updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    _changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
    _uploadAvatarUseCase = ref.read(uploadAvatarUseCaseProvider);

    await loadProfile();
    return null;
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final result = await _getProfileUseCase!();
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (profile) {
        state = AsyncValue.data(profile);
      },
    );
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.loading();

    final result = await _updateProfileUseCase!(request);
    result.fold(
      (failure) {
        state = AsyncValue.error(
          Failure.unknown(message: failure.toString()),
          StackTrace.current,
        );
      },
      (profile) {
        state = AsyncValue.data(profile);
      },
    );
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final result = await _changePasswordUseCase!(request);
    result.fold(
      (failure) {
        throw Failure.unknown(message: failure.toString());
      },
      (_) {
        // Success
      },
    );
  }

  Future<void> uploadAvatar(String imagePath) async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await _uploadAvatarUseCase!(imagePath);
    result.fold(
      (failure) {
        throw Failure.unknown(message: failure.toString());
      },
      (avatarUrl) async {
        await loadProfile();
      },
    );
  }
}


