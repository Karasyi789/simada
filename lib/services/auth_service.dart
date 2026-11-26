import '../models/user_model.dart';
import 'simada_repository.dart';

class AuthService {
  final SimadaRepository _repo = SimadaRepository();

  UserModel? get currentUser => _repo.currentUser;

  /// Login dengan NIM/NIP/Email/Username dan Password
  UserModel? login(String usernameOrId, String password) {
    final cleanInput = usernameOrId.trim().toLowerCase();
    
    // Cari user berdasarkan username, nim, nip, email, atau id
    final user = _repo.users.cast<UserModel?>().firstWhere(
      (u) =>
          u?.username.toLowerCase() == cleanInput ||
          u?.userId.toLowerCase() == cleanInput ||
          (u?.email?.toLowerCase() == cleanInput),
      orElse: () => null,
    );

    if (user != null) {
      _repo.setCurrentUser(user);
      return user;
    }
    return null;
  }

  /// Register mahasiswa baru
  UserModel registerMahasiswa({
    required String nim,
    required String namaLengkap,
    required String prodi,
    required String email,
  }) {
    final newUser = UserModel(
      userId: 'mhs_${DateTime.now().millisecondsSinceEpoch % 10000}',
      username: nim.trim(),
      namaLengkap: namaLengkap.trim(),
      role: 'mahasiswa',
      createdAt: DateTime.now(),
      email: email.trim(),
      prodi: prodi.trim(),
    );

    _repo.addUser(newUser);
    _repo.setCurrentUser(newUser);
    return newUser;
  }

  void logout() {
    // Default kembali ke user pertama atau null
    if (_repo.users.isNotEmpty) {
      _repo.setCurrentUser(_repo.users.first);
    }
  }
}

