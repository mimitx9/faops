import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/asset_helper.dart';
import '../../core/error/failures.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/fa_button.dart';
import '../widgets/common/fa_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  String? _loginError;

  @override
  void initState() {
    super.initState();
    // Auto focus vào ô số điện thoại sau khi widget được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loginError = null; // Clear error khi bắt đầu login
      });
      await ref.read(authNotifierProvider.notifier).login(
            _phoneController.text.trim(),
            _passwordController.text,
            false,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AsyncValue<bool>>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (isAuthenticated) {
          if (isAuthenticated) {
            // Navigation will be handled by router
          }
        },
        error: (error, stackTrace) {
          // Lấy error message từ Failure
          String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
          if (error is Failure) {
            errorMessage = error.message ?? errorMessage;
          } else {
            errorMessage = error.toString();
          }
          setState(() {
            _loginError = errorMessage;
          });
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DesignSystem.spacingXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: SvgPicture.asset(
                    AssetHelper.svgLogo,
                    width: 134,
                    height: 39,
                  ),
                ),
                SizedBox(height: DesignSystem.spacingXXL * 2),
                
                // Phone Number Field
                FATextField(
                  controller: _phoneController,
                  hint: AppStrings.phoneNumber,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      AssetHelper.svgUser,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  focusNode: _phoneFocusNode,
                  autofocus: true,
                  showBorder: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                SizedBox(height: DesignSystem.spacingMD),
                
                // Password Field
                FATextField(
                  controller: _passwordController,
                  hint: AppStrings.password,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      AssetHelper.svgPassword,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  obscureText: true, // Let FATextField handle visibility toggle
                  errorText: _loginError,
                  showBorder: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                SizedBox(height: DesignSystem.spacingXL),
                
                // Login Button
                FAButton(
                  text: authState.isLoading ? AppStrings.loading : AppStrings.login,
                  type: FAButtonType.gradient,
                  onPressed: authState.isLoading ? null : _handleLogin,
                  isLoading: authState.isLoading,
                  isFullWidth: true,
                  textUppercase: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

