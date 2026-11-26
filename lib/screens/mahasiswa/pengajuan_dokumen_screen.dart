import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/simada_repository.dart';
import '../../widgets/custom_button.dart';

class PengajuanDokumenScreen extends StatefulWidget {
  final UserModel mahasiswa;

  const PengajuanDokumenScreen({
    super.key,
    required this.mahasiswa,
  });

  @override
  State<PengajuanDokumenScreen> createState() => _PengajuanDokumenScreenState();
}

class _PengajuanDokumenScreenState extends State<PengajuanDokumenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final SimadaRepository _repo = SimadaRepository();

  String _selectedKategori = AppConstants.kategoriDokumen.first;
  String? _selectedDosenId;
  String? _selectedFilePath;
  String? _selectedFileName;
  double _selectedFileSizeMb = 0.0;
  bool _isPickingFile = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (_repo.dosenList.isNotEmpty) {
      _selectedDosenId = _repo.dosenList.first.userId;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  /// Membuka dialog direktori penyimpanan perangkat (Laptop/HP/PC)
  /// Membatasi ekstensi hanya untuk file .pdf dan maks 10 MB
  Future<void> _pickPdfFile() async {
    setState(() => _isPickingFile = true);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      // Tangani kondisi jika pengguna memilih file
      if (files.isNotEmpty) {
        final file = files.first;
        final lengthInBytes = file.lengthSync() ?? (await file.length()) ?? 0;
        final sizeMb = lengthInBytes > 0 ? (lengthInBytes / (1024 * 1024)) : 0.0;

        // Validasi ukuran dokumen maksimal 10 MB
        if (sizeMb > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file melebihi batas maksimal 10 MB!'),
                backgroundColor: AppColors.statusRevisi,
              ),
            );
          }
          return;
        }

        // Simpan path dan detail file ke dalam state form
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          _selectedFileSizeMb = double.parse(sizeMb.toStringAsFixed(2));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Berkas PDF dipilih: ${file.name} ($_selectedFileSizeMb MB)',
              ),
              backgroundColor: AppColors.statusProses,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Tangani kondisi aman jika pengguna membatalkan pilihan file (cancel dialog)
        if (mounted && _selectedFileName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pemilihan berkas PDF dibatalkan.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka direktori perangkat: $e'),
            backgroundColor: AppColors.statusRevisi,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDosenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih Dosen tujuan!'),
          backgroundColor: AppColors.statusRevisi,
        ),
      );
      return;
    }

    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih file PDF dokumen yang akan diunggah!'),
          backgroundColor: AppColors.statusRevisi,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      final doc = _repo.submitNewDocument(
        mahasiswaId: widget.mahasiswa.userId,
        dosenId: _selectedDosenId!,
        judulDokumen: _judulController.text.trim(),
        kategori: _selectedKategori,
        fileName: _selectedFileName!,
        filePath: _selectedFilePath,
        fileSizeMb: _selectedFileSizeMb,
      );

      setState(() => _isUploading = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.statusSelesai, size: 28),
                SizedBox(width: 8),
                Text('Pengajuan Berhasil!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berkas telah terdaftar dalam sistem antrean FIFO secara otomatis.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID Berkas: #${doc.dokumenId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Waktu Masuk: ${doc.createdAt.hour.toString().padLeft(2, '0')}:${doc.createdAt.minute.toString().padLeft(2, '0')} WIB',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Posisi: Menunggu Antrean Panggilan Dosen',
                        style: TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // pop dialog
                  Navigator.pop(context); // pop screen back to home
                },
                child: const Text('Ke Halaman Utama'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dosenList = _repo.dosenList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengajuan Dokumen Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box FIFO
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sistem SIMADA menerapkan antrean FIFO (First-In, First-Out). Berkas Anda akan diproses tepat sesuai urutan detik pengunggahan.',
                          style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori Dokumen
                      const Text(
                        'Kategori Dokumen *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedKategori,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: AppConstants.kategoriDokumen.map((kategori) {
                          return DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedKategori = val);
                        },
                      ),
                      const SizedBox(height: 18),

                      // Dosen Tujuan
                      const Text(
                        'Pilih Dosen Tujuan / Pemeriksa *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDosenId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: dosenList.map((dosen) {
                          return DropdownMenuItem(
                            value: dosen.userId,
                            child: Text('${dosen.namaLengkap} (${dosen.username})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedDosenId = val);
                        },
                      ),
                      const SizedBox(height: 18),

                      // Judul Dokumen
                      const Text(
                        'Judul Dokumen / Topik Bimbingan *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _judulController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan judul lengkap proposal atau dokumen Anda...',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Judul dokumen wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // File Picker Section (PDF format, max size)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Unggah Berkas PDF (Maks. 10 MB) *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          if (_selectedFileName != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 14),
                              label: const Text('Ganti File', style: TextStyle(fontSize: 11)),
                              onPressed: _isUploading ? null : _pickPdfFile,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isUploading ? null : _pickPdfFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: _selectedFileName != null
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedFileName != null
                                  ? AppColors.statusSelesai
                                  : AppColors.border,
                              width: _selectedFileName != null ? 1.6 : 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _isPickingFile
                              ? Column(
                                  children: const [
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Membuka direktori perangkat...',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Icon(
                                      _selectedFileName != null
                                          ? Icons.picture_as_pdf_rounded
                                          : Icons.folder_open_rounded,
                                      size: 38,
                                      color: _selectedFileName != null
                                          ? Colors.redAccent
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedFileName ?? 'Buka Direktori & Pilih File PDF',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedFileName != null
                                            ? AppColors.textPrimary
                                            : AppColors.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedFileName != null
                                          ? 'Ukuran: $_selectedFileSizeMb MB • Berkas siap diunggah'
                                          : 'Format dibatasi khusus: .pdf (Maksimum 10 MB)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _selectedFileName != null
                                            ? AppColors.statusSelesai
                                            : AppColors.textSecondary,
                                        fontWeight: _selectedFileName != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (_selectedFilePath != null) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          'Path: $_selectedFilePath',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF64748B),
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button (hanya aktif jika file sudah dipilih ke dalam state form)
                      CustomButton(
                        text: _selectedFileName == null
                            ? 'Pilih File PDF Dahulu (Tombol Dikunci)'
                            : 'Unggah & Ambil Nomor Antrean (FIFO)',
                        icon: Icons.send_rounded,
                        isLoading: _isUploading,
                        onPressed: (_selectedFileName != null && !_isUploading) ? _submit : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

