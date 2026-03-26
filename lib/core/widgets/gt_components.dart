import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GTCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GTCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: border ?? Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GTButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isFullWidth;
  final bool isOutlined;

  const GTButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.isFullWidth = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.primary;
    final finalTextColor = textColor ?? (isOutlined ? AppColors.primary : AppColors.white);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: finalTextColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.buttonText.copyWith(color: finalTextColor),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bgColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: content,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: content,
            ),
    );
  }
}

class GTTexField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const GTTexField({
    super.key,
    required this.label,
    required this.icon,
    this.hint,
    this.controller,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    color: AppColors.textHint,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
