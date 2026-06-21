import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/admin/model/matakuliah_model.dart';
import 'package:tugas_besar/fitur/admin/model/ruangan_model.dart';
import 'package:tugas_besar/fitur/otentikasi/model/pengguna_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class ModalFormJadwal extends StatefulWidget {
  final Jadwal? jadwal; // if null, then it's for 'Tambah'
  final Function(Map<String, dynamic>) onSubmit;

  const ModalFormJadwal({super.key, this.jadwal, required this.onSubmit});

  @override
  State<ModalFormJadwal> createState() => _ModalFormJadwalState();
}

class _ModalFormJadwalState extends State<ModalFormJadwal> {
  final _controller = AdminController();
  final _jamMulaiController = TextEditingController();
  final _jamSelesaiController = TextEditingController();
  final _tanggalController = TextEditingController();

  List<Matakuliah> _matkulList = [];
  List<Ruangan> _ruanganList = [];
  List<Pengguna> _dosenList = [];
  bool _loadingData = true;

  int? _selectedMatkulId;
  int? _selectedRuanganId;
  int? _selectedDosenId;
  String? _selectedHari;
  String? _selectedMetode;

  // New variables for reschedule
  String _tipe = 'selamanya';
  int _selectedPertemuan = 1;
  DateTime? _selectedTanggal;
  int? _selectedRuanganIdReschedule;

