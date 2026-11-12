import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/document_model.dart';
import '../models/queue_model.dart';
import '../models/revision_model.dart';
import '../core/constants/app_constants.dart';
import 'mock_data.dart';

class SimadaRepository extends ChangeNotifier {
  static final SimadaRepository _instance = SimadaRepository._internal();
  factory SimadaRepository() => _instance;

  SimadaRepository._internal() {
    _users = List.from(MockData.initialUsers);
    _documents = List.from(MockData.initialDocuments);
    _queues = List.from(MockData.initialQueues);
    _revisions = List.from(MockData.initialRevisions);
    // Set default user to Mahasiswa Ahmad Fauzi
    _currentUser = _users.firstWhere((u) => u.userId == 'mhs_001');
    _addLog('Sistem SIMADA diinisialisasi. Mode live siap digunakan.');
  }

  late List<UserModel> _users;
  late List<DocumentModel> _documents;
  late List<QueueModel> _queues;
  late List<RevisionModel> _revisions;
  final List<String> _activityLogs = [];

  UserModel? _currentUser;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => List.unmodifiable(_users);
  List<DocumentModel> get documents => List.unmodifiable(_documents);
  List<QueueModel> get queues => List.unmodifiable(_queues);
  List<RevisionModel> get revisions => List.unmodifiable(_revisions);
  List<String> get activityLogs => List.unmodifiable(_activityLogs);

  List<UserModel> get dosenList => _users.where((u) => u.isDosen).toList();
  List<UserModel> get mahasiswaList => _users.where((u) => u.isMahasiswa).toList();

