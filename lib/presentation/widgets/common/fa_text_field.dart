import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FATextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixIconPath; // SVG path for prefix icon
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool showBorder; // Whether to show border container

  const FATextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.prefixIconPath,
    this.suffixIcon,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.showBorder = false, // Default to false for backward compatibility
  });

  @override
  State<FATextField> createState() => _FATextFieldState();
}

class _FATextFieldState extends State<FATextField> {
  bool _obscureText = false;
  Key? _fieldKey;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    // Tạo key ổn định dựa trên controller để giữ text khi rebuild
    _fieldKey = widget.controller != null 
        ? ValueKey('text_field_${widget.controller.hashCode}')
        : UniqueKey();
  }

  Key get _getFieldKey {
    _fieldKey ??= widget.controller != null 
        ? ValueKey('text_field_${widget.controller.hashCode}')
        : UniqueKey();
    return _fieldKey!;
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      key: _getFieldKey,
      controller: widget.controller,
      obscureText: widget.obscureText ? _obscureText : false,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      autovalidateMode: AutovalidateMode.disabled,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: widget.showBorder
              ? AppColors.textHint
              : AppColors.textSecondary,
        ),
        errorText: null, // Error text will be shown below
        prefixIcon: _buildPrefixIcon(),
        suffixIcon: widget.suffixIcon != null
            ? widget.suffixIcon
            : (widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.iconSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMD,
          vertical: DesignSystem.spacingMD,
        ),
        filled: true,
        fillColor: widget.showBorder
            ? Colors.white
            : widget.enabled
                ? AppColors.surface
                : AppColors.background,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: DesignSystem.spacingXS),
        ],
        if (widget.showBorder)
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
              side: BorderSide(
                color: widget.errorText != null
                    ? AppColors.error
                    : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: textField,
          )
        else
          textField,
        if (widget.errorText != null) ...[
          SizedBox(height: DesignSystem.spacingXS),
          Padding(
            padding: EdgeInsets.only(left: DesignSystem.spacingMD),
            child: Text(
              widget.errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon;
    }
    return null;
  }
}

