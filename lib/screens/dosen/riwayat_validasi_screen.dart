import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/simada_repository.dart';
import '../../widgets/queue_card.dart';
import 'pemeriksaan_dokumen_screen.dart';

class RiwayatValidasiScreen extends StatefulWidget {
  final String dosenId;

  const RiwayatValidasiScreen({super.key, required this.dosenId});

  @override
  State<RiwayatValidasiScreen> createState() => _RiwayatValidasiScreenState();
}

class _RiwayatValidasiScreenState extends State<RiwayatValidasiScreen> {
  final SimadaRepository _repo = SimadaRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final history = _repo.getValidationHistoryForDosen(widget.dosenId);
    final filtered = history.where((d) {
      final student = _repo.getUserById(d.mahasiswaId);
      final query = _searchQuery.toLowerCase();
      final titleMatch = d.judulDokumen.toLowerCase().contains(query);
      final studentMatch =
          student != null &&
          (student.namaLengkap.toLowerCase().contains(query) ||
              student.username.toLowerCase().contains(query));
      return titleMatch || studentMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Validasi Berkas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama mahasiswa atau judul berkas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),

            // List of completed/revised documents
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum Ada Riwayat Validasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Dokumen yang telah Disetujui atau Diminta Revisi akan muncul di sini.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final student = _repo.getUserById(doc.mahasiswaId);
                        return QueueCard(
                          document: doc,
                          studentOrDosen: student,
                          showStudentInfo: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PemeriksaanDokumenScreen(
                                  dokumenId: doc.dokumenId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
