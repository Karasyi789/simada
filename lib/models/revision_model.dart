class RevisionModel {
  final int revisiId;
  final int dokumenId;
  final String dosenId;
  final String catatan;
  final int? halamanRevisi; // opsional nomor halaman catatan
  final DateTime createdAt;

  RevisionModel({
    required this.revisiId,
    required this.dokumenId,
    required this.dosenId,
    required this.catatan,
    this.halamanRevisi,
    required this.createdAt,
  });

  RevisionModel copyWith({
    int? revisiId,
    int? dokumenId,
    String? dosenId,
    String? catatan,
    int? halamanRevisi,
    DateTime? createdAt,
  }) {
    return RevisionModel(
      revisiId: revisiId ?? this.revisiId,
      dokumenId: dokumenId ?? this.dokumenId,
      dosenId: dosenId ?? this.dosenId,
      catatan: catatan ?? this.catatan,
      halamanRevisi: halamanRevisi ?? this.halamanRevisi,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'revisi_id': revisiId,
      'dokumen_id': dokumenId,
      'dosen_id': dosenId,
      'catatan': catatan,
      'halaman_revisi': halamanRevisi,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

