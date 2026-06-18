import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/dosen/controller/dosen_controller.dart';
import 'package:tugas_besar/fitur/dosen/component/kartu_kelas_dosen.dart';
import 'package:tugas_besar/fitur/dosen/screen/jadwal_mengajar.dart';
import 'package:tugas_besar/fitur/dosen/screen/validasi_izin.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/modal_profil_slider.dart';

class DasborDosen extends StatefulWidget {
  const DasborDosen({super.key});

  @override
  State<DasborDosen> createState() => _DasborDosenState();
}

class _DasborDosenState extends State<DasborDosen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeDosen(),
    const JadwalMengajar(),
    const ValidasiIzin(),
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
          BottomNavigationBarItem(icon: Icon(FIcons.fileCheck), label: 'Validasi'),
        ],
      ),
    );
  }
}

class _HomeDosen extends StatefulWidget {
  const _HomeDosen();
  @override
  State<_HomeDosen> createState() => _HomeDosenState();
}

class _HomeDosenState extends State<_HomeDosen> {
  final _controller = DosenController();
  final _kontrolerTema = KontrolerTema();

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalProfilSlider(
        nama: 'Turiman',
        identitas: '198001012010011001',
        peran: 'Dosen',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _kontrolerTema.addListener(() => setState(() {}));
    _controller.fetchJadwal();
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
        title: Text('Dasbor Dosen', style: TextStyle(color: headerTextColor)),
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
                Text('Hai, Bapak Turiman', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Jadwal Mengajar', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2, color: headerTextColor)),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mock Calendar Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Oktober 2023', style: TextStyle(color: theme.colors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Icon(FIcons.chevronLeft, color: theme.colors.foreground),
                            const SizedBox(width: 16),
                            Icon(FIcons.chevronRight, color: theme.colors.foreground),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Mock Calendar Days
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        final dates = ['23', '24', '25', '26', '27', '28', '29'];
                        final isSelected = index == 2;
                        
                        return Column(
                          children: [
                            Text(days[index], style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey, fontSize: 12)),
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
                                  color: isSelected ? Colors.white : theme.colors.foreground,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                )
                              ),
                            )
                          ],
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 32),
                    Text('Kelas Aktif Hari Ini', style: TextStyle(color: theme.colors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.jadwalMengajar.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final jadwal = _controller.jadwalMengajar[index];
                        return KartuKelasDosen(
                          matakuliah: jadwal.matakuliah.namaMatkul,
                          waktu: '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                          ruang: jadwal.ruangan.namaRuangan,
                          hadir: 0,
                          total: jadwal.ruangan.kapasitas,
                          onBukaPresensi: () async {
                            final res = await _controller.aktifkanSesi(jadwal.id);
                            if (res != null && context.mounted) {
                               Navigator.pushNamed(context, '/dosen/detail');
                            }
                          },
                        );
                      },
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
