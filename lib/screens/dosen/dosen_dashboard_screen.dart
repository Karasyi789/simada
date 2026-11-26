import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/simada_repository.dart';
import '../../widgets/queue_card.dart';
import '../../widgets/custom_button.dart';
import 'pemeriksaan_dokumen_screen.dart';
import 'riwayat_validasi_screen.dart';
import '../auth/login_screen.dart';

class DosenDashboardScreen extends StatefulWidget {
  const DosenDashboardScreen({super.key});

  @override
  State<DosenDashboardScreen> createState() => _DosenDashboardScreenState();
}

class _DosenDashboardScreenState extends State<DosenDashboardScreen> {
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

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _triggerNextQueue(String dosenId) {
    final currentlyExamining = _repo.getCurrentlyExaminingDoc(dosenId);
    if (currentlyExamining != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'FIFO Terkunci: Harap selesaikan (setujui atau revisi) Dokumen #${currentlyExamining.dokumenId} terlebih dahulu sebelum memanggil antrean berikutnya!',
          ),
          backgroundColor: AppColors.statusMenunggu,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final success = _repo.processNextQueue(dosenId);
    if (success) {
      final currentDoc = _repo.getCurrentlyExaminingDoc(dosenId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Antrean FIFO berikutnya berhasil ditarik: ${currentDoc?.judulDokumen ?? "Dokumen"}',
          ),
          backgroundColor: AppColors.statusProses,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada mahasiswa dalam antrean "Menunggu"!'),
          backgroundColor: AppColors.statusMenunggu,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _repo.currentUser ?? _repo.dosenList.first;
    final activeQueue = _repo.getActiveQueueForDosen(user.userId);
    final currentlyExamining = _repo.getCurrentlyExaminingDoc(user.userId);
    final nextWaiting = _repo.getNextWaitingDocument(user.userId);
    final validationHistory = _repo.getValidationHistoryForDosen(user.userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Bimbingan Dosen',
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
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Validasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RiwayatValidasiScreen(dosenId: user.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. STATS BANNER
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Antrean Aktif',
                      count: activeQueue.length,
                      icon: Icons.people_alt_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Perlu Diperiksa',
                      count: activeQueue.where((d) => d.isMenunggu).length,
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.statusMenunggu,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Selesai Divalidasi',
                      count: validationHistory.where((d) => d.isSelesai).length,
                      icon: Icons.verified_outlined,
                      color: AppColors.statusSelesai,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ==========================================
              // 2. NEXT QUEUE ACTION BAR (FIFO DISPATCHER)
              // ==========================================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.format_list_numbered_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PENGENDALI ANTREAN OTOMATIS (FIFO)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentlyExamining != null
                          ? 'Dokumen #${currentlyExamining.dokumenId} (${_repo.getUserById(currentlyExamining.mahasiswaId)?.namaLengkap}) sedang diperiksa. Dokumen ini wajib disetujui atau direvisi terlebih dahulu sebelum antrean berikutnya dibuka.'
                          : (nextWaiting != null
                              ? 'Antrean teratas yang siap diproses: ${_repo.getUserById(nextWaiting.mahasiswaId)?.namaLengkap} (#${nextWaiting.dokumenId})'
                              : 'Semua antrean bimbingan telah dipanggil / tidak ada antrean menunggu.'),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: currentlyExamining != null
                          ? 'Selesaikan Pemeriksaan Aktif Dahulu'
                          : 'Panggil Antrean Berikutnya (Next Queue)',
                      icon: currentlyExamining != null
                          ? Icons.lock_clock_rounded
                          : Icons.skip_next_rounded,
                      type: currentlyExamining != null
                          ? ButtonType.outline
                          : ButtonType.secondary,
                      onPressed: (currentlyExamining == null && nextWaiting != null)
                          ? () => _triggerNextQueue(user.userId)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 3. CURRENTLY BEING EXAMINED (IF ANY)
              // ==========================================
              if (currentlyExamining != null) ...[
                const Text(
                  'Sedang Dalam Pemeriksaan Anda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                QueueCard(
                  document: currentlyExamining,
                  studentOrDosen: _repo.getUserById(
                    currentlyExamining.mahasiswaId,
                  ),
                  trailingAction: CustomButton(
                    text: 'Buka PDF & Beri Catatan / Ubah Status',
                    icon: Icons.edit_document,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PemeriksaanDokumenScreen(
                            dokumenId: currentlyExamining.dokumenId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ==========================================
              // 4. DAFTAR ANTREAN FIFO DOSEN
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Antrean Mahasiswa (FIFO Terurut)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${activeQueue.length} Berkas',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Urutan ditentukan otomatis berdasarkan created_at timestamp mahasiswa.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              if (activeQueue.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppColors.statusSelesai,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Antrean Kosong',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Belum ada mahasiswa baru yang mengajukan berkas ke Anda.',
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
                  itemCount: activeQueue.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = activeQueue[index];
                    final student = _repo.getUserById(doc.mahasiswaId);
                    // Pengecekan FIFO: Cek apakah dokumen ini terkunci berdasarkan status indeks sebelumnya
                    final isLocked = _repo.isQueueItemLocked(activeQueue, index);

                    return QueueCard(
                      document: doc,
                      studentOrDosen: student,
                      queuePosition: index + 1,
                      isLocked: isLocked,
                      onTap: () {
                        if (isLocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Antrean Terkunci (FIFO): Dokumen #${doc.dokumenId} (urutan ke-${index + 1}) belum bisa divalidasi. Selesaikan (setujui atau revisi) dokumen urutan sebelumnya (${activeQueue[index - 1].judulDokumen}) terlebih dahulu.',
                              ),
                              backgroundColor: const Color(0xFF334155),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PemeriksaanDokumenScreen(
                                dokumenId: doc.dokumenId,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
