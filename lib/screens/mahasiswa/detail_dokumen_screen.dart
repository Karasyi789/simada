import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../services/simada_repository.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/pdf_document_viewer.dart';
import '../../widgets/custom_button.dart';
import 'unggah_revisi_screen.dart';

class DetailDokumenScreen extends StatefulWidget {
  final int dokumenId;

  const DetailDokumenScreen({super.key, required this.dokumenId});

  @override
  State<DetailDokumenScreen> createState() => _DetailDokumenScreenState();
}

class _DetailDokumenScreenState extends State<DetailDokumenScreen> {
  final SimadaRepository _repo = SimadaRepository();

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    super.dispose();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final doc = _repo.getDocumentById(widget.dokumenId);

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dokumen Tidak Ditemukan')),
        body: const Center(child: Text('Data dokumen tidak ditemukan.')),
      );
    }

    final dosen = _repo.getUserById(doc.dosenId);
    final revisions = _repo.getRevisionsForDocument(doc.dokumenId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Detail Dokumen #${doc.dokumenId}')),
      bottomNavigationBar: doc.status == AppConstants.statusRevisi
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Unggah Dokumen Revisi / Perbaikan',
                icon: Icons.upload_file_rounded,
                type: ButtonType.danger,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnggahRevisiScreen(document: doc),
                    ),
                  );
                },
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          doc.kategori,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      StatusBadge(status: doc.status, isLarge: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    doc.judulDokumen,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Dosen & Timestamp
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dosen: ${dosen?.namaLengkap ?? "-"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Diajukan: ${DateFormatter.formatFull(doc.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (doc.revisionCount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.history_edu,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Iterasi Revisi ke: ${doc.revisionCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Revision Alert Banner if in 'Revisi'
            if (doc.status == AppConstants.statusRevisi) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF87171)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Dosen Meminta Revisi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan periksa catatan koreksi di bawah ini, perbaiki dokumen Anda, lalu unggah file perbaikan.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Revision Notes List Section
            if (revisions.isNotEmpty) ...[
              const Text(
                'Catatan Koreksi dari Dosen',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: revisions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final rev = revisions[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (rev.halamanRevisi != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.statusRevisiBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Halaman ${rev.halamanRevisi}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              const Text(
                                'Catatan Umum',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            Text(
                              DateFormatter.formatShortDate(rev.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rev.catatan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Built-in PDF Viewer
            const Text(
              'Preview Dokumen PDF',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            PdfDocumentViewer(
              title: doc.judulDokumen,
              fileName: doc.fileName,
              revisions: revisions,
              isDosen: false,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
