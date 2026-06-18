import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/kartu_jadwal_hari_ini.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/jadwal_mahasiswa.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/pemindai_presensi.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/riwayat_presensi.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/pengajuan_izin.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/modal_profil_slider.dart';

class DasborMahasiswa extends StatefulWidget {
  const DasborMahasiswa({super.key});

  @override
  State<DasborMahasiswa> createState() => _DasborMahasiswaState();
}

class _DasborMahasiswaState extends State<DasborMahasiswa> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeMahasiswa(),
    const JadwalMahasiswa(),
    const PemindaiPresensi(),
    const RiwayatPresensi(),
    const PengajuanIzin(),
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
          BottomNavigationBarItem(icon: Icon(FIcons.calendar), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(FIcons.scan), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(FIcons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(FIcons.fileText), label: 'Izin'),
        ],
      ),
    );
  }
}

class _HomeMahasiswa extends StatefulWidget {
  const _HomeMahasiswa();
  @override
  State<_HomeMahasiswa> createState() => _HomeMahasiswaState();
}

class _HomeMahasiswaState extends State<_HomeMahasiswa> {
  final _controller = MahasiswaController();
  final _kontrolerTema = KontrolerTema();

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalProfilSlider(
        nama: 'Andrean Syah Putra',
        identitas: 'STI202303719',
        peran: 'Mahasiswa',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _kontrolerTema.addListener(() => setState(() {}));
    _controller.fetchJadwalHariIni();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = _kontrolerTema.isDarkMode;
    final scaffoldBgColor = theme.colors.background;
    final headerTextColor = Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FIcons.user, color: Colors.white),
          onPressed: _showProfile,
        ),
        title: Text('Dasbor Mahasiswa', style: TextStyle(color: headerTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: headerTextColor),
            onPressed: () => _kontrolerTema.toggleTheme(),
          ),
          IconButton(
            icon: Icon(FIcons.logOut, color: headerTextColor),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
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
                Text(
                  'Hai, Andrean',
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jadwal Anda',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: headerTextColor,
                  ),
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
              ),
              child: _controller.sedangLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Oktober 2023',
                          style: TextStyle(
                            color: theme.colors.foreground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              FIcons.chevronLeft,
                              color: theme.colors.foreground,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              FIcons.chevronRight,
                              color: theme.colors.foreground,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        final dates = ['23', '24', '25', '26', '27', '28', '29'];
                        final isSelected = index == 2;

                        return Column(
                          children: [
                            Text(
                              days[index],
                              style: TextStyle(
                                color: isDarkMode ? Colors.white60 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dates[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colors.foreground,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Jadwal Aktif',
                      style: TextStyle(
                        color: theme.colors.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_controller.jadwalHariIni.isEmpty)
                      const Text('Tidak ada jadwal aktif hari ini.')
                    else
                      ..._controller.jadwalHariIni.map((jadwal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: KartuJadwalHariIni(
                          matakuliah: jadwal.matakuliah.namaMatkul,
                          waktu: '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                          ruang: jadwal.ruangan.namaRuangan,
                          onScan: () =>
                              Navigator.pushNamed(context, '/mahasiswa/scan'),
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
