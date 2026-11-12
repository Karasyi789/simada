import '../models/user_model.dart';
import '../models/document_model.dart';
import '../models/queue_model.dart';
import '../models/revision_model.dart';
import '../core/constants/app_constants.dart';

class MockData {
  // Mock Users
  static List<UserModel> initialUsers = [
    // Mahasiswa
    UserModel(
      userId: 'mhs_001',
      username: '2021001',
      namaLengkap: 'Ahmad Fauzi',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      email: 'ahmad.fauzi@student.univ.ac.id',
      prodi: 'Teknik Informatika',
    ),
    UserModel(
      userId: 'mhs_002',
      username: '2021002',
      namaLengkap: 'Siti Rahmawati',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      email: 'siti.rahma@student.univ.ac.id',
      prodi: 'Teknik Informatika',
    ),
    UserModel(
      userId: 'mhs_003',
      username: '2021003',
      namaLengkap: 'Budi Santoso',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      email: 'budi.santoso@student.univ.ac.id',
      prodi: 'Sistem Informasi',
    ),
    UserModel(
      userId: 'mhs_004',
      username: '2021004',
      namaLengkap: 'Dewi Lestari',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      email: 'dewi.lestari@student.univ.ac.id',
      prodi: 'Teknik Informatika',
    ),

    // Dosen
    UserModel(
      userId: 'dsn_001',
      username: '198501012010121001',
      namaLengkap: 'Dr. Budi Prasetyo, M.T.',
      role: AppConstants.roleDosen,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
      email: 'budi.prasetyo@univ.ac.id',
      prodi: 'Teknik Informatika',
    ),
    UserModel(
      userId: 'dsn_002',
      username: '197805122005012002',
      namaLengkap: 'Prof. Dr. Sri Wahyuni, M.Kom.',
      role: AppConstants.roleDosen,
      createdAt: DateTime.now().subtract(const Duration(days: 600)),
      email: 'sri.wahyuni@univ.ac.id',
      prodi: 'Teknik Informatika',
    ),
    UserModel(
      userId: 'dsn_003',
      username: '198203152008121003',
      namaLengkap: 'Ir. Hendra Wijaya, Ph.D.',
      role: AppConstants.roleDosen,
      createdAt: DateTime.now().subtract(const Duration(days: 450)),
      email: 'hendra.wijaya@univ.ac.id',
      prodi: 'Sistem Informasi',
    ),

    // Admin
    UserModel(
      userId: 'adm_001',
      username: 'adminprodi',
      namaLengkap: 'Biro Administrasi Akademik & Kemahasiswaan',
      role: AppConstants.roleAdmin,
      createdAt: DateTime.now().subtract(const Duration(days: 800)),
      email: 'baak@univ.ac.id',
      prodi: 'Fakultas Ilmu Komputer',
    ),
  ];

