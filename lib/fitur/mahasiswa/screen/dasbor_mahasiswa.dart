import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/kartu_jadwal_hari_ini.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/jadwal_mahasiswa.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/pemindai_presensi.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/riwayat_presensi.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/peminatan_matakuliah.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/modal_profil_slider.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

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
  final _searchController = TextEditingController();
  
  String _namaPengguna = 'Mahasiswa';
  String _identitasPengguna = '';

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateState);
    _kontrolerTema.addListener(_updateState);
    _searchController.addListener(_updateState);
    _fetchDataForSelectedDate();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _kontrolerTema.removeListener(_updateState);
    _searchController.removeListener(_updateState);
    _searchController.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  String _formatTanggalAPI(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _fetchDataForSelectedDate() {
    _controller.fetchJadwalHariIni(tanggal: _formatTanggalAPI(_selectedDate));
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

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalProfilSlider(
        nama: _namaPengguna,
        identitas: _identitasPengguna,
        peran: 'Mahasiswa',
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
        judul: 'Dasbor Mahasiswa',
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
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchDataForSelectedDate();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hai, ${_namaPengguna.split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 18, 
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jadwal Anda',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: headerTextColor,
                          ),
                        ),
                        FButton(
                          size: FButtonSizeVariant.sm,
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PeminatanMatakuliah()),
                            );
                          },
                          child: const Text('Peminatan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 250,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: isDarkMode 
                      ? Border.all(color: Colors.white, width: 1.5) 
                      : null,
                ),
                padding: const EdgeInsets.all(24),
                child: _controller.sedangLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Calendar Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][_focusedDate.month - 1]} ${_focusedDate.year}',
                                style: TextStyle(
                                  color: theme.colors.foreground,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(FIcons.chevronLeft, color: theme.colors.foreground),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDate = _focusedDate.subtract(const Duration(days: 7));
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(FIcons.chevronRight, color: theme.colors.foreground),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDate = _focusedDate.add(const Duration(days: 7));
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Calendar Days
                          Builder(
                            builder: (context) {
                              final monday = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
                              final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  final date = monday.add(Duration(days: index));
                                  final isSelected = date.year == _selectedDate.year &&
                                      date.month == _selectedDate.month &&
                                      date.day == _selectedDate.day;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                      _fetchDataForSelectedDate();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            days[index],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDarkMode ? Colors.white60 : Colors.grey),
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : theme.colors.foreground,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }
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
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDarkMode ? theme.colors.border : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            color: isDarkMode ? theme.colors.card : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(FIcons.search, color: theme.colors.mutedForeground, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      style: TextStyle(color: theme.colors.foreground),
                                      decoration: InputDecoration(
                                        hintText: 'Cari mata kuliah atau ruangan...',
                                        hintStyle: TextStyle(color: theme.colors.mutedForeground),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Builder(
                            builder: (context) {
                              final query = _searchController.text.toLowerCase();
                              final filteredList = _controller.jadwalHariIni.where((jadwal) {
                                return jadwal.matakuliah.namaMatkul.toLowerCase().contains(query) ||
                                    jadwal.matakuliah.kodeMatkul.toLowerCase().contains(query) ||
                                    jadwal.ruangan.namaRuangan.toLowerCase().contains(query);
                              }).toList();

                              if (filteredList.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(child: Text('Tidak ada jadwal aktif.')),
                                );
                              }

                              return Column(
                                children: filteredList.map((jadwal) {
                                  bool isSesiAktif = jadwal.sesiAktif != null && jadwal.sesiAktif!.isAktif && jadwal.sesiAktif!.berakhirPada.isAfter(DateTime.now());
                                  bool isSesiHabis = jadwal.sesiAktif != null && (!jadwal.sesiAktif!.isAktif || jadwal.sesiAktif!.berakhirPada.isBefore(DateTime.now()));

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: KartuJadwalHariIni(
                                      matakuliah: '${jadwal.matakuliah.kodeMatkul} - ${jadwal.matakuliah.namaMatkul}',
                                      namaDosen: jadwal.dosen.nama,
                                      waktu: '${jadwal.jamMulai.substring(0, 5)} - ${jadwal.jamSelesai.substring(0, 5)} • ${jadwal.metode.toUpperCase()}',
                                      ruang: jadwal.ruangan.namaRuangan,
                                      isSesiAktif: isSesiAktif,
                                      isSesiHabis: isSesiHabis,
                                      onTap: () async {
                                        await Navigator.pushNamed(context, '/mahasiswa/jadwal');
                                        _fetchDataForSelectedDate();
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
