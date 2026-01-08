import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/design_system.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/asset_helper.dart';
import '../../../../core/constants/role_constants.dart';
import '../../providers/profile_provider.dart';
import '../../pages/webview_page.dart';
import 'bottom_navigator.dart';

class HelpBubble {
  final String label;
  final VoidCallback? onTap;

  const HelpBubble({
    required this.label,
    this.onTap,
  });
}

class FunctionPageLayout extends ConsumerStatefulWidget {
  final Widget body;
  final String? placeholderText;
  final Function(String)? onSendMessage;
  final Function(File)? onImageSelected;
  final bool showTabs;
  final int initialTabIndex;
  final bool showInputBox;
  final List<String>? tabLabels;
  final List<HelpBubble>? helpBubbles;
  final bool enableClipboardPaste;
  final bool showSendButton;
  final Function(String label, String inputText)? onHelpBubbleTap;
  final Function(HelpBubble)? onHelpBubbleTapDirect;
  final Widget? customBottomWidget;
  final Function(int)? onTabChanged;
  final bool alwaysShowHelpBubbles;

  const FunctionPageLayout({
    super.key,
    required this.body,
    this.placeholderText,
    this.onSendMessage,
    this.onImageSelected,
    this.showTabs = true,
    this.initialTabIndex = 0,
    this.showInputBox = true,
    this.tabLabels,
    this.helpBubbles,
    this.enableClipboardPaste = false,
    this.showSendButton = true,
    this.onHelpBubbleTap,
    this.onHelpBubbleTapDirect,
    this.customBottomWidget,
    this.onTabChanged,
    this.alwaysShowHelpBubbles = false,
  });

  @override
  ConsumerState<FunctionPageLayout> createState() => _FunctionPageLayoutState();
}

