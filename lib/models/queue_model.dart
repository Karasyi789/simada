class QueueModel {
  final int antreanId;
  final int dokumenId;
  final String dosenId;
  final int nomorAntrean;
  final String posisiSekarang; // 'Waiting', 'Processing', 'Done'
  final DateTime waktuMasuk;

  QueueModel({
    required this.antreanId,
    required this.dokumenId,
    required this.dosenId,
    required this.nomorAntrean,
    required this.posisiSekarang,
    required this.waktuMasuk,
  });

  bool get isWaiting => posisiSekarang == 'Waiting';
  bool get isProcessing => posisiSekarang == 'Processing';
  bool get isDone => posisiSekarang == 'Done';

  QueueModel copyWith({
    int? antreanId,
    int? dokumenId,
    String? dosenId,
    int? nomorAntrean,
    String? posisiSekarang,
    DateTime? waktuMasuk,
  }) {
    return QueueModel(
      antreanId: antreanId ?? this.antreanId,
      dokumenId: dokumenId ?? this.dokumenId,
      dosenId: dosenId ?? this.dosenId,
      nomorAntrean: nomorAntrean ?? this.nomorAntrean,
      posisiSekarang: posisiSekarang ?? this.posisiSekarang,
      waktuMasuk: waktuMasuk ?? this.waktuMasuk,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'antrean_id': antreanId,
      'dokumen_id': dokumenId,
      'dosen_id': dosenId,
      'nomor_antrean': nomorAntrean,
      'posisi_sekarang': posisiSekarang,
      'waktu_masuk': waktuMasuk.toIso8601String(),
    };
  }
}

