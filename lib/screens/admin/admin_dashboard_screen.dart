import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/simada_repository.dart';
import '../../models/user_model.dart';
import 'user_management_screen.dart';
import 'laporan_aktivitas_screen.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    final bottleneckSummary = _repo.getDosenBottleneckSummary();
    final totalDocs = _repo.documents.length;
    final totalDone = _repo.documents.where((d) => d.isSelesai).length;
    final totalWaiting = _repo.documents.where((d) => d.isMenunggu).length;
    final hasBottleneck = bottleneckSummary.any(
      (b) => b['isBottleneck'] == true,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SIMADA • Panel Administrator & Prodi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'Manajemen Pengguna',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: 'Laporan & Log',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanAktivitasScreen(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Pengajuan',
                    value: '$totalDocs',
                    icon: Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Dalam Antrean',
                    value: '$totalWaiting',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.statusMenunggu,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Tuntas Validasi',
                    value: '$totalDone',
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusSelesai,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bottleneck Detection Warning Banner
            if (hasBottleneck) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_rounded, color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PERINGATAN BOTTLENECK TERDETEKSI!',
                            style: TextStyle(
                              color: Color(0xFF991B1B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Terdapat antrean menumpuk (≥ 3 berkas) pada dosen tertentu. Segera lakukan penyesuaian beban bimbingan prodi.',
                            style: TextStyle(
                              color: Color(0xFF7F1D1D),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section: Monitoring Keseluruhan & Beban Antrean Dosen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monitoring Beban Antrean Dosen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Real-time Polling',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Deteksi penumpukan berkas mahasiswa di setiap dosen pembimbing / penguji.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            // Dosen Queue Load List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bottleneckSummary.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = bottleneckSummary[index];
                final UserModel dosen = item['dosen'];
                final int waiting = item['waitingCount'];
                final int processing = item['processingCount'];
                final int finished = item['finishedCount'];
                final int totalActive = item['totalActive'];
                final bool isBottleneck = item['isBottleneck'];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isBottleneck ? Colors.redAccent : AppColors.border,
                      width: isBottleneck ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dosen.namaLengkap,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'NIP: ${dosen.username}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isBottleneck)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'BOTTLENECK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Queue Load Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (totalActive / 5).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isBottleneck ? Colors.red : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Metrics Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLoadItem(
                            'Menunggu',
                            '$waiting',
                            AppColors.statusMenunggu,
                          ),
                          _buildLoadItem(
                            'Sedang Diproses',
                            '$processing',
                            AppColors.statusProses,
                          ),
                          _buildLoadItem(
                            'Selesai',
                            '$finished',
                            AppColors.statusSelesai,
                          ),
                          _buildLoadItem(
                            'Total Antrean',
                            '$totalActive',
                            isBottleneck ? Colors.red : AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Menu Actions for Admin
            const Text(
              'Menu Pengelolaan Prodi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.manage_accounts_rounded),
                    label: const Text('Kelola Pengguna'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Ekspor Laporan'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LaporanAktivitasScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
