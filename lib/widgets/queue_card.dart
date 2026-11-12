import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import 'status_badge.dart';

class QueueCard extends StatelessWidget {
  final DocumentModel document;
  final UserModel? studentOrDosen;
  final int? queuePosition;
  final VoidCallback? onTap;
  final Widget? trailingAction;
  final bool showStudentInfo;

  const QueueCard({
    super.key,
    required this.document,
    this.studentOrDosen,
    this.queuePosition,
    this.onTap,
    this.trailingAction,
    this.showStudentInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = document.isSedangDiperiksa;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted ? AppColors.primaryLight : AppColors.border,
            width: isHighlighted ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag + FIFO Position + Status Badge
            Row(
              children: [
                if (queuePosition != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FIFO #$queuePosition',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    document.kategori,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                StatusBadge(status: document.status),
              ],
            ),
            const SizedBox(height: 10),

            // Document Title
            Text(
              document.judulDokumen,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // User Info (Mahasiswa NIM / Dosen NIP)
            if (studentOrDosen != null) ...[
              Row(
                children: [
                  Icon(
                    showStudentInfo ? Icons.person_outline_rounded : Icons.school_outlined,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${studentOrDosen!.namaLengkap} (${studentOrDosen!.username})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            // Timestamp FIFO & File detail
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Masuk: ${DateFormatter.formatTime(document.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 14,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${document.fileSizeMb} MB',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            if (trailingAction != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              trailingAction!,
            ],
          ],
        ),
      ),
    );
  }
}

