import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class ModalFormPengguna extends StatefulWidget {
  final Pengguna? pengguna; // if null, then it's for 'Tambah'
  final Function(Map<String, dynamic>) onSubmit;

  const ModalFormPengguna({super.key, this.pengguna, required this.onSubmit});

  @override
  State<ModalFormPengguna> createState() => _ModalFormPenggunaState();
}

class _ModalFormPenggunaState extends State<ModalFormPengguna> {
  final _namaController = TextEditingController();
  final _identitasController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedPeran;

  @override
  void initState() {
    super.initState();
    if (widget.pengguna != null) {
      _namaController.text = widget.pengguna!.nama;
      _identitasController.text = widget.pengguna!.nomorIdentitas;
      _emailController.text = widget.pengguna!.email;
      _selectedPeran = widget.pengguna!.peran;
    } else {
      _selectedPeran = 'mahasiswa';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _identitasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_namaController.text.isEmpty ||
        _identitasController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedPeran == null) {
      showFToast(
        context: context,
        title: const Text('Silakan lengkapi semua pilihan wajib'),
      );
      return;
    }

    if (widget.pengguna == null && _passwordController.text.isEmpty) {
      showFToast(
        context: context,
        title: const Text('Kata Sandi wajib diisi untuk pengguna baru'),
      );
      return;
    }

    final data = {
      'nama': _namaController.text,
      'nomor_identitas': _identitasController.text,
      'email': _emailController.text,
      'peran': _selectedPeran,
      if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
    };

    widget.onSubmit(data);
    Navigator.pop(context);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hint,
  }) {
    final isDarkMode = KontrolerTema().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = KontrolerTema().isDarkMode;
    final modalBgColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: modalBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.pengguna == null ? 'Tambah Pengguna' : 'Ubah Pengguna',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildField(
              label: 'Nama Lengkap',
              controller: _namaController,
              hint: 'Nama lengkap pengguna',
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'NIM / NIP / Nomor Identitas',
              controller: _identitasController,
              hint: 'NIM untuk mahasiswa, NIP untuk dosen',
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hint: 'nama@domain.com',
            ),
            const SizedBox(height: 16),
            _buildField(
              label: widget.pengguna == null ? 'Kata Sandi' : 'Kata Sandi (Kosongkan jika tidak diubah)',
              controller: _passwordController,
              obscureText: true,
              hint: 'Minimal 6 karakter',
            ),
            const SizedBox(height: 16),
            FSelect<String>.rich(
              label: Text('Peran Pengguna', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
              hint: 'Pilih Peran',
              format: (v) => v[0].toUpperCase() + v.substring(1),
              control: FSelectControl.lifted(
                value: _selectedPeran,
                onChange: (v) => setState(() => _selectedPeran = v),
              ),
              children: [
                .item(title: const Text('Mahasiswa'), value: 'mahasiswa'),
                .item(title: const Text('Dosen'), value: 'dosen'),
                .item(title: const Text('Admin'), value: 'admin'),
              ],
            ),
            const SizedBox(height: 24),
            FButton(
              onPress: _submit,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
