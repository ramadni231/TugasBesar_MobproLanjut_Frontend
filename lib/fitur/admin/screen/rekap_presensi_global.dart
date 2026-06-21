import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';
import 'package:tugas_besar/umum/utilitas/ekspor_helper.dart';

class RekapPresensi extends StatefulWidget {
  const RekapPresensi({super.key});

  @override
  State<RekapPresensi> createState() => _RekapPresensiState();
}

class _RekapPresensiState extends State<RekapPresensi> {
  final _controller = AdminController();
  bool _sedangLoading = true;
  Jadwal? _jadwal;
  List<dynamic> _listPertemuan = [];
  List<dynamic> _listRekap = [];
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
    final data = await _controller.fetchJadwalRekap(_jadwal!.id);
    if (mounted) {
      setState(() {
        if (data != null) {
          _listPertemuan = data['pertemuan'] ?? [];
          _listRekap = data['rekap'] ?? [];
        }
        _sedangLoading = false;
      });
    }
  }

  void _eksporRekap() {
    if (_listRekap.isEmpty) {
      showFToast(
        context: context,
        title: const Text('Tidak ada data rekap untuk diekspor'),
        variant: FToastVariant.destructive,
      );
      return;
    }

    final headers = ['Nama Mahasiswa', 'NIM'];
    for (var p in _listPertemuan) {
      headers.add(p['label'] as String);
    }
    headers.addAll(['Total Hadir', 'Persentase Kehadiran']);

    final List<List<String>> rows = [];
    for (var r in _listRekap) {
      final mhs = r['mahasiswa'];
      final nama = mhs['nama'] as String;
      final nim = mhs['nomor_identitas'] as String;
      final kehadiran = r['kehadiran'] as List<dynamic>;
      final ringkasan = r['ringkasan'];
      final totalHadir = ringkasan['hadir'].toString();
      final persentase = '${ringkasan['persentase']}%';

      final row = [nama, nim];
      for (var k in kehadiran) {
        row.add(k['status'] as String);
      }
      row.addAll([totalHadir, persentase]);
      rows.add(row);
    }

    EksporHelper.eksporKeCSV(
      context: context,
      namaFile: 'Rekap_Presensi_${_jadwal!.matakuliah.kodeMatkul}',
      headers: headers,
      rows: rows,
    );
  }

  Widget _buildGridCell(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'hadir':
        color = Colors.green;
        text = 'H';
        break;
      case 'sakit':
        color = Colors.amber;
        text = 'S';
        break;
      case 'izin':
        color = Colors.blue;
        text = 'I';
        break;
      case 'alpa':
        color = Colors.red;
        text = 'A';
        break;
      default:
        color = Colors.grey.shade300;
        text = '-';
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
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
          judul: 'Rekap Presensi',
        ),
        body: const Center(
          child: Text('Data kelas tidak ditemukan.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Rekap: ${_jadwal!.matakuliah.kodeMatkul}',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            onPress: _eksporRekap,
            child: const Icon(FIcons.download, size: 20),
          ),
          const SizedBox(width: 8),
        ],
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
                    // Class Header
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tabel Rekap Kehadiran Kelas',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            _buildLegendItem('H', Colors.green),
                            const SizedBox(width: 6),
                            _buildLegendItem('S', Colors.amber),
                            const SizedBox(width: 6),
                            _buildLegendItem('I', Colors.blue),
                            const SizedBox(width: 6),
                            _buildLegendItem('A', Colors.red),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _listRekap.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(child: Text('Belum ada mahasiswa yang mengambil kelas ini.')),
                            ),
                          )
                        : Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDarkMode ? theme.colors.border : Colors.grey.shade200,
                              ),
                            ),
                            color: isDarkMode ? theme.colors.card : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 16,
                                  horizontalMargin: 16,
                                  headingRowColor: WidgetStateProperty.all(
                                    isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                                  ),
                                  columns: [
                                    const DataColumn(
                                      label: Text(
                                        'Mahasiswa',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // P1 to P14 + UTS + UAS columns
                                    ..._listPertemuan.map((p) {
                                      final label = p['label'] as String;
                                      return DataColumn(
                                        label: Center(
                                          child: Text(
                                            label,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                      );
                                    }),
                                    const DataColumn(
                                      label: Text(
                                        'Hadir',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const DataColumn(
                                      label: Text(
                                        '%',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: _listRekap.map((r) {
                                    final mhs = r['mahasiswa'];
                                    final nama = mhs['nama'] as String;
                                    final nim = mhs['nomor_identitas'] as String;
                                    final kehadiran = r['kehadiran'] as List<dynamic>;
                                    final ringkasan = r['ringkasan'];
                                    final totalHadir = ringkasan['hadir'];
                                    final persentase = ringkasan['persentase'];

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                nama,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              Text(
                                                nim,
                                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...kehadiran.map((k) {
                                          final status = k['status'] as String;
                                          return DataCell(
                                            Center(child: _buildGridCell(status)),
                                          );
                                        }),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              '$totalHadir',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              '$persentase%',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: (persentase as num) >= 75
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
