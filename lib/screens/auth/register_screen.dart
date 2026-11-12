import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../mahasiswa/mahasiswa_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedProdi = 'Teknik Informatika';
  bool _isLoading = false;

  final List<String> _prodiList = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
    'Sains Data',
    'Teknologi Informasi',
  ];

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      final user = _authService.registerMahasiswa(
        nim: _nimController.text,
        namaLengkap: _namaController.text,
        prodi: _selectedProdi,
        email: _emailController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, ${user.namaLengkap}! Akun berhasil dibuat.'),
            backgroundColor: AppColors.statusSelesai,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MahasiswaHomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrasi Akun Mahasiswa'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pendaftaran Akun Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gunakan NIM aktif yang terdaftar di pangkalan data akademik.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // NIM
                      TextFormField(
                        controller: _nimController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Induk Mahasiswa (NIM)',
                          hintText: 'Contoh: 2021005',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'NIM wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Nama Lengkap
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Mahasiswa',
                          hintText: 'Masukkan nama sesuai KTM',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Program Studi Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedProdi,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: _prodiList.map((prodi) {
                          return DropdownMenuItem(
                            value: prodi,
                            child: Text(prodi),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedProdi = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Kampus / Pribadi',
                          hintText: 'mahasiswa@student.univ.ac.id',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (val) {
                          if (val == null || !val.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Akun',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      CustomButton(
                        text: 'Daftar & Masuk',
                        icon: Icons.check_circle_outline,
                        isLoading: _isLoading,
                        onPressed: _register,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

