import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? border;

    switch (type) {
      case ButtonType.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case ButtonType.secondary:
        bgColor = AppColors.secondary;
        fgColor = Colors.white;
        break;
      case ButtonType.outline:
        bgColor = Colors.white;
        fgColor = AppColors.primary;
        border = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case ButtonType.danger:
        bgColor = AppColors.statusRevisi;
        fgColor = Colors.white;
        break;
      case ButtonType.success:
        bgColor = AppColors.statusSelesai;
        fgColor = Colors.white;
        break;
    }

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: border ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