  @override
  void initState() {
    super.initState();
    _jamMulaiController.text = widget.jadwal?.jamMulai ?? '08:00:00';
    _jamSelesaiController.text = widget.jadwal?.jamSelesai ?? '10:30:00';
    _selectedHari = widget.jadwal?.hari ?? 'Senin';
    _selectedMetode = widget.jadwal?.metode ?? 'luring';
    _selectedMatkulId = widget.jadwal?.matakuliah.id;
    _selectedRuanganId = widget.jadwal?.ruangan.id;
    _selectedDosenId = widget.jadwal?.dosen.id;
    _selectedRuanganIdReschedule = widget.jadwal?.ruangan.id;
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final matkuls = await _controller.fetchMatakuliah();
      final rooms = await _controller.fetchRuangan();
      final dosens = await _controller.fetchPengguna(peran: 'dosen');
      if (mounted) {
        setState(() {
          _matkulList = matkuls;
          _ruanganList = rooms;
          _dosenList = dosens;
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  String dapatkanLabelPertemuan(int p) {
    if (p >= 1 && p <= 7) {
      return "Pertemuan $p";
    } else if (p == 8) {
      return "UTS";
    } else if (p >= 9 && p <= 15) {
      return "Pertemuan ${p - 1}";
    } else if (p == 16) {
      return "UAS";
    }
    return "Pertemuan $p";
  }

  void _submit() {
    if (_tipe == 'satu_pertemuan') {
      if (_tanggalController.text.isEmpty) {
        showFToast(context: context, title: const Text('Tanggal Reschedule harus dipilih'));
        return;
      }
      final jamMulai = _jamMulaiController.text.contains(':') && _jamMulaiController.text.split(':').length == 2
          ? '${_jamMulaiController.text}:00'
          : _jamMulaiController.text;
      final jamSelesai = _jamSelesaiController.text.contains(':') && _jamSelesaiController.text.split(':').length == 2
          ? '${_jamSelesaiController.text}:00'
          : _jamSelesaiController.text;

      final data = {
        'tipe': 'satu_pertemuan',
        'pertemuan_ke': _selectedPertemuan,
        'tanggal_reschedule': _tanggalController.text,
        'jam_mulai_reschedule': jamMulai,
        'jam_selesai_reschedule': jamSelesai,
        'ruangan_id_reschedule': _selectedRuanganIdReschedule,
      };
      widget.onSubmit(data);
      Navigator.pop(context);
      return;
    }

    if (_selectedMatkulId == null || _selectedRuanganId == null || _selectedDosenId == null || _selectedHari == null) {
      showFToast(
        context: context,
        title: const Text('Silakan lengkapi semua pilihan'),
      );
      return;
    }
    final data = {
      'tipe': 'selamanya',
      'matakuliah_id': _selectedMatkulId,
      'ruangan_id': _selectedRuanganId,
      'dosen_id': _selectedDosenId,
      'hari': _selectedHari,
      'jam_mulai': _jamMulaiController.text,
      'jam_selesai': _jamSelesaiController.text,
      'metode': _selectedMetode,
    };
    widget.onSubmit(data);
    Navigator.pop(context);
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

  Future<void> _pilihJam(BuildContext context, TextEditingController controller) async {
    final timeParts = controller.text.split(':');
    final initialHour = timeParts.isNotEmpty ? (int.tryParse(timeParts[0]) ?? 8) : 8;
    final initialMinute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
    final isDark = KontrolerTema().isDarkMode;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
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
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$minute:00';
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
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
        GestureDetector(
          onTap: () => _pilihJam(context, controller),
          child: AbsorbPointer(
            child: TextField(
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
                suffixIcon: Icon(Icons.access_time, color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
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
        child: _loadingData
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.jadwal == null ? 'Tambah Jadwal' : 'Ubah Jadwal',
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

                  if (widget.jadwal != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Satu Pertemuan')),
                            selected: _tipe == 'satu_pertemuan',
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: _tipe == 'satu_pertemuan' ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _tipe = 'satu_pertemuan');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Selamanya')),
                            selected: _tipe == 'selamanya',
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: _tipe == 'selamanya' ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _tipe = 'selamanya');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_tipe == 'satu_pertemuan') ...[
                    // Dropdown Pertemuan Ke
                    Text(
                      'Pilih Sesi Pertemuan',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedPertemuan,
                      dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
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
                      items: List.generate(16, (i) => i + 1)
                          .map((p) => DropdownMenuItem<int>(
                                value: p,
                                child: Text(dapatkanLabelPertemuan(p)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPertemuan = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Datepicker Tanggal Reschedule
                    Text(
                      'Tanggal Reschedule',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
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
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Pilih Tanggal',
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
                            suffixIcon: Icon(Icons.calendar_today, color: isDarkMode ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ruangan Reschedule
                    FSelect<int>.rich(
                      label: Text('Ruangan Reschedule', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      hint: 'Pilih Ruangan',
                      format: (v) {
                        final found = _ruanganList.where((r) => r.id == v);
                        if (found.isEmpty) return 'Pilih Ruangan';
                        return found.first.namaRuangan;
                      },
                      control: FSelectControl.lifted(
                        value: _selectedRuanganIdReschedule,
                        onChange: (v) => setState(() => _selectedRuanganIdReschedule = v),
                      ),
                      children: [
                        for (final r in _ruanganList)
                          .item(
                            title: Text(r.namaRuangan),
                            value: r.id,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Jam Mulai Reschedule
                    _buildField(
                      label: 'Jam Mulai Reschedule',
                      controller: _jamMulaiController,
                      hint: 'HH:MM:SS',
                    ),
                    const SizedBox(height: 16),

                    // Jam Selesai Reschedule
                    _buildField(
                      label: 'Jam Selesai Reschedule',
                      controller: _jamSelesaiController,
                      hint: 'HH:MM:SS',
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Mata Kuliah Select
                    FSelect<int>.rich(
                      label: Text('Mata Kuliah', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      hint: 'Pilih Mata Kuliah',
                      format: (v) {
                        final found = _matkulList.where((m) => m.id == v);
                        if (found.isEmpty) return 'Pilih Mata Kuliah';
                        final item = found.first;
                        return '${item.kodeMatkul} - ${item.namaMatkul}';
                      },
                      control: FSelectControl.lifted(
                        value: _selectedMatkulId,
                        onChange: (v) => setState(() => _selectedMatkulId = v),
                      ),
                      children: [
                        for (final m in _matkulList)
                          .item(
                            title: Text('${m.kodeMatkul} - ${m.namaMatkul}'),
                            value: m.id,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Ruangan Select
                    FSelect<int>.rich(
                      label: Text('Ruangan', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      hint: 'Pilih Ruangan',
                      format: (v) {
                        final found = _ruanganList.where((r) => r.id == v);
                        if (found.isEmpty) return 'Pilih Ruangan';
                        return found.first.namaRuangan;
                      },
                      control: FSelectControl.lifted(
                        value: _selectedRuanganId,
                        onChange: (v) => setState(() => _selectedRuanganId = v),
                      ),
                      children: [
                        for (final r in _ruanganList)
                          .item(
                            title: Text(r.namaRuangan),
                            value: r.id,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dosen Select
                    FSelect<int>.rich(
                      label: Text('Dosen Pengampu', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      hint: 'Pilih Dosen',
                      format: (v) {
                        final found = _dosenList.where((d) => d.id == v);
                        if (found.isEmpty) return 'Pilih Dosen';
                        return found.first.nama;
                      },
                      control: FSelectControl.lifted(
                        value: _selectedDosenId,
                        onChange: (v) => setState(() => _selectedDosenId = v),
                      ),
                      children: [
                        for (final d in _dosenList)
                          .item(
                            title: Text(d.nama),
                            value: d.id,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Metode Select
                    FSelect<String>.rich(
                      label: Text('Metode Kelas', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      hint: 'Pilih Metode',
                      format: (v) => v.toUpperCase(),
                      control: FSelectControl.lifted(
                        value: _selectedMetode,
                        onChange: (v) => setState(() => _selectedMetode = v),
                      ),
                      children: [
                        .item(title: const Text('Luring (Offline)'), value: 'luring'),
                        .item(title: const Text('Daring (Online)'), value: 'daring'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hari Select
                    FSelect<String>.rich(
                      label: Text('Hari', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      hint: 'Pilih Hari',
                      format: (v) => v,
                      control: FSelectControl.lifted(
                        value: _selectedHari,
                        onChange: (v) => setState(() => _selectedHari = v),
                      ),
                      children: [
                        .item(title: const Text('Senin'), value: 'Senin'),
                        .item(title: const Text('Selasa'), value: 'Selasa'),
                        .item(title: const Text('Rabu'), value: 'Rabu'),
                        .item(title: const Text('Kamis'), value: 'Kamis'),
                        .item(title: const Text('Jumat'), value: 'Jumat'),
                        .item(title: const Text('Sabtu'), value: 'Sabtu'),
                        .item(title: const Text('Minggu'), value: 'Minggu'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Jam Mulai
                    _buildField(
                      label: 'Jam Mulai',
                      controller: _jamMulaiController,
                      hint: 'HH:MM:SS',
                    ),
                    const SizedBox(height: 16),

                    // Jam Selesai
                    _buildField(
                      label: 'Jam Selesai',
                      controller: _jamSelesaiController,
                      hint: 'HH:MM:SS',
                    ),
                    const SizedBox(height: 24),
                  ],

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
