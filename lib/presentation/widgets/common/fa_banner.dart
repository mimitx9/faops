import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

enum FABannerType {
  info,
  success,
  warning,
  error,
}

class FABanner extends StatelessWidget {
  final String message;
  final FABannerType type;
  final IconData? icon;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const FABanner({
    super.key,
    required this.message,
    this.type = FABannerType.info,
    this.icon,
    this.onClose,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final defaultIcon = _getDefaultIcon();

    return Container(
      padding: EdgeInsets.all(DesignSystem.spacingMD),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
        border: Border.all(
          color: colors['border']!,
          width: DesignSystem.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? defaultIcon,
            color: colors['icon'],
            size: DesignSystem.iconSizeMD,
          ),
          SizedBox(width: DesignSystem.spacingMD),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colors['text'],
              ),
            ),
          ),
          if (showCloseButton && onClose != null) ...[
            SizedBox(width: DesignSystem.spacingSM),
            IconButton(
              icon: Icon(
                Icons.close,
                size: DesignSystem.iconSizeSM,
                color: colors['text'],
              ),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case FABannerType.success:
        return {
          'background': AppColors.success.withOpacity(0.1),
          'border': AppColors.success,
          'icon': AppColors.success,
          'text': AppColors.success,
        };
      case FABannerType.warning:
        return {
          'background': AppColors.warning.withOpacity(0.1),
          'border': AppColors.warning,
          'icon': AppColors.warning,
          'text': AppColors.warning,
        };
      case FABannerType.error:
        return {
          'background': AppColors.error.withOpacity(0.1),
          'border': AppColors.error,
          'icon': AppColors.error,
          'text': AppColors.error,
        };
      case FABannerType.info:
      default:
        return {
          'background': AppColors.info.withOpacity(0.1),
          'border': AppColors.info,
          'icon': AppColors.info,
          'text': AppColors.info,
        };
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case FABannerType.success:
        return Icons.check_circle;
      case FABannerType.warning:
        return Icons.warning;
      case FABannerType.error:
        return Icons.error;
      case FABannerType.info:
      default:
        return Icons.info;
    }
  }
}





