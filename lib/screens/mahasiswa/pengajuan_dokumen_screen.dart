import 'package:flutter/material.dart';
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
  String? _selectedFileName;
  double _selectedFileSizeMb = 0.0;
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

  // Simulated PDF File Picker with format & size validation
  void _pickPdfFile() {
    // Generate realistic sample filename based on category & student
    final cleanNim = widget.mahasiswa.username;
    final catCode = _selectedKategori.replaceAll(' ', '_');
    final mockFileName = '${catCode}_${cleanNim}_TA2026.pdf';
    final mockSize = 2.45; // MB (< 10MB limit)

    setState(() {
      _selectedFileName = mockFileName;
      _selectedFileSizeMb = mockSize;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berkas terpilih: $mockFileName (${mockSize} MB)'),
        backgroundColor: AppColors.statusProses,
        duration: const Duration(seconds: 2),
      ),
    );
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
                      const Text(
                        'Unggah Berkas PDF (Maks. 10 MB) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickPdfFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedFileName != null
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: _selectedFileName != null ? 1.5 : 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFileName != null
                                    ? Icons.check_circle_rounded
                                    : Icons.cloud_upload_outlined,
                                size: 36,
                                color: _selectedFileName != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFileName ?? 'Ketuk untuk Memilih Berkas PDF',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedFileName != null
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFileName != null
                                    ? 'Ukuran: $_selectedFileSizeMb MB • Format valid PDF'
                                    : 'Format yang didukung: .pdf (Maksimum 10 MB)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      CustomButton(
                        text: 'Unggah & Ambil Nomor Antrean (FIFO)',
                        icon: Icons.send_rounded,
                        isLoading: _isUploading,
                        onPressed: _submit,
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

