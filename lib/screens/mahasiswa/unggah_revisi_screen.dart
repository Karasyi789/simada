import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/document_model.dart';
import '../../services/simada_repository.dart';
import '../../widgets/custom_button.dart';

class UnggahRevisiScreen extends StatefulWidget {
  final DocumentModel document;

  const UnggahRevisiScreen({
    super.key,
    required this.document,
  });

  @override
  State<UnggahRevisiScreen> createState() => _UnggahRevisiScreenState();
}

class _UnggahRevisiScreenState extends State<UnggahRevisiScreen> {
  final _keteranganController = TextEditingController();
  final SimadaRepository _repo = SimadaRepository();

  String? _selectedFilePath;
  String? _selectedFileName;
  double _selectedFileSizeMb = 0.0;
  bool _isPickingFile = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickRevisedFile() async {
    setState(() => _isPickingFile = true);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final lengthInBytes = file.lengthSync() ?? (await file.length()) ?? 0;
        final sizeMb = lengthInBytes > 0 ? (lengthInBytes / (1024 * 1024)) : 0.0;

        if (sizeMb > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran berkas melebihi batas maksimal 10 MB!'),
                backgroundColor: AppColors.statusRevisi,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          _selectedFileSizeMb = double.parse(sizeMb.toStringAsFixed(2));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berkas revisi dipilih: ${file.name} ($_selectedFileSizeMb MB)'),
              backgroundColor: AppColors.statusProses,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted && _selectedFileName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pemilihan berkas perbaikan dibatalkan.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih berkas PDF: $e'),
            backgroundColor: AppColors.statusRevisi,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _submitRevision() {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih berkas PDF perbaikan terlebih dahulu!'),
          backgroundColor: AppColors.statusRevisi,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      _repo.submitRevisionDocument(
        dokumenId: widget.document.dokumenId,
        fileName: _selectedFileName!,
        filePath: _selectedFilePath,
        fileSizeMb: _selectedFileSizeMb,
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.statusSelesai, size: 28),
                SizedBox(width: 8),
                Text('Revisi Berhasil Dikirim!'),
              ],
            ),
            content: const Text(
              'Dokumen Anda telah diperbarui dan dimasukkan kembali ke antrean bimbingan dosen dengan urutan FIFO terkini.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close dialog
                  Navigator.pop(context); // close unggah revisi screen
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Unggah Dokumen Perbaikan (Revisi)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dokumen Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dokumen Yang Direvisi:',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.document.judulDokumen,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nama file sebelumnya: ${widget.document.fileName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // File Picker
              const Text(
                'Pilih File PDF Hasil Revisi *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickRevisedFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedFileName != null ? AppColors.primary : AppColors.border,
                      width: _selectedFileName != null ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_isPickingFile)
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      else
                        Icon(
                          _selectedFileName != null ? Icons.task_alt_rounded : Icons.cloud_upload_outlined,
                          size: 38,
                          color: _selectedFileName != null ? AppColors.primary : AppColors.textSecondary,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName ?? 'Ketuk untuk Memilih File Perbaikan (.pdf)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedFileName != null ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFileName != null
                            ? 'Ukuran: $_selectedFileSizeMb MB'
                            : 'Maks. 10 MB (Format PDF)',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Catatan Perbaikan Tambahan (Optional)
              const Text(
                'Catatan Perubahan (Poin yang sudah diperbaiki)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan ringkas perbaikan yang telah dilakukan pada dokumen ini...',
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: 'Kirimkan Dokumen Revisi (Masuk Antrean FIFO)',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _submitRevision,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