class _FunctionPageLayoutState extends ConsumerState<FunctionPageLayout> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _selectedTabIndex = 0;
  String? _errorMessage;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    // Kiểm tra clipboard khi khởi tạo nếu tab "Khác" được chọn và enableClipboardPaste = true
    if (widget.enableClipboardPaste && _selectedTabIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndPasteClipboard();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.onSendMessage != null) {
      widget.onSendMessage!(text);
      _textController.clear();
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && widget.onImageSelected != null) {
        widget.onImageSelected!(File(image.path));
      }
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  /// Kiểm tra clipboard và paste nếu thỏa mãn điều kiện
  /// (toàn số và tối đa 20 ký tự)
  /// Chỉ paste khi ô input đang trống để tránh ghi đè nội dung người dùng
  Future<void> _checkAndPasteClipboard() async {
    if (!widget.enableClipboardPaste || _selectedTabIndex != 0) {
      return;
    }

    // Chỉ paste khi ô input đang trống
    if (_textController.text.trim().isNotEmpty) {
      return;
    }

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text?.trim() ?? '';

      // Kiểm tra nếu là dãy toàn số và tối đa 20 ký tự
      if (clipboardText.isNotEmpty &&
          clipboardText.length <= 20 &&
          RegExp(r'^\d+$').hasMatch(clipboardText)) {
        // Paste vào ô input
        _textController.text = clipboardText;
        setState(() {
          _hasText = true;
        });
      }
    } catch (e) {
      // Xử lý lỗi nếu không thể đọc clipboard
      print('Error reading clipboard: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.valueOrNull;
    final hasAllRoles = profile?.roles.contains(RoleConstants.roleAll) ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header với avatar, tabs, và trend icon
            _buildHeader(context, profileState),
            // Body content
            Expanded(
              child: widget.body,
            ),
            // Custom bottom widget hoặc Input box bo tròn
            if (widget.customBottomWidget != null)
              widget.customBottomWidget!
            else if (widget.showInputBox)
              _buildInputBox(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigator(context, hasAllRoles),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue profileState) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingLG,
        vertical: DesignSystem.spacingMD,
      ),
      child: Row(
        children: [
          // Avatar bên trái
          profileState.when(
            data: (profile) => GestureDetector(
              onTap: () => context.push('/profile'),
              child: profile?.avatarUrl != null &&
                      profile!.avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profile.avatarUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.background,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.border,
                            ),
                            child: SvgPicture.asset(
                              AssetHelper.svgUser,
                              width: 20,
                              height: 20,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.border,
                      ),
                      child: SvgPicture.asset(
                        AssetHelper.svgUser,
                        width: 20,
                        height: 20,
                      ),
                    ),
            ),
            loading: () => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.border,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, __) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.border,
              ),
              child: SvgPicture.asset(
                AssetHelper.svgUser,
                width: 20,
                height: 20,
              ),
            ),
          ),
          // Tabs ở giữa
          if (widget.showTabs) ...[
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.tabLabels != null && widget.tabLabels!.isNotEmpty)
                      ...widget.tabLabels!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final label = entry.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index > 0) SizedBox(width: DesignSystem.spacingLG),
                            _buildTab(label, index),
                          ],
                        );
                      }).toList()
                    else ...[
                      _buildTab('Tự động', 0),
                      SizedBox(width: DesignSystem.spacingLG),
                      _buildTab('Thủ công', 1),
                    ],
                  ],
                ),
              ),
            ),
          ] else
            Spacer(),
          // Trend icon bên phải
          GestureDetector(
            onTap: () {
              // Mở webview khi click vào trend icon
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WebViewPage(
                    url: 'https://fa.ap.ngrok.io/public/dashboard/bcccd372-81cc-4fef-9f2f-206db502bbd2',
                    title: 'Dashboard',
                  ),
                ),
              );
            },
            child: SvgPicture.asset(
              'assets/svg/trend.svg',
              width: 20,
              height: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        // Notify parent về tab change
        if (widget.onTabChanged != null) {
          widget.onTabChanged!(index);
        }
        // Kiểm tra clipboard khi chuyển sang tab "Khác" (index 0)
        if (widget.enableClipboardPaste && index == 0) {
          _checkAndPasteClipboard();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: label.length * 8.0,
            height: 2,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }


  void _handleHelpBubbleTap(HelpBubble bubble) {
    // Nếu có onHelpBubbleTapDirect, gọi trực tiếp không cần input text
    if (widget.onHelpBubbleTapDirect != null) {
      widget.onHelpBubbleTapDirect!(bubble);
      return;
    }

    final inputText = _textController.text.trim();
    
    // Nếu alwaysShowHelpBubbles = true, không cần input text
    if (!widget.alwaysShowHelpBubbles && inputText.isEmpty) {
      setState(() {
        _errorMessage = 'hãy nhập sđt khách hàng';
        _hasText = false;
      });
      return;
    }
    
    setState(() {
      _errorMessage = null;
    });
    
    if (widget.onHelpBubbleTap != null) {
      widget.onHelpBubbleTap!(bubble.label, inputText);
      // Clear input sau khi gửi message
      _textController.clear();
      setState(() {
        _hasText = false;
      });
    } else if (bubble.onTap != null) {
      bubble.onTap!();
    }
  }

  Widget _buildInputBox(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Help bubbles - hiện khi có text hoặc alwaysShowHelpBubbles = true
        if (widget.helpBubbles != null && widget.helpBubbles!.isNotEmpty)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: (_hasText || widget.alwaysShowHelpBubbles) ? null : 0,
            padding: (_hasText || widget.alwaysShowHelpBubbles)
                ? EdgeInsets.only(
                    left: DesignSystem.spacingLG,
                    right: DesignSystem.spacingLG,
                    bottom: DesignSystem.spacingLG,
                    top: DesignSystem.spacingMD,
                  )
                : EdgeInsets.zero,
            margin: (_hasText || widget.alwaysShowHelpBubbles)
                ? EdgeInsets.only(
                    top: DesignSystem.spacingLG,
                    bottom: DesignSystem.spacingMD,
                  )
                : EdgeInsets.zero,
            child: (_hasText || widget.alwaysShowHelpBubbles)
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.helpBubbles!.map((bubble) {
                        return Padding(
                          padding: EdgeInsets.only(right: DesignSystem.spacingSM),
                          child: _buildHelpBubble(bubble),
                        );
                      }).toList(),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        // Input box
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingLG,
            vertical: DesignSystem.spacingMD,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
              border: Border.all(
                color: Color(0xFFF5F5F5),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: DesignSystem.spacingMD),
                // Upload icon
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(DesignSystem.spacingSM),
                    child: SvgPicture.asset(
                      'assets/svg/upload.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                SizedBox(width: DesignSystem.spacingSM),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onChanged: (value) {
                      final hasText = value.trim().isNotEmpty;
                      // Chỉ setState khi giá trị thực sự thay đổi để tránh mất focus
                      if (_hasText != hasText || _errorMessage != null) {
                        setState(() {
                          _hasText = hasText;
                          if (_errorMessage != null && hasText) {
                            _errorMessage = null;
                          }
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.placeholderText ?? 'Viết yêu cầu',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: DesignSystem.spacingMD,
                      ),
                    ),
                    style: AppTypography.bodyMedium,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                // Send button hoặc padding bên phải
                if (widget.showSendButton && widget.onSendMessage != null)
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      padding: EdgeInsets.all(DesignSystem.spacingMD),
                      child: SvgPicture.asset(
                        'assets/svg/send.svg',
                        width: 19,
                        height: 17,
                      ),
                    ),
                  )
                else
                  SizedBox(width: DesignSystem.spacingMD),
              ],
            ),
          ),
        ),
        // Error message
        if (_errorMessage != null)
          Container(
            padding: EdgeInsets.only(
              left: DesignSystem.spacingLG,
              right: DesignSystem.spacingLG,
              top: DesignSystem.spacingXS,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorMessage!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHelpBubble(HelpBubble bubble) {
    return GestureDetector(
      onTap: () => _handleHelpBubbleTap(bubble),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMD,
          vertical: DesignSystem.spacingSM,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          bubble.label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigator(BuildContext context, bool hasAllRoles) {
    // Không truyền currentRoute để BottomNavigator tự lấy từ GoRouterState
    // Điều này đảm bảo widget sẽ rebuild khi route thay đổi
    return BottomNavigator(
      hasAllRoles: hasAllRoles,
    );
  }
}

