import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

enum FAAvatarSize {
  xs,
  sm,
  md,
  lg,
  xl,
}

class FAAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final FAAvatarSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? fallbackIcon;

  const FAAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = FAAvatarSize.md,
    this.backgroundColor,
    this.textColor,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getSize();
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? AppColors.textOnPrimary;
    final fontSize = _getFontSize();

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl == null ? bgColor : null,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.background,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: bgColor,
                  child: Icon(
                    fallbackIcon ?? Icons.person,
                    color: txtColor,
                    size: avatarSize * 0.6,
                  ),
                ),
              ),
            )
          : Center(
              child: name != null && name!.isNotEmpty
                  ? Text(
                      _getInitials(name!),
                      style: AppTypography.titleMedium.copyWith(
                        color: txtColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(
                      fallbackIcon ?? Icons.person,
                      color: txtColor,
                      size: avatarSize * 0.6,
                    ),
            ),
    );
  }

  double _getSize() {
    switch (size) {
      case FAAvatarSize.xs:
        return DesignSystem.avatarSizeXS;
      case FAAvatarSize.sm:
        return DesignSystem.avatarSizeSM;
      case FAAvatarSize.md:
        return DesignSystem.avatarSizeMD;
      case FAAvatarSize.lg:
        return DesignSystem.avatarSizeLG;
      case FAAvatarSize.xl:
        return DesignSystem.avatarSizeXL;
    }
  }

  double _getFontSize() {
    switch (size) {
      case FAAvatarSize.xs:
        return 10;
      case FAAvatarSize.sm:
        return 12;
      case FAAvatarSize.md:
        return 16;
      case FAAvatarSize.lg:
        return 20;
      case FAAvatarSize.xl:
        return 24;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}



