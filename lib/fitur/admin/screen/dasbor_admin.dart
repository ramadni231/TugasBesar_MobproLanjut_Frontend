import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/component/kartu_statistik.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_ruangan.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_matkul.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_jadwal.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_pengguna.dart';
import 'package:tugas_besar/umum/component/modal_profil_slider.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class DasborAdmin extends StatefulWidget {
  const DasborAdmin({super.key});

  @override
  State<DasborAdmin> createState() => _DasborAdminState();
}

class _DasborAdminState extends State<DasborAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeAdmin(),
    const ManajemenRuangan(),
    const ManajemenMatkul(),
    const ManajemenJadwal(),
    const ManajemenPengguna(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(FIcons.mapPin), label: 'Ruang'),
          BottomNavigationBarItem(icon: Icon(FIcons.bookOpen), label: 'Matkul'),
          BottomNavigationBarItem(icon: Icon(FIcons.clock), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(FIcons.users), label: 'Akun'),
        ],
      ),
    );
  }
}

class _HomeAdmin extends StatefulWidget {
  const _HomeAdmin();
  @override
  State<_HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<_HomeAdmin> {
  final _controller = AdminController();
  final _kontrolerTema = KontrolerTema();

  String _namaPengguna = 'Admin';
  String _identitasPengguna = '';
  String _tanggalMulaiSemester = '';
  bool _loadingSemester = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _kontrolerTema.addListener(() => setState(() {}));
    _controller.fetchStatistik();
    _loadUserData();
    _loadTanggalSemester();
  }

  Future<void> _loadUserData() async {
    final user = await _controller.getLoggedInUser();
    if (user != null && mounted) {
      setState(() {
        _namaPengguna = user.nama;
        _identitasPengguna = user.nomorIdentitas;
      });
    }
  }

  Future<void> _loadTanggalSemester() async {
    final tanggal = await _controller.fetchTanggalMulaiSemester();
    if (mounted) {
      setState(() {
        _tanggalMulaiSemester = tanggal;
        _loadingSemester = false;
      });
    }
  }

  Future<void> _pilihTanggalSemester() async {
    final isDark = _kontrolerTema.isDarkMode;
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(_tanggalMulaiSemester);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
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
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() => _loadingSemester = true);
      try {
        final success = await _controller.setTanggalMulaiSemester(formatted);
        if (!mounted) return;
        if (success) {
          setState(() {
            _tanggalMulaiSemester = formatted;
            _loadingSemester = false;
          });
          showFToast(
            context: context,
            title: const Text('Tanggal mulai semester berhasil diperbarui'),
          );
        } else {
          setState(() => _loadingSemester = false);
          showFToast(
            context: context,
            title: const Text('Gagal memperbarui tanggal semester'),
            variant: FToastVariant.destructive,
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _loadingSemester = false);
        if (e.toString().contains('SESSION_EXPIRED')) {
          showFToast(
            context: context,
            title: const Text('Sesi berakhir, silakan login ulang'),
            variant: FToastVariant.destructive,
          );
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          showFToast(
            context: context,
            title: const Text('Terjadi kesalahan, coba lagi'),
            variant: FToastVariant.destructive,
          );
        }
      }
    }
  }

  String _formatTanggalDisplay(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('dd MMMM yyyy', 'id').format(date);
    } catch (_) {
      return tanggal;
    }
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalProfilSlider(
        nama: _namaPengguna,
        identitas: _identitasPengguna,
        peran: 'Admin',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = _kontrolerTema.isDarkMode;
    final scaffoldBgColor = theme.colors.background;
    final headerTextColor = Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: buatAppBar(
        context: context,
        judul: 'Dasbor Admin',
        warnaKontras: headerTextColor,
        leading: IconButton(
          icon: const Icon(FIcons.user, color: Colors.white),
          onPressed: _showProfile,
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: headerTextColor),
            onPressed: () => _kontrolerTema.toggleTheme(),
          ),
          IconButton(
            icon: Icon(FIcons.logOut, color: headerTextColor),
            onPressed: () {
               Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Hai, ${_namaPengguna.split(' ')[0]}', style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ringkasan Sistem', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2, color: headerTextColor)),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colors.card,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: isDarkMode 
                    ? Border.all(color: Colors.white, width: 1.5) 
                    : null,
              ),
              child: _controller.sedangLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistik Terkini', style: TextStyle(color: theme.colors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: _controller.statistik.map((stat) => KartuStatistik(
                        label: stat['label'], 
                        value: stat['value'], 
                        icon: FIcons.check,
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text('Pengaturan Semester', style: TextStyle(color: theme.colors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(FIcons.calendar, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Mulai Semester',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: theme.colors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _loadingSemester
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(
                                        _formatTanggalDisplay(_tanggalMulaiSemester),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          FButton(
                            size: FButtonSizeVariant.sm,
                            onPress: _pilihTanggalSemester,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_calendar, size: 14),
                                SizedBox(width: 6),
                                Text('Ubah'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
