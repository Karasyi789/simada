class UserModel {
  final String userId;
  final String username; // NIM untuk mahasiswa, NIP untuk dosen, username untuk admin
  final String namaLengkap;
  final String role; // 'mahasiswa', 'dosen', 'admin'
  final DateTime createdAt;
  final String? email;
  final String? prodi;

  UserModel({
    required this.userId,
    required this.username,
    required this.namaLengkap,
    required this.role,
    required this.createdAt,
    this.email,
    this.prodi,
  });

  bool get isMahasiswa => role.toLowerCase() == 'mahasiswa';
  bool get isDosen => role.toLowerCase() == 'dosen';
  bool get isAdmin => role.toLowerCase() == 'admin';

  String get roleDisplay {
    switch (role.toLowerCase()) {
      case 'mahasiswa':
        return 'Mahasiswa';
      case 'dosen':
        return 'Dosen Pembimbing / Penguji';
      case 'admin':
        return 'Administrator Prodi';
      default:
        return role;
    }
  }

  String get idLabel {
    if (isMahasiswa) return 'NIM';
    if (isDosen) return 'NIP';
    return 'Username';
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'nama_lengkap': namaLengkap,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'email': email,
      'prodi': prodi,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      username: map['username'] ?? '',
      namaLengkap: map['nama_lengkap'] ?? '',
      role: map['role'] ?? 'mahasiswa',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      email: map['email'],
      prodi: map['prodi'],
    );
  }

  UserModel copyWith({
    String? userId,
    String? username,
    String? namaLengkap,
    String? role,
    DateTime? createdAt,
    String? email,
    String? prodi,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      prodi: prodi ?? this.prodi,
    );
  }
}

