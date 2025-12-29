import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

enum FAButtonType {
  primary,
  secondary,
  outline,
  text,
  gradient, // For gradient buttons like login button
}

enum FAButtonSize {
  small,
  medium,
  large,
}

class FAButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final FAButtonType type;
  final FAButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Color>? gradientColors; // For gradient button
  final AlignmentGeometry? gradientBegin; // For gradient button
  final AlignmentGeometry? gradientEnd; // For gradient button
  final bool textUppercase; // Whether to uppercase text

  const FAButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = FAButtonType.primary,
    this.size = FAButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.gradientBegin,
    this.gradientEnd,
    this.textUppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getButtonHeight();
    final textStyle = _getTextStyle();
    final fgColor = foregroundColor ?? _getForegroundColor(context);

    Widget child = isLoading
        ? SizedBox(
            height: buttonHeight,
            child: Center(
              child: SizedBox(
                width: DesignSystem.iconSizeSM,
                height: DesignSystem.iconSizeSM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: DesignSystem.iconSizeSM),
                SizedBox(width: DesignSystem.spacingXS),
              ],
              Text(
                textUppercase ? text.toUpperCase() : text,
                style: textStyle.copyWith(
                  color: type == FAButtonType.gradient 
                      ? Colors.white 
                      : fgColor,
                ),
              ),
            ],
          );

    // Handle gradient button separately
    if (type == FAButtonType.gradient) {
      return _buildGradientButton(child, buttonHeight);
    }

    final buttonStyle = _getButtonStyle(context);

    if (type == FAButtonType.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    } else if (type == FAButtonType.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    } else {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    }
  }

  Widget _buildGradientButton(Widget child, double height) {
    final gradientColors = this.gradientColors ??
        [AppColors.buttonGradientStart, AppColors.buttonGradientEnd];
    final gradientBegin = this.gradientBegin ?? Alignment.topCenter;
    final gradientEnd = this.gradientEnd ?? Alignment.bottomCenter;
    final borderRadius = BorderRadius.circular(DesignSystem.radiusXL);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: gradientColors,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingMD,
              vertical: DesignSystem.spacingMD,
            ),
            alignment: Alignment.center,
            constraints: BoxConstraints(
              minHeight: height,
              minWidth: isFullWidth ? double.infinity : 0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  double _getButtonHeight() {
    switch (size) {
      case FAButtonSize.small:
        return DesignSystem.buttonHeightSM;
      case FAButtonSize.medium:
        return DesignSystem.buttonHeightMD;
      case FAButtonSize.large:
        return DesignSystem.buttonHeightLG;
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final height = _getButtonHeight();
    final bgColor = backgroundColor ?? _getBackgroundColor(context);
    final fgColor = foregroundColor ?? _getForegroundColor(context);

    switch (type) {
      case FAButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: DesignSystem.elevationNone,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        );
      case FAButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: DesignSystem.elevationNone,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        );
      case FAButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: BorderSide(
            color: AppColors.primary, // Use primary color for outline border
            width: DesignSystem.borderWidthThin,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        );
      case FAButtonType.gradient:
        // Gradient button is handled separately in _buildGradientButton
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: fgColor,
          elevation: DesignSystem.elevationNone,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        );
      case FAButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: fgColor,
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMD,
            vertical: DesignSystem.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        );
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case FAButtonType.primary:
        return AppColors.primary;
      case FAButtonType.secondary:
        return AppColors.secondary;
      case FAButtonType.outline:
      case FAButtonType.text:
      case FAButtonType.gradient:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(BuildContext context) {
    switch (type) {
      case FAButtonType.primary:
      case FAButtonType.secondary:
      case FAButtonType.gradient:
        return AppColors.textOnPrimary;
      case FAButtonType.outline:
      case FAButtonType.text:
        return AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    return AppTypography.button.copyWith(
      fontSize: size == FAButtonSize.small
          ? 12
          : size == FAButtonSize.medium
              ? 14
              : 16,
    );
  }
}

