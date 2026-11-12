import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/simada_repository.dart';
import '../../models/user_model.dart';
import '../../models/document_model.dart';
import '../../widgets/queue_card.dart';
import 'pengajuan_dokumen_screen.dart';
import 'detail_dokumen_screen.dart';
import '../auth/login_screen.dart';

class MahasiswaHomeScreen extends StatefulWidget {
  const MahasiswaHomeScreen({super.key});

  @override
  State<MahasiswaHomeScreen> createState() => _MahasiswaHomeScreenState();
}

class _MahasiswaHomeScreenState extends State<MahasiswaHomeScreen> {
  final SimadaRepository _repo = SimadaRepository();
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepositoryUpdate);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepositoryUpdate);
    super.dispose();
  }

  void _onRepositoryUpdate() {
    if (mounted) setState(() {});
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _repo.currentUser ?? _repo.mahasiswaList.first;
    final liveStatus = _repo.getLiveQueueStatusForMahasiswa(user.userId);
    final allMyDocs = _repo.getDocumentsByMahasiswa(user.userId);

    final filteredDocs = allMyDocs.where((doc) {
      if (_selectedFilter == 'Semua') return true;
      return doc.status == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIMADA Mahasiswa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${user.namaLengkap} (${user.username})',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui Status',
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Ajukan Dokumen'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PengajuanDokumenScreen(mahasiswa: user),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. LIVE STATUS MONITORING CARD
              // ==========================================
              _buildLiveMonitoringSection(liveStatus),
              const SizedBox(height: 24),

              // ==========================================
              // 2. QUICK ACTION & BERKAS SAYA HEADER
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Pengajuan Berkas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${allMyDocs.length} Dokumen',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        'Semua',
                        AppConstants.statusMenunggu,
                        AppConstants.statusSedangDiperiksa,
                        AppConstants.statusRevisi,
                        AppConstants.statusSelesai,
                      ].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(filter),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            onSelected: (val) {
                              setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Document List
              if (filteredDocs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum Ada Dokumen',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Silakan klik "Ajukan Dokumen" di bawah untuk mengunggah proposal atau skripsi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final dosen = _repo.getUserById(doc.dosenId);
                    return QueueCard(
                      document: doc,
                      studentOrDosen: dosen,
                      showStudentInfo: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailDokumenScreen(dokumenId: doc.dokumenId),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 80), // spacing for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveMonitoringSection(Map<String, dynamic>? liveStatus) {
    if (liveStatus == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.secondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tidak Ada Antrean Aktif',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Semua berkas Anda telah selesai diproses atau belum ada berkas baru yang diajukan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final DocumentModel doc = liveStatus['document'];
    final UserModel? dosen = liveStatus['dosen'];
    final int currentPos = liveStatus['currentPosition'];
    final int totalQ = liveStatus['totalQueue'];
    final bool isBeingProcessed = liveStatus['isBeingProcessedNow'];
    final int estWait = liveStatus['estimatedMinutesWait'];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBeingProcessed
              ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB)]
              : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isBeingProcessed ? AppColors.primary : Colors.black)
                .withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge Real-time Live
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isBeingProcessed
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFFBBF24),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isBeingProcessed
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFFBBF24))
                              .withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE STATUS MONITORING (FIFO)',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  doc.kategori,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Live Status Banner
          if (isBeingProcessed) ...[
            const Text(
              'SEDANG DIPERIKSA SEKARANG',
              style: TextStyle(
                color: Color(0xFF4ADE80),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dokumen Anda sedang dibuka dan ditinjau oleh ${dosen?.namaLengkap ?? "Dosen"}.',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ] else ...[
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                children: [
                  const TextSpan(text: 'Antrean Anda saat ini nomor urut '),
                  TextSpan(
                    text: '$currentPos ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                  TextSpan(
                    text: 'dari $totalQ mahasiswa',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dosen Tujuan: ${dosen?.namaLengkap ?? "Dosen"}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Progress Bar / Queue Position Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalQ > 0 ? (totalQ - currentPos + 1) / totalQ : 1.0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isBeingProcessed
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFBBF24),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // Bottom card metadata & link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Estimasi tunggu: ~$estWait menit',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailDokumenScreen(dokumenId: doc.dokumenId),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
