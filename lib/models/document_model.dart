class DocumentModel {
  final int dokumenId;
  final String mahasiswaId;
  final String dosenId;
  final String judulDokumen;
  final String kategori; // Proposal, Skripsi, Surat Pengantar, dll
  final String filePath;
  final String fileName;
  final double fileSizeMb;
  final String status; // 'Menunggu', 'Sedang Diperiksa', 'Revisi', 'Selesai'
  final DateTime createdAt; // Kunci utama algoritma FIFO
  final DateTime updatedAt;
  final int revisionCount;

  DocumentModel({
    required this.dokumenId,
    required this.mahasiswaId,
    required this.dosenId,
    required this.judulDokumen,
    required this.kategori,
    required this.filePath,
    required this.fileName,
    this.fileSizeMb = 1.8,
    required this.status,
    required this.createdAt,
    DateTime? updatedAt,
    this.revisionCount = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get isMenunggu => status == 'Menunggu';
  bool get isSedangDiperiksa => status == 'Sedang Diperiksa';
  bool get isRevisi => status == 'Revisi';
  bool get isSelesai => status == 'Selesai';

  DocumentModel copyWith({
    int? dokumenId,
    String? mahasiswaId,
    String? dosenId,
    String? judulDokumen,
    String? kategori,
    String? filePath,
    String? fileName,
    double? fileSizeMb,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? revisionCount,
  }) {
    return DocumentModel(
      dokumenId: dokumenId ?? this.dokumenId,
      mahasiswaId: mahasiswaId ?? this.mahasiswaId,
      dosenId: dosenId ?? this.dosenId,
      judulDokumen: judulDokumen ?? this.judulDokumen,
      kategori: kategori ?? this.kategori,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSizeMb: fileSizeMb ?? this.fileSizeMb,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revisionCount: revisionCount ?? this.revisionCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dokumen_id': dokumenId,
      'mahasiswa_id': mahasiswaId,
      'dosen_id': dosenId,
      'judul_dokumen': judulDokumen,
      'kategori': kategori,
      'file_path': filePath,
      'file_name': fileName,
      'file_size_mb': fileSizeMb,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'revision_count': revisionCount,
    };
  }
}

