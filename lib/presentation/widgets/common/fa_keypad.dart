import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FAKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;

  const FAKeypad({
    super.key,
    required this.onKeyPressed,
    this.onBackspace,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        SizedBox(height: DesignSystem.spacingSM),
        _buildRow(['4', '5', '6']),
        SizedBox(height: DesignSystem.spacingSM),
        _buildRow(['7', '8', '9']),
        SizedBox(height: DesignSystem.spacingSM),
        Row(
          children: [
            Expanded(
              child: _buildKey(
                '0',
                onTap: () => onKeyPressed('0'),
              ),
            ),
            SizedBox(width: DesignSystem.spacingSM),
            Expanded(
              child: _buildKey(
                '⌫',
                onTap: onBackspace,
                backgroundColor: AppColors.error.withOpacity(0.1),
                textColor: AppColors.error,
              ),
            ),
            SizedBox(width: DesignSystem.spacingSM),
            Expanded(
              child: _buildKey(
                'C',
                onTap: onClear,
                backgroundColor: AppColors.warning.withOpacity(0.1),
                textColor: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys
          .map(
            (key) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: keys.indexOf(key) < keys.length - 1
                      ? DesignSystem.spacingSM
                      : 0,
                ),
                child: _buildKey(
                  key,
                  onTap: () => onKeyPressed(key),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKey(
    String key, {
    required VoidCallback? onTap,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusMD),
          border: Border.all(
            color: AppColors.border,
            width: DesignSystem.borderWidthThin,
          ),
        ),
        child: Center(
          child: Text(
            key,
            style: AppTypography.titleLarge.copyWith(
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}



