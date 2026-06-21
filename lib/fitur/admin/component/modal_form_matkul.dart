import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/model/matakuliah_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class ModalFormMatkul extends StatefulWidget {
  final Matakuliah? matkul; // if null, then it's for 'Tambah'
  final Function(Map<String, dynamic>) onSubmit;

  const ModalFormMatkul({super.key, this.matkul, required this.onSubmit});

  @override
  State<ModalFormMatkul> createState() => _ModalFormMatkulState();
}

class _ModalFormMatkulState extends State<ModalFormMatkul> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _sksController = TextEditingController();
  final _semesterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.matkul != null) {
      _kodeController.text = widget.matkul!.kodeMatkul;
      _namaController.text = widget.matkul!.namaMatkul;
      _sksController.text = widget.matkul!.sks.toString();
      _semesterController.text = widget.matkul!.semester.toString();
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _sksController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_kodeController.text.isEmpty || _namaController.text.isEmpty) {
      showFToast(context: context, title: const Text('Kode dan Nama tidak boleh kosong'));
      return;
    }
    final data = {
      'kode_matkul': _kodeController.text,
      'nama_matkul': _namaController.text,
      'sks': int.tryParse(_sksController.text) ?? 3,
      'semester': int.tryParse(_semesterController.text) ?? 1,
    };
    widget.onSubmit(data);
    Navigator.pop(context);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hint,
    required bool isDarkMode,
  }) {
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
                  widget.matkul == null ? 'Tambah Matakuliah' : 'Ubah Matakuliah',
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
              label: 'Kode Matakuliah',
              controller: _kodeController,
              hint: 'Misal: IF201',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Nama Matakuliah',
              controller: _namaController,
              hint: 'Misal: Pemrograman Mobile',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'SKS',
              controller: _sksController,
              keyboardType: TextInputType.number,
              hint: 'Misal: 3',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: 'Semester',
              controller: _semesterController,
              keyboardType: TextInputType.number,
              hint: 'Misal: 4',
              isDarkMode: isDarkMode,
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
