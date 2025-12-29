import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/role_constants.dart';
import '../widgets/common/fa_button.dart';
import '../widgets/common/fa_text_field.dart';
import '../widgets/common/fa_avatar.dart';
import '../widgets/common/bottom_navigator.dart';
import '../providers/profile_provider.dart';
import '../../domain/profile/entities/profile_entity.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    ref.read(profileNotifierProvider.notifier).loadProfile();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final request = UpdateProfileRequest(
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );
      await ref.read(profileNotifierProvider.notifier).updateProfile(request);
      _toggleEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _toggleEdit,
            )
          else
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            _loadProfile();
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!_isEditing) {
            _fullNameController.text = profile.fullName ?? '';
            _phoneNumberController.text = profile.phoneNumber ?? '';
            _addressController.text = profile.address ?? '';
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(DesignSystem.spacingLG),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: DesignSystem.spacingMD),
                  FAAvatar(
                    imageUrl: profile.avatarUrl,
                    name: profile.fullName,
                    size: FAAvatarSize.xl,
                  ),
                  SizedBox(height: DesignSystem.spacingLG),
                  FATextField(
                    label: AppStrings.fullName,
                    controller: _fullNameController,
                    enabled: _isEditing,
                  ),
                  SizedBox(height: DesignSystem.spacingMD),
                  FATextField(
                    label: AppStrings.email,
                    controller: TextEditingController(text: profile.email),
                    enabled: false,
                  ),
                  SizedBox(height: DesignSystem.spacingMD),
                  FATextField(
                    label: AppStrings.phoneNumber,
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  SizedBox(height: DesignSystem.spacingMD),
                  FATextField(
                    label: AppStrings.address,
                    controller: _addressController,
                    maxLines: 3,
                    enabled: _isEditing,
                  ),
                  if (_isEditing) ...[
                    SizedBox(height: DesignSystem.spacingLG),
                    FAButton(
                      text: AppStrings.save,
                      onPressed: _saveProfile,
                      isFullWidth: true,
                    ),
                  ],
                ],
              ),
            ),
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
                onPressed: _loadProfile,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: profileState.when(
        data: (profile) {
          // Không truyền currentRoute để BottomNavigator tự lấy từ GoRouterState
          return BottomNavigator(
            hasAllRoles: profile?.roles.contains(RoleConstants.roleAll) ?? false,
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

