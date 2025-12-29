import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../widgets/common/function_page_layout.dart';

class RolePage extends ConsumerStatefulWidget {
  const RolePage({super.key});

  @override
  ConsumerState<RolePage> createState() => _RolePageState();
}

class _RolePageState extends ConsumerState<RolePage> {
  final List<Map<String, dynamic>> _messages = [];

  void _handleSendMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    // TODO: Xử lý gửi message và nhận response
  }

  @override
  Widget build(BuildContext context) {
    return FunctionPageLayout(
      placeholderText: 'Viết yêu cầu',
      onSendMessage: _handleSendMessage,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_messages.isEmpty) {
      return SizedBox.shrink();
    }

    return ListView.builder(
      padding: EdgeInsets.all(DesignSystem.spacingLG),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSystem.spacingMD),
        padding: EdgeInsets.all(DesignSystem.spacingMD),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.chatBubbleReceived,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLG),
        ),
        child: Text(
          message['text'] as String,
          style: AppTypography.bodyMedium.copyWith(
            color: isUser
                ? AppColors.textOnPrimary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}


