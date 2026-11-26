import '../models/user_model.dart';
import '../models/document_model.dart';
import '../models/queue_model.dart';
import '../models/revision_model.dart';
import '../core/constants/app_constants.dart';

class MockData {
  // Master Pengguna Akademik
  static List<UserModel> initialUsers = [
    // Mahasiswa
    UserModel(
      userId: 'mhs_001',
      username: '20210801001',
      namaLengkap: 'Ahmad Fauzi',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      email: 'ahmad.fauzi@student.univ.ac.id',
      prodi: 'Teknik Informatika',
    ),
    UserModel(
      userId: 'mhs_002',
      username: '20210801015',
      namaLengkap: 'Siti Rahmawati',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      email: 'siti.rahma@student.univ.ac.id',
      prodi: 'Teknik Informatika',
    ),
    UserModel(
      userId: 'mhs_003',
      username: '20220802023',
      namaLengkap: 'Budi Santoso',
      role: AppConstants.roleMahasiswa,
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      email: 'budi.santoso@student.univ.ac.id',
      prodi: 'Sistem Informasi',
    ),
    UserModel(
      userId: 'mhs_004',
      username: '20220801042',
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

    // Admin Biro Akademik
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

  // Data Pengajuan Dokumen Awal (1-2 data realistis untuk demo antrean FIFO)
  static List<DocumentModel> initialDocuments = [
    DocumentModel(
      dokumenId: 101,
      mahasiswaId: 'mhs_001',
      dosenId: 'dsn_001',
      judulDokumen: 'Pengajuan Judul Skripsi: Sistem Informasi Pelayanan Terpadu Mahasiswa',
      kategori: 'Skripsi',
      filePath: 'dokumen/skripsi/Pengajuan_Skripsi_Ahmad_Fauzi.pdf',
      fileName: 'Pengajuan_Skripsi_Ahmad_Fauzi.pdf',
      fileSizeMb: 2.4,
      status:
          AppConstants.statusSedangDiperiksa, // Urutan 1: Sedang diproses Dosen
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    DocumentModel(
      dokumenId: 102,
      mahasiswaId: 'mhs_002',
      dosenId: 'dsn_001',
      judulDokumen:
          'Surat Pengantar Magang/PKL pada Dinas Komunikasi dan Informatika',
      kategori: 'Surat Pengantar',
      filePath: 'dokumen/surat/Surat_Pengantar_Magang_Siti_Rahmawati.pdf',
      fileName: 'Surat_Pengantar_Magang_Siti_Rahmawati.pdf',
      fileSizeMb: 1.2,
      status: AppConstants.statusMenunggu, // Urutan 2: Menunggu (Terkunci FIFO)
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  // Antrean FIFO Awal
  static List<QueueModel> initialQueues = [
    QueueModel(
      antreanId: 1,
      dokumenId: 101,
      dosenId: 'dsn_001',
      nomorAntrean: 1,
      posisiSekarang: AppConstants.queueProcessing,
      waktuMasuk: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    QueueModel(
      antreanId: 2,
      dokumenId: 102,
      dosenId: 'dsn_001',
      nomorAntrean: 2,
      posisiSekarang: AppConstants.queueWaiting,
      waktuMasuk: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  // Riwayat Catatan Revisi
  static List<RevisionModel> initialRevisions = [];
}
