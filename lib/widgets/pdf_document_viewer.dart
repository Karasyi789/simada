import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/revision_model.dart';

class PdfDocumentViewer extends StatefulWidget {
  final String title;
  final String fileName;
  final List<RevisionModel> revisions;
  final Function(int pageNumber, String note)? onAddAnnotation;
  final bool isDosen;

  const PdfDocumentViewer({
    super.key,
    required this.title,
    required this.fileName,
    this.revisions = const [],
    this.onAddAnnotation,
    this.isDosen = false,
  });

  @override
  State<PdfDocumentViewer> createState() => _PdfDocumentViewerState();
}

class _PdfDocumentViewerState extends State<PdfDocumentViewer> {
  int _currentPage = 1;
  final int _totalPages = 5;
  double _zoomScale = 1.0;

  final Map<int, String> _samplePageContents = {
    1: 'LEMBAR JUDUL / COVER\n\n'
        'SISTEM INFORMASI MANAJEMEN AKADEMIK\n'
        'Disusun sebagai salah satu syarat kelulusan program sarjana strata 1.\n\n'
        'Fakultas Ilmu Komputer & Teknologi Informasi\n'
        'Universitas Akademika Indonesia\n'
        'Tahun Akademik 2026/2027',
    2: 'BAB I - PENDAHULUAN\n\n'
        '1.1 Latar Belakang\n'
        'Birokrasi administrasi dokumen akademik sering menghadapi kendala antrean panjang '
        'dan ketidakpastian status persetujuan. Mahasiswa kerap menunggu tanpa kepastian posisi antrean, '
        'sedangkan dosen pembimbing mengalami kendala penumpukan dokumen.\n\n'
        '1.2 Rumusan Masalah\n'
        'Bagaimana merancang arsitektur antrean otomatis FIFO (First-In, First-Out) yang transparan, '
        'terintegrasi dengan real-time live monitoring dan built-in annotation tool?',
    3: 'BAB II - TINJAUAN PUSTAKA\n\n'
        '2.1 Algoritma First-In First-Out (FIFO)\n'
        'Algoritma FIFO memastikan entitas yang masuk terlebih dahulu ke antrean bimbingan '
        'akan dieksekusi terlebih dahulu berdasarkan timestamp pengajuan tanpa penyerobotan urutan.\n\n'
        '2.2 Role-Based Access Control (RBAC)\n'
        'Sistem memisahkan wewenang antara Mahasiswa (pengunggah), Dosen (pemeriksa berkas & anotator), '
        'dan Administrator (pemantau bottleneck & pengelola pengguna).',
    4: 'BAB III - METODOLOGI PENELITIAN\n\n'
        '3.1 Alur Pengujian Sistem\n'
        '- Tahap 1: Pengunggahan berkas PDF proposal oleh mahasiswa.\n'
        '- Tahap 2: Pemberian tiket antrean FIFO otomatis.\n'
        '- Tahap 3: Dosen memanggil antrean urutan teratas (Next Queue).\n'
        '- Tahap 4: Pemeriksaan berkas dan pemberian catatan koreksi.\n\n'
        '3.2 Diagram Arsitektur Berkas Terlampir.',
    5: 'BAB IV - DAFTAR PUSTAKA & LAMPIRAN\n\n'
        '[1] Tanenbaum, A. S. Modern Operating Systems, Principles of Queue Scheduling.\n'
        '[2] Pressman, R. S. Software Engineering: A Practitioner’s Approach.\n'
        '[3] Panduan Penulisan Skripsi & Tugas Akhir Akademik 2026.',
  };

  void _showAddAnnotationDialog() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.note_add_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Anotasi Halaman $_currentPage'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tulis catatan koreksi yang akan disematkan langsung pada halaman ini:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Contoh: Perbaiki rumus di baris 3 dan cantumkan sumber referensi...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty && widget.onAddAnnotation != null) {
                widget.onAddAnnotation!(_currentPage, noteController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Anotasi berhasil disematkan di Halaman $_currentPage'),
                    backgroundColor: AppColors.statusProses,
                  ),
                );
              }
            },
            child: const Text('Simpan Catatan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageRevisions = widget.revisions.where((r) => r.halamanRevisi == _currentPage).toList();

    return Column(
      children: [
        // Top Toolbar (File Info & Zoom & Page navigation)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Zoom Controls
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
                tooltip: 'Perkecil',
                onPressed: () {
                  setState(() {
                    if (_zoomScale > 0.8) _zoomScale -= 0.1;
                  });
                },
              ),
              Text(
                '${(_zoomScale * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
                tooltip: 'Perbesar',
                onPressed: () {
                  setState(() {
                    if (_zoomScale < 1.4) _zoomScale += 0.1;
                  });
                },
              ),
            ],
          ),
        ),

        // Document Canvas (Paper-like view)
        Container(
          constraints: const BoxConstraints(minHeight: 340, maxHeight: 420),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF475569),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Center(
              child: Transform.scale(
                scale: _zoomScale,
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paper Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SIMADA PDF VIEWER • DOKUMEN RESMI',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Hal $_currentPage / $_totalPages',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Document Content Simulation
                      Text(
                        _samplePageContents[_currentPage] ?? 'Konten Halaman...',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: Color(0xFF1F2937),
                          fontFamily: 'Courier',
                        ),
                      ),

                      // Page Specific Revision Annotations if any
                      if (pageRevisions.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.edit_note, color: Colors.red, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Catatan Koreksi Halaman Ini:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ...pageRevisions.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• ${r.catatan}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom Navigation Bar for PDF
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev / Next Page Buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 12),
                    label: const Text('Sebelumnya', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_currentPage dari $_totalPages',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 12),
                    label: const Text('Berikutnya', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              // Dosen Annotation Action Button
              if (widget.isDosen)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: _showAddAnnotationDialog,
                  icon: const Icon(Icons.add_comment_rounded, size: 15),
                  label: const Text('Beri Catatan', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

