import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../services/simada_repository.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';

class LaporanAktivitasScreen extends StatefulWidget {
  const LaporanAktivitasScreen({super.key});

  @override
  State<LaporanAktivitasScreen> createState() => _LaporanAktivitasScreenState();
}

class _LaporanAktivitasScreenState extends State<LaporanAktivitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SimadaRepository _repo = SimadaRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repo.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _repo.removeListener(_onRepoChange);
    super.dispose();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  void _simulateExport(String format) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              format == 'Excel'
                  ? Icons.table_chart_rounded
                  : Icons.picture_as_pdf_rounded,
              color: format == 'Excel' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text('Ekspor Laporan $format'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File rekapitulasi pengajuan dokumen bimbingan akademik (${_repo.documents.length} data) siap diunduh untuk keperluan akreditasi BAN-PT / LAM-INFOKOM.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Nama Berkas: REKAP_SIMADA_AKREDITASI_${DateTime.now().year}_${format.toLowerCase()}.${format == "Excel" ? "xlsx" : "pdf"}',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Laporan $format berhasil diekspor dan disimpan!',
                  ),
                  backgroundColor: AppColors.statusSelesai,
                ),
              );
            },
            child: const Text('Unduh File'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = _repo.documents;
    final logs = _repo.activityLogs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan & Log Aktivitas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.table_rows_rounded),
              text: 'Rekapitulasi Berkas',
            ),
            Tab(
              icon: Icon(Icons.history_toggle_off_rounded),
              text: 'Log Audit Sistem',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Rekapitulasi Berkas untuk Akreditasi
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Export Action Bar
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Ekspor Excel (.xlsx)',
                        icon: Icons.table_view_rounded,
                        type: ButtonType.secondary,
                        onPressed: () => _simulateExport('Excel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Cetak Laporan PDF',
                        icon: Icons.picture_as_pdf,
                        type: ButtonType.primary,
                        onPressed: () => _simulateExport('PDF'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Rekapitulasi Pengajuan Dokumen (${docs.length} entri):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                // Table View
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xFFF8FAFC),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'ID Berkas',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Mahasiswa (NIM)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Kategori',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Dosen Pemeriksa',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Waktu Masuk FIFO',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: docs.map((doc) {
                            final mhs = _repo.getUserById(doc.mahasiswaId);
                            final dsn = _repo.getUserById(doc.dosenId);
                            return DataRow(
                              cells: [
                                DataCell(Text('#${doc.dokumenId}')),
                                DataCell(
                                  Text(
                                    '${mhs?.namaLengkap ?? "-"} (${mhs?.username ?? "-"})',
                                  ),
                                ),
                                DataCell(Text(doc.kategori)),
                                DataCell(Text(dsn?.namaLengkap ?? "-")),
                                DataCell(StatusBadge(status: doc.status)),
                                DataCell(
                                  Text(DateFormatter.formatFull(doc.createdAt)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: Log Audit Sistem Real-time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Log Aktivitas Real-time (Audit Trail)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${logs.length} Peristiwa',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Color(0xFF334155), height: 12),
                      itemBuilder: (context, index) {
                        final logText = logs[index];
                        return Text(
                          logText,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontFamily: 'Courier',
                            fontSize: 12,
                            height: 1.4,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
