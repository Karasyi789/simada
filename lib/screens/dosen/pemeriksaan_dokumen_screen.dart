import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/document_model.dart';
import '../../services/simada_repository.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/pdf_document_viewer.dart';
import '../../widgets/custom_button.dart';

class PemeriksaanDokumenScreen extends StatefulWidget {
  final int dokumenId;

  const PemeriksaanDokumenScreen({super.key, required this.dokumenId});

  @override
  State<PemeriksaanDokumenScreen> createState() =>
      _PemeriksaanDokumenScreenState();
}

class _PemeriksaanDokumenScreenState extends State<PemeriksaanDokumenScreen> {
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

  void _addAnnotationFromViewer(int pageNumber, String note) {
    _repo.updateDocumentStatus(
      dokumenId: widget.dokumenId,
      newStatus: AppConstants.statusRevisi,
      revisionNotes: note,
      revisionPage: pageNumber,
    );
  }

  void _showChangeStatusDialog(DocumentModel doc) {
    String selectedStatus = doc.status;
    final noteController = TextEditingController();
    final pageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ubah Status Dokumen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Status Selector Options
              ...[
                AppConstants.statusSedangDiperiksa,
                AppConstants.statusRevisi,
                AppConstants.statusSelesai,
                AppConstants.statusMenunggu,
              ].map((statusOption) {
                return RadioListTile<String>(
                  title: Row(children: [StatusBadge(status: statusOption)]),
                  value: statusOption,
                  groupValue: selectedStatus,
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedStatus = val);
                    }
                  },
                );
              }),

              // If status is Revisi, show annotation/notes inputs
              if (selectedStatus == AppConstants.statusRevisi) ...[
                const SizedBox(height: 12),
                const Text(
                  'Catatan Koreksi & Nomor Halaman:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: pageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Halaman',
                          hintText: 'Misal: 3',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Revisi',
                          hintText: 'Apa yang perlu diperbaiki...',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // Confirm button
              CustomButton(
                text: 'Simpan Perubahan Status',
                icon: Icons.check,
                onPressed: () {
                  final pageNum = int.tryParse(pageController.text.trim());
                  _repo.updateDocumentStatus(
                    dokumenId: doc.dokumenId,
                    newStatus: selectedStatus,
                    revisionNotes: noteController.text.trim().isNotEmpty
                        ? noteController.text.trim()
                        : (selectedStatus == AppConstants.statusRevisi
                              ? 'Harap lengkapi dan revisi bagian dokumen ini.'
                              : null),
                    revisionPage: pageNum,
                  );

                  Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Status dokumen berhasil diubah ke: $selectedStatus',
                      ),
                      backgroundColor: AppColors.statusSelesai,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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

    final student = _repo.getUserById(doc.mahasiswaId);
    final revisions = _repo.getRevisionsForDocument(doc.dokumenId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pemeriksaan Berkas #${doc.dokumenId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Ubah Status',
            onPressed: () => _showChangeStatusDialog(doc),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Minta Revisi',
                icon: Icons.edit_note,
                type: ButtonType.danger,
                onPressed: () {
                  _repo.updateDocumentStatus(
                    dokumenId: doc.dokumenId,
                    newStatus: AppConstants.statusRevisi,
                    revisionNotes:
                        'Perlu perbaikan sesuai catatan yang diberikan.',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Dokumen ditandai: Minta Revisi ke Mahasiswa',
                      ),
                      backgroundColor: AppColors.statusRevisi,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Setujui / Selesai',
                icon: Icons.check_circle_outline,
                type: ButtonType.success,
                onPressed: () {
                  _repo.updateDocumentStatus(
                    dokumenId: doc.dokumenId,
                    newStatus: AppConstants.statusSelesai,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dokumen berhasil Disetujui & Selesai!'),
                      backgroundColor: AppColors.statusSelesai,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student & Document Overview
            Container(
              padding: const EdgeInsets.all(16),
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
                      StatusBadge(status: doc.status, isLarge: true),
                      InkWell(
                        onTap: () => _showChangeStatusDialog(doc),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ubah Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    doc.judulDokumen,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 6),

                  // Student Details
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mahasiswa: ${student?.namaLengkap ?? "-"} (${student?.username ?? "-"})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Program Studi: ${student?.prodi ?? "Teknik Informatika"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Waktu Masuk FIFO: ${DateFormatter.formatFull(doc.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Revision History if exists
            if (revisions.isNotEmpty) ...[
              const Text(
                'Catatan Koreksi Tersimpan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: revisions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final r = revisions[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.halamanRevisi != null
                                  ? 'Koreksi Halaman ${r.halamanRevisi}'
                                  : 'Koreksi Umum',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              DateFormatter.formatShortDate(r.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.catatan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
            ],

            // Built-in PDF Viewer with interactive annotation
            const Text(
              'Built-in PDF Viewer & Anotasi Halaman',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gunakan tombol "Beri Catatan" untuk menyematkan anotasi koreksi langsung di halaman yang sedang dibaca.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            PdfDocumentViewer(
              title: doc.judulDokumen,
              fileName: doc.fileName,
              revisions: revisions,
              isDosen: true,
              onAddAnnotation: _addAnnotationFromViewer,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
