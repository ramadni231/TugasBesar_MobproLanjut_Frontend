import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class DetailJadwalMahasiswa extends StatefulWidget {
  const DetailJadwalMahasiswa({super.key});

  @override
  State<DetailJadwalMahasiswa> createState() => _DetailJadwalMahasiswaState();
}

class _DetailJadwalMahasiswaState extends State<DetailJadwalMahasiswa> {
  final _controller = MahasiswaController();
  bool _sedangLoading = true;
  Jadwal? _jadwal;
  List<dynamic> _listPertemuan = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Jadwal) {
        _jadwal = args;
        _loadData();
      }
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    if (_jadwal == null) return;
    setState(() => _sedangLoading = true);
    final data = await _controller.fetchJadwalDetail(_jadwal!.id);
    if (mounted) {
      setState(() {
        if (data != null) {
          _listPertemuan = data['pertemuan'] ?? [];
        }
        _sedangLoading = false;
      });
    }
  }

  String _formatTanggal(String tanggal) {
    final parts = tanggal.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return tanggal;
  }

  Widget _buildStatusBadge(String status, FThemeData theme) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'hadir':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'HADIR';
        break;
      case 'sakit':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade700;
        label = 'SAKIT';
        break;
      case 'izin':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'IZIN';
        break;
      case 'alpa':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'ALPA';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        label = 'BELUM MULAI';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    if (_jadwal == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
        appBar: buatAppBar(
          context: context,
          judul: 'Detail Jadwal',
        ),
        body: const Center(
          child: Text('Data jadwal tidak valid.'),
        ),
      );
    }

    // Hitung persentase kehadiran
    int totalHadir = 0;
    for (var p in _listPertemuan) {
      final status = (p['status'] as String).toLowerCase();
      if (status == 'hadir') {
        totalHadir++;
      }
    }
    final persentase = ((totalHadir / 16) * 100).round();

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: '${_jadwal!.matakuliah.kodeMatkul} - Detail Kelas',
      ),
      body: _sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Ringkasan Mata Kuliah
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _jadwal!.matakuliah.namaMatkul,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dosen: ${_jadwal!.dosen.nama}\n'
                              'Ruangan: ${_jadwal!.ruangan.namaRuangan} (${_jadwal!.metode.toUpperCase()})\n'
                              'Waktu: ${_jadwal!.hari}, ${_jadwal!.jamMulai.substring(0, 5)} - ${_jadwal!.jamSelesai.substring(0, 5)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Persentase Kehadiran:',
                                  style: TextStyle(color: theme.colors.foreground),
                                ),
                                Text(
                                  '$persentase%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: persentase >= 75 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sesi Pertemuan (16 Sesi)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    // List 16 Pertemuan
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _listPertemuan.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = _listPertemuan[index];
                        final label = p['label'] as String;
                        final tanggal = p['tanggal'] as String;
                        final status = p['status'] as String;
                        final isSesiAktif = p['is_sesi_aktif'] as bool;
                        final jamMasuk = p['jam_masuk'] as String?;

                        // UTS & UAS style
                        final isUjian = label == 'UTS' || label == 'UAS';

                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSesiAktif
                                  ? Colors.blue.shade300
                                  : (isDarkMode ? theme.colors.border : Colors.grey.shade200),
                              width: isSesiAktif ? 2 : 1,
                            ),
                          ),
                          color: isSesiAktif
                              ? Colors.blue.shade50.withValues(alpha: isDarkMode ? 0.1 : 0.6)
                              : (isDarkMode ? theme.colors.card : Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isUjian
                                            ? Colors.amber.shade700
                                            : Colors.blue.shade700,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatTanggal(tanggal),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${p['jam_mulai']} - ${p['jam_selesai']} WIB${p['ruangan_nama'] != _jadwal!.ruangan.namaRuangan ? ' • Ruang: ${p['ruangan_nama']}' : ''}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusBadge(status, theme),
                                  ],
                                ),
                                if (jamMasuk != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Masuk jam: ${jamMasuk.substring(0, 5)} WIB',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (isSesiAktif) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FButton(
                                      size: FButtonSizeVariant.sm,
                                      onPress: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/mahasiswa/scan',
                                          arguments: _jadwal,
                                        );
                                        _loadData();
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(FIcons.camera, size: 16),
                                          SizedBox(width: 6),
                                          Text('Pindai Presensi'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
