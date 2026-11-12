class AppConstants {
  static const String appName = 'SIMADA';
  static const String appFullName = 'Sistem Manajemen Dokumen & Antrean Akademik';
  static const String appTagline = 'Birokrasi Akademik Transparan & Tertib Antrean (FIFO)';

  // Roles
  static const String roleMahasiswa = 'mahasiswa';
  static const String roleDosen = 'dosen';
  static const String roleAdmin = 'admin';

  // Dokumen Categories
  static const List<String> kategoriDokumen = [
    'Proposal',
    'Skripsi',
    'Surat Pengantar',
    'Laporan Magang / PKL',
    'Borang Validasi',
  ];

  // Dokumen Statuses
  static const String statusMenunggu = 'Menunggu';
  static const String statusSedangDiperiksa = 'Sedang Diperiksa';
  static const String statusRevisi = 'Revisi';
  static const String statusSelesai = 'Selesai';

  // Antrean Posisi
  static const String queueWaiting = 'Waiting';
  static const String queueProcessing = 'Processing';
  static const String queueDone = 'Done';
}

