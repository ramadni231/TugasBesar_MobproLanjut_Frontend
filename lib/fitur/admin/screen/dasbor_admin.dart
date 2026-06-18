import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/component/kartu_statistik.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_ruangan.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_matkul.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_jadwal.dart';
import 'package:tugas_besar/fitur/admin/screen/validasi_izin_global.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/fitur/admin/screen/manajemen_pengguna.dart';
import 'package:tugas_besar/umum/component/modal_profil_slider.dart';

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
    const ValidasiIzinGlobal(),
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
          BottomNavigationBarItem(icon: Icon(FIcons.fileCheck), label: 'Validasi'),
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

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalProfilSlider(
        nama: 'Admin Pusat',
        identitas: 'ADMIN001',
        peran: 'Admin',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _kontrolerTema.addListener(() => setState(() {}));
    _controller.fetchStatistik();
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
        title: Text('Dasbor Admin', style: TextStyle(color: headerTextColor)),
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
                Text('Hai, Admin Pusat', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Ringkasan Sistem', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2, color: headerTextColor)),
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
                        icon: FIcons.check, // Fixed or mapped icon
                      )).toList(),
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
