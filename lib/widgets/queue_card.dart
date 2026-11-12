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
  final bool isLocked;

  const QueueCard({
    super.key,
    required this.document,
    this.studentOrDosen,
    this.queuePosition,
    this.onTap,
    this.trailingAction,
    this.showStudentInfo = true,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = document.isSedangDiperiksa && !isLocked;

    Color bgColor = Colors.white;
    Color borderColor = AppColors.border;
    double borderWidth = 1.0;

    if (isLocked) {
      bgColor = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFCBD5E1);
    } else if (isHighlighted) {
      bgColor = const Color(0xFFEFF6FF);
      borderColor = AppColors.primaryLight;
      borderWidth = 1.6;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isLocked ? 0.01 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag + FIFO Position + Status Badge / Lock Badge
            Row(
              children: [
                if (queuePosition != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLocked ? const Color(0xFF64748B) : AppColors.primary,
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
                    style: TextStyle(
                      color: isLocked ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF94A3B8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.lock_rounded, size: 12, color: Color(0xFF475569)),
                        SizedBox(width: 4),
                        Text(
                          'Terkunci (FIFO)',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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

            if (isLocked) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 13, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Menunggu giliran antrean FIFO (dokumen di atasnya wajib disetujui/direvisi dahulu)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (trailingAction != null) ...[
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