  // Initial Documents seeded in FIFO chronological order
  static List<DocumentModel> initialDocuments = [
    DocumentModel(
      dokumenId: 101,
      mahasiswaId: 'mhs_001',
      dosenId: 'dsn_001',
      judulDokumen: 'Rancang Bangun Sistem Informasi Monitoring Magang Berbasis Web',
      kategori: 'Proposal',
      filePath: 'dokumen/2026/proposal_ahmad_fauzi.pdf',
      fileName: 'Proposal_Ahmad_Fauzi_TI.pdf',
      fileSizeMb: 2.4,
      status: AppConstants.statusSedangDiperiksa, // Sedang diproses Dosen
      createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
    ),
    DocumentModel(
      dokumenId: 102,
      mahasiswaId: 'mhs_002',
      dosenId: 'dsn_001',
      judulDokumen: 'Implementasi Algoritma FIFO pada Antrean Bimbingan Akademik',
      kategori: 'Proposal',
      filePath: 'dokumen/2026/proposal_siti_rahma.pdf',
      fileName: 'Proposal_Siti_Rahma_v1.pdf',
      fileSizeMb: 3.1,
      status: AppConstants.statusMenunggu, // Antrean berikutnya setelah Ahmad
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
    ),
    DocumentModel(
      dokumenId: 103,
      mahasiswaId: 'mhs_003',
      dosenId: 'dsn_001',
      judulDokumen: 'Analisis Keamanan Jaringan Menggunakan Intrusion Detection System',
      kategori: 'Skripsi',
      filePath: 'dokumen/2026/skripsi_budi_santoso.pdf',
      fileName: 'Bab1_3_Budi_Santoso.pdf',
      fileSizeMb: 4.8,
      status: AppConstants.statusMenunggu,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    ),
    DocumentModel(
      dokumenId: 104,
      mahasiswaId: 'mhs_004',
      dosenId: 'dsn_001',
      judulDokumen: 'Surat Pengantar Penelitian Instansi Dinas Kominfo',
      kategori: 'Surat Pengantar',
      filePath: 'dokumen/2026/surat_dewi.pdf',
      fileName: 'Surat_Pengantar_Dewi_Lestari.pdf',
      fileSizeMb: 0.9,
      status: AppConstants.statusRevisi,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      revisionCount: 1,
    ),
    DocumentModel(
      dokumenId: 105,
      mahasiswaId: 'mhs_001',
      dosenId: 'dsn_002',
      judulDokumen: 'Penerapan Deep Learning untuk Deteksi Kerusakan Tanaman Padi',
      kategori: 'Skripsi',
      filePath: 'dokumen/2026/skripsi_ahmad_fauzi.pdf',
      fileName: 'Skripsi_Ahmad_Fauzi_Full.pdf',
      fileSizeMb: 5.6,
      status: AppConstants.statusSelesai,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DocumentModel(
      dokumenId: 106,
      mahasiswaId: 'mhs_003',
      dosenId: 'dsn_003',
      judulDokumen: 'Pengembangan Dashboard Eksekutif Penjualan Menggunakan PowerBI',
      kategori: 'Laporan Magang / PKL',
      filePath: 'dokumen/2026/laporan_pkl_budi.pdf',
      fileName: 'Laporan_PKL_Budi_Santoso.pdf',
      fileSizeMb: 2.1,
      status: AppConstants.statusMenunggu,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  // Initial Queues
  static List<QueueModel> initialQueues = [
    QueueModel(
      antreanId: 1,
      dokumenId: 101,
      dosenId: 'dsn_001',
      nomorAntrean: 1,
      posisiSekarang: AppConstants.queueProcessing,
      waktuMasuk: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
    ),
    QueueModel(
      antreanId: 2,
      dokumenId: 102,
      dosenId: 'dsn_001',
      nomorAntrean: 2,
      posisiSekarang: AppConstants.queueWaiting,
      waktuMasuk: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
    ),
    QueueModel(
      antreanId: 3,
      dokumenId: 103,
      dosenId: 'dsn_001',
      nomorAntrean: 3,
      posisiSekarang: AppConstants.queueWaiting,
      waktuMasuk: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    ),
    QueueModel(
      antreanId: 4,
      dokumenId: 104,
      dosenId: 'dsn_001',
      nomorAntrean: 4,
      posisiSekarang: AppConstants.queueDone,
      waktuMasuk: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    QueueModel(
      antreanId: 5,
      dokumenId: 105,
      dosenId: 'dsn_002',
      nomorAntrean: 1,
      posisiSekarang: AppConstants.queueDone,
      waktuMasuk: DateTime.now().subtract(const Duration(days: 3)),
    ),
    QueueModel(
      antreanId: 6,
      dokumenId: 106,
      dosenId: 'dsn_003',
      nomorAntrean: 1,
      posisiSekarang: AppConstants.queueWaiting,
      waktuMasuk: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  // Initial Revisions
  static List<RevisionModel> initialRevisions = [
    RevisionModel(
      revisiId: 1,
      dokumenId: 104,
      dosenId: 'dsn_001',
      catatan: 'Nama pejabat instansi tujuan salah tulis, dan nomor surat permohonan dari fakultas harap dilampirkan.',
      halamanRevisi: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];
}

