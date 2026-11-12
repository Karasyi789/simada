import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const StatusBadge({super.key, required this.status, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    IconData icon;

    switch (status) {
      case AppConstants.statusMenunggu:
        bg = AppColors.statusMenungguBg;
        textColor = const Color(0xFFB45309);
        icon = Icons.access_time_rounded;
        break;
      case AppConstants.statusSedangDiperiksa:
        bg = AppColors.statusProsesBg;
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.sync_rounded;
        break;
      case AppConstants.statusRevisi:
        bg = AppColors.statusRevisiBg;
        textColor = const Color(0xFFB91C1C);
        icon = Icons.edit_note_rounded;
        break;
      case AppConstants.statusSelesai:
        bg = AppColors.statusSelesaiBg;
        textColor = const Color(0xFF047857);
        icon = Icons.check_circle_rounded;
        break;
      default:
        bg = AppColors.divider;
        textColor = AppColors.textSecondary;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLarge ? 16 : 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: isLarge ? 13 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
