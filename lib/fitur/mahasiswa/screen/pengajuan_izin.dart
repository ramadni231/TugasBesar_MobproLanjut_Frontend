import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class PengajuanIzin extends StatefulWidget {
  const PengajuanIzin({super.key});

  @override
  State<PengajuanIzin> createState() => _PengajuanIzinState();
}

class _PengajuanIzinState extends State<PengajuanIzin> {
  final _keteranganController = TextEditingController();
  final _tanggalController = TextEditingController();
  String? _jenisIzin = 'Sakit';
  DateTime? _selectedTanggal;
  String? _lampiranPath;
  String? _lampiranName;

  @override
  void dispose() {
    _keteranganController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final isDark = KontrolerTema().isDarkMode;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal ?? DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTanggal = picked;
        _tanggalController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pilihFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          if (!mounted) return;
          showFToast(
            context: context,
            title: const Text('Ukuran file bukti maksimal 10MB'),
            variant: FToastVariant.destructive,
          );
          return;
        }
        setState(() {
          _lampiranPath = file.path;
          _lampiranName = file.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: const Text('Gagal memilih file bukti'),
        variant: FToastVariant.destructive,
      );
    }
  }

  void _submit() async {
    if (_tanggalController.text.isEmpty) {
      showFToast(context: context, title: const Text('Tanggal tidak boleh kosong'));
      return;
    }
    if (_keteranganController.text.isEmpty) {
      showFToast(context: context, title: const Text('Keterangan tidak boleh kosong'));
      return;
    }
    if (_lampiranPath == null) {
      showFToast(context: context, title: const Text('Lampiran bukti/foto wajib diunggah'));
      return;
    }

    final controller = MahasiswaController();
    final tipe = _jenisIzin?.toLowerCase() == 'sakit' ? 'sakit' : 'izin';
    
    final success = await controller.ajukanIzin(
      tipeIzin: tipe,
      tanggal: _tanggalController.text,
      alasan: _keteranganController.text,
      lampiranPath: _lampiranPath!,
    );

    if (!mounted) return;
    if (success) {
      showFToast(
        context: context,
        title: const Text('Izin Berhasil Diajukan'),
      );
      Navigator.pop(context);
    } else {
      showFToast(
        context: context,
        title: const Text('Gagal mengirim pengajuan izin'),
        variant: FToastVariant.destructive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Pengajuan Izin',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FCard(
              title: const Text('Form Izin / Sakit'),
              subtitle: const Text('Silakan lengkapi alasan ketidakhadiran.'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FSelect<String>.rich(
                    label: const Text('Jenis Izin'),
                    hint: 'Pilih Jenis',
                    format: (value) => value,
                    control: FSelectControl.lifted(
                      value: _jenisIzin,
                      onChange: (v) => setState(() => _jenisIzin = v),
                    ),
                    children: [
                      .item(title: const Text('Sakit'), value: 'Sakit'),
                      .item(title: const Text('Izin'), value: 'Izin'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Tanggal Picker
                  const Text(
                    'Tanggal Ketidakhadiran',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pilihTanggal(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _tanggalController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Pilih Tanggal',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FTextField(
                    label: const Text('Keterangan'),
                    hint: 'Tuliskan detail alasan...',
                    maxLines: 3,
                    control: FTextFieldControl.managed(controller: _keteranganController),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lampiran Foto Bukti',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FTappable(
                    onPress: _pilihFile,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FIcons.image, color: Colors.grey),
                            const SizedBox(height: 4),
                            Text(
                              _lampiranName ?? 'Klik untuk Unggah Foto/Bukti',
                              style: TextStyle(
                                color: _lampiranName != null ? Colors.blue : Colors.grey,
                                fontWeight: _lampiranName != null ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FButton(
              onPress: _submit,
              child: const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }
}
