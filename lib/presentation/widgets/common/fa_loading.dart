import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';

class FALoading extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const FALoading({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? DesignSystem.iconSizeXL,
            height: size ?? DesignSystem.iconSizeXL,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: DesignSystem.spacingMD),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}



