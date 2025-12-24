import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FABubbleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final IconData? icon;
  final EdgeInsets? padding;

  const FABubbleChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedBackgroundColor ?? AppColors.primary)
        : (backgroundColor ?? AppColors.surface);
    final txtColor = isSelected
        ? (selectedTextColor ?? AppColors.textOnPrimary)
        : (textColor ?? AppColors.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingMD,
              vertical: DesignSystem.spacingSM,
            ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.border,
                  width: DesignSystem.borderWidthThin,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: DesignSystem.iconSizeSM,
                color: txtColor,
              ),
              SizedBox(width: DesignSystem.spacingXS),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

