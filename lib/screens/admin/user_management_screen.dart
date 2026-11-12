import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/simada_repository.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final SimadaRepository _repo = SimadaRepository();
  String _selectedRoleFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    super.dispose();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = AppConstants.roleMahasiswa;
    String selectedProdi = 'Teknik Informatika';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Tambah Pengguna Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Peran (Role)',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.roleMahasiswa,
                        child: Text('Mahasiswa'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.roleDosen,
                        child: Text('Dosen'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.roleAdmin,
                        child: Text('Administrator'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: selectedRole == AppConstants.roleMahasiswa
                          ? 'NIM Mahasiswa'
                          : (selectedRole == AppConstants.roleDosen
                                ? 'NIP Dosen'
                                : 'Username Admin'),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Email tidak valid'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newUser = UserModel(
                    userId:
                        '${selectedRole}_${DateTime.now().millisecondsSinceEpoch % 10000}',
                    username: idController.text.trim(),
                    namaLengkap: nameController.text.trim(),
                    role: selectedRole,
                    createdAt: DateTime.now(),
                    email: emailController.text.trim(),
                    prodi: selectedProdi,
                  );
                  _repo.addUser(newUser);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pengguna ${newUser.namaLengkap} berhasil ditambahkan!',
                      ),
                      backgroundColor: AppColors.statusSelesai,
                    ),
                  );
                }
              },
              child: const Text('Simpan Pengguna'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun ${user.namaLengkap} (${user.username})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRevisi,
            ),
            onPressed: () {
              _repo.deleteUser(user.userId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Akun ${user.namaLengkap} telah dihapus.'),
                  backgroundColor: AppColors.statusRevisi,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = _repo.users;
    final filteredUsers = allUsers.where((u) {
      if (_selectedRoleFilter != 'Semua' &&
          u.role.toLowerCase() != _selectedRoleFilter.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = u.namaLengkap.toLowerCase().contains(q);
        final idMatch = u.username.toLowerCase().contains(q);
        return nameMatch || idMatch;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Pengguna'),
        onPressed: _showAddUserDialog,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama, NIM, atau NIP...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),

            // Role filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Mahasiswa', 'Dosen', 'Admin'].map((role) {
                  final isSelected = _selectedRoleFilter == role;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(role),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      showCheckmark: false,
                      onSelected: (val) {
                        setState(() => _selectedRoleFilter = role);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // User List
            Expanded(
              child: ListView.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  Color roleColor = AppColors.primary;
                  if (user.isDosen) roleColor = AppColors.secondary;
                  if (user.isAdmin) roleColor = AppColors.statusMenunggu;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: roleColor.withOpacity(0.12),
                          child: Icon(
                            user.isMahasiswa
                                ? Icons.person
                                : (user.isDosen
                                      ? Icons.school
                                      : Icons.admin_panel_settings),
                            color: roleColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.namaLengkap,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${user.idLabel}: ${user.username} • ${user.roleDisplay}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (user.email != null)
                                Text(
                                  user.email!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Quick switch or delete
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (val) {
                            if (val == 'switch') {
                              _repo.setCurrentUser(user);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Beralih login sebagai ${user.namaLengkap}',
                                  ),
                                  backgroundColor: AppColors.statusProses,
                                ),
                              );
                            } else if (val == 'delete') {
                              _confirmDeleteUser(user);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'switch',
                              child: Row(
                                children: [
                                  Icon(Icons.login, size: 16),
                                  SizedBox(width: 8),
                                  Text('Masuk Sebagai Akun Ini'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus Akun',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