  // Switch current user (for rapid testing / role switching)
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    _addLog('Pengguna berganti ke: ${user.namaLengkap} (${user.roleDisplay})');
    notifyListeners();
  }

  // Helper log
  void _addLog(String message) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _activityLogs.insert(0, '[$timeStr] $message');
    if (_activityLogs.length > 100) {
      _activityLogs.removeLast();
    }
  }

  // User Lookup
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.userId == userId);
    } catch (_) {
      return null;
    }
  }

  // Document Lookup
  DocumentModel? getDocumentById(int docId) {
    try {
      return _documents.firstWhere((d) => d.dokumenId == docId);
    } catch (_) {
      return null;
    }
  }

  // Revisions for a Document
  List<RevisionModel> getRevisionsForDocument(int docId) {
    final list = _revisions.where((r) => r.dokumenId == docId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // ==========================================
  // FIFO QUEUE LOGIC FOR DOSEN & MAHASISWA
  // ==========================================

  /// Mengambil daftar antrean aktif dosen (Sedang Diperiksa & Menunggu)
  /// Terurut FIFO murni berdasarkan `created_at` ASC.
  List<DocumentModel> getActiveQueueForDosen(String dosenId) {
    final activeDocs = _documents.where((doc) {
      return doc.dosenId == dosenId &&
          (doc.status == AppConstants.statusSedangDiperiksa ||
              doc.status == AppConstants.statusMenunggu);
    }).toList();

    // FIFO: urutan pertama adalah yang paling awal diunggah
    activeDocs.sort((a, b) {
      // Jika salah satu sedang diperiksa, utamakan yang sedang diperiksa di puncak
      if (a.isSedangDiperiksa && !b.isSedangDiperiksa) return -1;
      if (!a.isSedangDiperiksa && b.isSedangDiperiksa) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    return activeDocs;
  }

  /// Dokumen yang sedang aktif diperiksa oleh dosen saat ini
  DocumentModel? getCurrentlyExaminingDoc(String dosenId) {
    try {
      return _documents.firstWhere(
        (doc) => doc.dosenId == dosenId && doc.status == AppConstants.statusSedangDiperiksa,
      );
    } catch (_) {
      return null;
    }
  }

  /// Mengambil antrean MENUNGGU paling awal berdasarkan FIFO (ORDER BY created_at ASC LIMIT 1)
  DocumentModel? getNextWaitingDocument(String dosenId) {
    final waitingList = _documents
        .where((doc) => doc.dosenId == dosenId && doc.status == AppConstants.statusMenunggu)
        .toList();

    if (waitingList.isEmpty) return null;

    waitingList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return waitingList.first;
  }

  /// Memeriksa apakah suatu dokumen di antrean aktif dosen dapat divalidasi.
  /// Berdasarkan prinsip FIFO:
  /// Dokumen urutan pertama (indeks 0 / antrean teratas yang berstatus "Menunggu" atau "Sedang Diperiksa")
  /// harus disetujui (status: Selesai / isSelesai) atau direvisi (status: Revisi / isRevisi) terlebih dahulu.
  /// Dokumen di urutan berikutnya (ke-2, ke-3, dst.) terkunci dan tidak bisa divalidasi.
  bool canValidateDocument(int dokumenId) {
    final doc = getDocumentById(dokumenId);
    if (doc == null) return false;

    // Dokumen yang sudah berstatus Selesai atau Revisi sudah selesai diproses dari antrean aktif
    if (doc.isSelesai || doc.isRevisi) return true;

    final activeQueue = getActiveQueueForDosen(doc.dosenId);
    if (activeQueue.isEmpty) return false;

    // Hanya dokumen indeks pertama (antrean teratas) yang dapat divalidasi
    return activeQueue.first.dokumenId == dokumenId;
  }

  /// Memeriksa apakah dokumen pada indeks tertentu terkunci dengan mengecek status dokumen pada indeks sebelumnya
  bool isQueueItemLocked(List<DocumentModel> queueList, int index) {
    if (index <= 0) return false;
    final prevDoc = queueList[index - 1];
    // Jika dokumen indeks sebelumnya belum disetujui (isSelesai) dan belum direvisi (isRevisi),
    // maka dokumen pada indeks ini terkunci
    return !prevDoc.isSelesai && !prevDoc.isRevisi;
  }

  /// Fitur Dosen: "Ambil Antrean Berikutnya" (Next Queue)
  /// Secara otomatis memproses mahasiswa urutan FIFO pertama yang berstatus 'Menunggu'
  /// Dilindungi aturan FIFO: tidak dapat memanggil antrean baru jika antrean aktif saat ini belum selesai.
  bool processNextQueue(String dosenId) {
    final currentlyExamining = getCurrentlyExaminingDoc(dosenId);
    if (currentlyExamining != null) {
      _addLog('FIFO Ditolak: Harap selesaikan Dokumen #${currentlyExamining.dokumenId} terlebih dahulu sebelum memanggil antrean berikutnya.');
      return false;
    }

    final nextDoc = getNextWaitingDocument(dosenId);
    if (nextDoc == null) return false;

    final mhs = getUserById(nextDoc.mahasiswaId);
    final dosen = getUserById(dosenId);

    // Update status dokumen menjadi 'Sedang Diperiksa'
    final docIndex = _documents.indexWhere((d) => d.dokumenId == nextDoc.dokumenId);
    if (docIndex != -1) {
      _documents[docIndex] = _documents[docIndex].copyWith(
        status: AppConstants.statusSedangDiperiksa,
        updatedAt: DateTime.now(),
      );
    }

    // Update queue status
    final qIndex = _queues.indexWhere((q) => q.dokumenId == nextDoc.dokumenId);
    if (qIndex != -1) {
      _queues[qIndex] = _queues[qIndex].copyWith(
        posisiSekarang: AppConstants.queueProcessing,
      );
    }

    _addLog('FIFO Call: ${dosen?.namaLengkap ?? "Dosen"} memanggil antrean #${nextDoc.dokumenId} milik ${mhs?.namaLengkap ?? "Mahasiswa"}.');
    notifyListeners();
    return true;
  }

  /// Fitur Dosen: Ubah Status Dokumen (Menunggu, Sedang Diperiksa, Revisi, Disetujui/Selesai)
  void updateDocumentStatus({
    required int dokumenId,
    required String newStatus,
    String? revisionNotes,
    int? revisionPage,
  }) {
    final docIndex = _documents.indexWhere((d) => d.dokumenId == dokumenId);
    if (docIndex == -1) return;

    final oldDoc = _documents[docIndex];

    // Validasi FIFO: Pastikan dokumen ini urutan pertama yang berhak divalidasi
    if (!canValidateDocument(dokumenId)) {
      final activeQueue = getActiveQueueForDosen(oldDoc.dosenId);
      final firstDoc = activeQueue.isNotEmpty ? activeQueue.first : null;
      _addLog('FIFO Ditolak: Dokumen #$dokumenId terkunci. Selesaikan dokumen urutan pertama (${firstDoc?.judulDokumen ?? "antrean teratas"}) terlebih dahulu.');
      return;
    }

    int newRevisionCount = oldDoc.revisionCount;

    if (newStatus == AppConstants.statusRevisi && revisionNotes != null && revisionNotes.trim().isNotEmpty) {
      newRevisionCount += 1;
      final newRev = RevisionModel(
        revisiId: DateTime.now().millisecondsSinceEpoch,
        dokumenId: dokumenId,
        dosenId: oldDoc.dosenId,
        catatan: revisionNotes.trim(),
        halamanRevisi: revisionPage,
        createdAt: DateTime.now(),
      );
      _revisions.insert(0, newRev);
    }

    _documents[docIndex] = oldDoc.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      revisionCount: newRevisionCount,
    );

    // Update antrean
    final qIndex = _queues.indexWhere((q) => q.dokumenId == dokumenId);
    if (qIndex != -1) {
      String newPosisi = _queues[qIndex].posisiSekarang;
      if (newStatus == AppConstants.statusSelesai) {
        newPosisi = AppConstants.queueDone;
      } else if (newStatus == AppConstants.statusSedangDiperiksa) {
        newPosisi = AppConstants.queueProcessing;
      } else if (newStatus == AppConstants.statusRevisi) {
        newPosisi = AppConstants.queueDone; // Menunggu mahasiswa mengunggah revisi
      } else if (newStatus == AppConstants.statusMenunggu) {
        newPosisi = AppConstants.queueWaiting;
      }
      _queues[qIndex] = _queues[qIndex].copyWith(posisiSekarang: newPosisi);
    }

    final mhs = getUserById(oldDoc.mahasiswaId);
    _addLog('Status Dokumen #$dokumenId ("${oldDoc.judulDokumen}") diperbarui menjadi "$newStatus" untuk ${mhs?.namaLengkap ?? "Mahasiswa"}.');
    notifyListeners();
  }

  /// Fitur Mahasiswa: Submit Dokumen Baru (FIFO Generator otomatis)
  DocumentModel submitNewDocument({
    required String mahasiswaId,
    required String dosenId,
    required String judulDokumen,
    required String kategori,
    required String fileName,
    String? filePath,
    double fileSizeMb = 1.5,
  }) {
    final now = DateTime.now();
    final newDocId = DateTime.now().millisecondsSinceEpoch % 100000;

    // Hitung nomor antrean berikutnya untuk dosen bersangkutan
    final existingQueuesForDosen = _queues.where((q) => q.dosenId == dosenId).toList();
    final nextQueueNumber = existingQueuesForDosen.length + 1;

    final newDoc = DocumentModel(
      dokumenId: newDocId,
      mahasiswaId: mahasiswaId,
      dosenId: dosenId,
      judulDokumen: judulDokumen,
      kategori: kategori,
      filePath: filePath ?? 'dokumen/${now.year}/$fileName',
      fileName: fileName,
      fileSizeMb: fileSizeMb,
      status: AppConstants.statusMenunggu,
      createdAt: now,
    );

    final newQueue = QueueModel(
      antreanId: DateTime.now().millisecondsSinceEpoch % 1000000,
      dokumenId: newDocId,
      dosenId: dosenId,
      nomorAntrean: nextQueueNumber,
      posisiSekarang: AppConstants.queueWaiting,
      waktuMasuk: now,
    );

    _documents.add(newDoc);
    _queues.add(newQueue);

    final mhs = getUserById(mahasiswaId);
    final dosen = getUserById(dosenId);
    _addLog('FIFO Berkas Baru: ${mhs?.namaLengkap} mengunggah "$judulDokumen" ke ${dosen?.namaLengkap} (Antrean #$nextQueueNumber).');

    notifyListeners();
    return newDoc;
  }

  /// Fitur Mahasiswa: Unggah Revisi
  void submitRevisionDocument({
    required int dokumenId,
    required String fileName,
    double fileSizeMb = 1.8,
  }) {
    final docIndex = _documents.indexWhere((d) => d.dokumenId == dokumenId);
    if (docIndex == -1) return;

    final oldDoc = _documents[docIndex];
    final now = DateTime.now();

    // Reset status ke 'Menunggu' dan perbarui timestamp created_at untuk urutan FIFO baru
    _documents[docIndex] = oldDoc.copyWith(
      fileName: fileName,
      filePath: 'dokumen/${now.year}/revisi_$fileName',
      fileSizeMb: fileSizeMb,
      status: AppConstants.statusMenunggu,
      createdAt: now, // Urutan antrean baru berdasarkan timestamp pengajuan revisi
      updatedAt: now,
    );

    // Update antrean
    final qIndex = _queues.indexWhere((q) => q.dokumenId == dokumenId);
    if (qIndex != -1) {
      _queues[qIndex] = _queues[qIndex].copyWith(
        posisiSekarang: AppConstants.queueWaiting,
        waktuMasuk: now,
      );
    }

    final mhs = getUserById(oldDoc.mahasiswaId);
    _addLog('Revisi Diunggah: ${mhs?.namaLengkap} mengunggah berkas revisi untuk Dokumen #$dokumenId.');
    notifyListeners();
  }

  // ==========================================
  // LIVE STATUS MONITORING UNTUK MAHASISWA
  // ==========================================
  Map<String, dynamic>? getLiveQueueStatusForMahasiswa(String mahasiswaId) {
    // Cari dokumen aktif mahasiswa (sedang diperiksa atau menunggu)
    final activeDocs = _documents.where((d) {
      return d.mahasiswaId == mahasiswaId &&
          (d.status == AppConstants.statusMenunggu || d.status == AppConstants.statusSedangDiperiksa);
    }).toList();

    if (activeDocs.isEmpty) return null;

    // Ambil dokumen aktif yang paling relevan
    activeDocs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final currentDoc = activeDocs.first;
    final dosen = getUserById(currentDoc.dosenId);

    // Ambil seluruh antrean aktif dosen ini (FIFO urut created_at ASC)
    final allActiveForDosen = getActiveQueueForDosen(currentDoc.dosenId);
    final totalWaitingAndProcessing = allActiveForDosen.length;

    // Hitung posisi urutan dokumen ini
    int currentPosition = 1;
    for (int i = 0; i < allActiveForDosen.length; i++) {
      if (allActiveForDosen[i].dokumenId == currentDoc.dokumenId) {
        currentPosition = i + 1;
        break;
      }
    }

    final isBeingProcessedNow = currentDoc.status == AppConstants.statusSedangDiperiksa;
    final estimatedMinutesWait = isBeingProcessedNow ? 5 : (currentPosition * 12);

    return {
      'document': currentDoc,
      'dosen': dosen,
      'currentPosition': currentPosition,
      'totalQueue': totalWaitingAndProcessing,
      'isBeingProcessedNow': isBeingProcessedNow,
      'estimatedMinutesWait': estimatedMinutesWait,
    };
  }

  // Riwayat Pengajuan Mahasiswa
  List<DocumentModel> getDocumentsByMahasiswa(String mahasiswaId) {
    final list = _documents.where((d) => d.mahasiswaId == mahasiswaId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Riwayat Dokumen Dosen yang Selesai / Riwayat Validasi
  List<DocumentModel> getValidationHistoryForDosen(String dosenId) {
    final list = _documents.where((d) {
      return d.dosenId == dosenId &&
          (d.status == AppConstants.statusSelesai || d.status == AppConstants.statusRevisi);
    }).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // ==========================================
  // FITUR ADMINISTRATOR: BOTTLENECK & USER MGMT
  // ==========================================

  /// Mendeteksi bottleneck antrean di setiap dosen
  List<Map<String, dynamic>> getDosenBottleneckSummary() {
    final List<Map<String, dynamic>> summary = [];

    for (var dosen in dosenList) {
      final docs = _documents.where((d) => d.dosenId == dosen.userId).toList();
      final waitingCount = docs.where((d) => d.status == AppConstants.statusMenunggu).length;
      final processingCount = docs.where((d) => d.status == AppConstants.statusSedangDiperiksa).length;
      final finishedCount = docs.where((d) => d.status == AppConstants.statusSelesai).length;
      final revisionCount = docs.where((d) => d.status == AppConstants.statusRevisi).length;

      final totalActive = waitingCount + processingCount;
      final isBottleneck = totalActive >= 3; // jika antrean menumpuk >= 3 berkas

      summary.add({
        'dosen': dosen,
        'waitingCount': waitingCount,
        'processingCount': processingCount,
        'finishedCount': finishedCount,
        'revisionCount': revisionCount,
        'totalActive': totalActive,
        'isBottleneck': isBottleneck,
      });
    }

    // Urutkan dari antrean paling padat (potensi bottleneck tertinggi)
    summary.sort((a, b) => (b['totalActive'] as int).compareTo(a['totalActive'] as int));
    return summary;
  }

  // Tambah User baru (Fitur Admin)
  void addUser(UserModel user) {
    _users.add(user);
    _addLog('Admin menambahkan pengguna baru: ${user.namaLengkap} (${user.roleDisplay}).');
    notifyListeners();
  }

  // Hapus User (Fitur Admin)
  void deleteUser(String userId) {
    _users.removeWhere((u) => u.userId == userId);
    _addLog('Admin menghapus pengguna ID: $userId.');
    notifyListeners();
  }
}

