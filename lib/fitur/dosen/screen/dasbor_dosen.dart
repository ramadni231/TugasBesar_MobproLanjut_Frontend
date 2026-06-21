import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/dosen/controller/dosen_controller.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/dosen/component/kartu_kelas_dosen.dart';
import 'package:tugas_besar/fitur/dosen/screen/jadwal_mengajar.dart';
import 'package:tugas_besar/fitur/dosen/screen/riwayat_presensi_dosen.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/modal_profil_slider.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

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
    const RiwayatPresensiDosen(),
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
          BottomNavigationBarItem(icon: Icon(FIcons.history), label: 'Riwayat'),
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
  final _searchController = TextEditingController();

  String _namaPengguna = 'Dosen';
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
    _controller.fetchKelasHariIni(tanggal: _formatTanggalAPI(_selectedDate));
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
        peran: 'Dosen',
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
        judul: 'Dasbor Dosen',
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
                    Text('Hai, Bapak/Ibu ${_namaPengguna.split(',')[0]}', style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Jadwal Mengajar', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2, color: headerTextColor)),
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
                  color: isDarkMode ? theme.colors.card : Colors.white,
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
                                style: TextStyle(color: theme.colors.foreground, fontSize: 18, fontWeight: FontWeight.bold),
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
                              )
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
                                              color: isSelected ? Colors.white : theme.colors.foreground,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            )
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
                          Text('Kelas Aktif Hari Ini', style: TextStyle(color: theme.colors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
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
                                        hintText: 'Cari Kelas atau Ruangan...',
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
                              final kelasHariIni = _controller.kelasHariIni.where((j) {
                                return j.matakuliah.namaMatkul.toLowerCase().contains(query) ||
                                      j.ruangan.namaRuangan.toLowerCase().contains(query);
                              }).toList();

                              if (kelasHariIni.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(child: Text('Tidak ada kelas aktif hari ini.')),
                                );
                              }

                              return Column(
                                children: kelasHariIni.map((jadwal) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: KartuKelasDosen(
                                    matakuliah: '${jadwal.matakuliah.kodeMatkul} - ${jadwal.matakuliah.namaMatkul}',
                                    waktu: '${jadwal.jamMulai.substring(0, 5)} - ${jadwal.jamSelesai.substring(0, 5)} • ${jadwal.metode.toUpperCase()}',
                                    ruang: jadwal.ruangan.namaRuangan,
                                    hadir: jadwal.hadirCount,
                                    total: jadwal.ruangan.kapasitas,
                                    isSesiAktif: jadwal.sesiAktif != null && jadwal.sesiAktif!.isAktif,
                                    onBukaPresensi: () async {
                                       if (jadwal.sesiAktif != null && jadwal.sesiAktif!.isAktif) {
                                         Navigator.pushNamed(context, '/dosen/detail', arguments: jadwal);
                                       } else {
                                          final pKe = jadwal.sesiAktif?.pertemuanKe;
                                          final res = await _controller.aktifkanSesi(jadwal.id, pertemuanKe: pKe);
                                          if (res != null && context.mounted) {
                                            _fetchDataForSelectedDate();
                                            final sesi = SesiAktif.fromJson(res);
                                            final updatedJadwal = Jadwal(
                                              id: jadwal.id,
                                              matakuliah: jadwal.matakuliah,
                                              ruangan: jadwal.ruangan,
                                              dosen: jadwal.dosen,
                                              hari: jadwal.hari,
                                              jamMulai: jadwal.jamMulai,
                                              jamSelesai: jadwal.jamSelesai,
                                              metode: jadwal.metode,
                                              sesiAktif: sesi,
                                            );
                                            Navigator.pushNamed(context, '/dosen/detail', arguments: updatedJadwal);
                                          }
                                       }
                                     },
                                  ),
                                )).toList(),
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
