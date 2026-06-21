import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tugas_besar/fitur/dosen/controller/dosen_controller.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/admin/model/presensi_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';
import 'package:tugas_besar/umum/utilitas/ekspor_helper.dart';

class DetailKelasAktif extends StatefulWidget {
  final String matakuliah;

  const DetailKelasAktif({
    super.key,
    required this.matakuliah,
  });

  @override
  State<DetailKelasAktif> createState() => _DetailKelasAktifState();
}

class _DetailKelasAktifState extends State<DetailKelasAktif> {
  final _controller = DosenController();
  
  Timer? _timer;
  Timer? _countdownTimer;
  final ValueNotifier<Duration> _sisaWaktuNotifier = ValueNotifier(Duration.zero);
  Duration get _sisaWaktu => _sisaWaktuNotifier.value;
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
        _startPolling();
        _startCountdown();
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _sisaWaktuNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_jadwal == null) return;
    final data = await _controller.fetchJadwalDetail(_jadwal!.id);
    if (mounted) {
      setState(() {
        if (data != null) {
          _listPertemuan = data['pertemuan'] ?? [];
          // Update local jadwal object if backend returns updated active session info
          final rawJadwal = data['jadwal'];
          if (rawJadwal != null) {
            _jadwal = Jadwal.fromJson(rawJadwal);
          }
        }
        _sedangLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_jadwal?.sesiAktif == null) return;
    final initial = _jadwal!.sesiAktif!.berakhirPada.difference(DateTime.now());
    _sisaWaktuNotifier.value = initial.isNegative ? Duration.zero : initial;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_jadwal?.sesiAktif == null) return;
      final sisa = _jadwal!.sesiAktif!.berakhirPada.difference(DateTime.now());
      _sisaWaktuNotifier.value = sisa.isNegative ? Duration.zero : sisa;
      if (sisa.isNegative) {
        _countdownTimer?.cancel();
      }
      setState(() {}); // refresh UI (card section)
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      // Poll only if there is an active session
      final hasActive = _listPertemuan.any((p) => p['is_sesi_aktif'] == true);
      if (hasActive) {
        _loadData();
      }
    });
  }

  Future<void> _bukaPresensi(int pertemuanKe) async {
    if (_jadwal == null) return;
    setState(() => _sedangLoading = true);
    final res = await _controller.aktifkanSesi(_jadwal!.id, pertemuanKe: pertemuanKe);
    if (!mounted) return;
    if (res != null) {
      showFToast(context: context, title: const Text('Presensi berhasil dibuka!'));
      await _loadData();
      _startCountdown();
    } else {
      showFToast(context: context, title: const Text('Gagal membuka presensi'), variant: FToastVariant.destructive);
      setState(() => _sedangLoading = false);
    }
  }

  Future<void> _tutupPresensi(int sesiId) async {
    setState(() => _sedangLoading = true);
    final sukses = await _controller.hentikanSesi(sesiId);
    if (!mounted) return;
    if (sukses) {
      showFToast(context: context, title: const Text('Presensi berhasil ditutup'));
      await _loadData();
    } else {
      showFToast(context: context, title: const Text('Gagal menutup presensi'), variant: FToastVariant.destructive);
      setState(() => _sedangLoading = false);
    }
  }

  Future<void> _lihatDetailSesi(int pertemuanKe, String label) async {
    if (_jadwal == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ModalDetailSesi(
          jadwalId: _jadwal!.id,
          pertemuanKe: pertemuanKe,
          label: label,
          controller: _controller,
        );
      },
    );
  }

  String _formatTanggal(String tanggal) {
    final parts = tanggal.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return tanggal;
  }

  /// Menampilkan bottom sheet QR code untuk pertemuan aktif.
  void _tampilkanQrDialog(Map<String, dynamic> sesiData) {
    final isDark = KontrolerTema().isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {

            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: 24 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR Code — ${sesiData['label']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_jadwal!.ruangan.namaRuangan} • ${_jadwal!.metode.toUpperCase()}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Countdown
                  ValueListenableBuilder<Duration>(
                    valueListenable: _sisaWaktuNotifier,
                    builder: (_, durasi, __) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: durasi.inMinutes < 5
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: durasi.inMinutes < 5 ? Colors.red : Colors.blue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sisa: ${_formatDuration(durasi)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: durasi.inMinutes < 5 ? Colors.red : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // QR image
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: sesiData['token_qr'] as String,
                        version: QrVersions.auto,
                        size: 220.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Statistik hadir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statChip(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        label: '${sesiData['jumlah_hadir']} Hadir',
                      ),
                      const SizedBox(width: 12),
                      _statChip(
                        icon: Icons.people,
                        color: Colors.blue,
                        label: '${sesiData['total_mahasiswa']} Total',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tutup presensi dari modal
                  FButton(
                    variant: FButtonVariant.destructive,
                    onPress: () {
                      Navigator.pop(ctx);
                      _tutupPresensi(sesiData['sesi_aktif_id'] as int);
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Tutup Presensi'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statChip({required IconData icon, required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
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
          judul: 'Detail Kelas',
        ),
        body: const Center(
          child: Text('Data kelas tidak ditemukan atau parameter tidak valid.'),
        ),
      );
    }

    // Cari sesi aktif saat ini
    dynamic sesiAktifData;
    for (var p in _listPertemuan) {
      if (p['is_sesi_aktif'] == true && _sisaWaktu > Duration.zero) {
        sesiAktifData = p;
        break;
      }
    }

    final isSesiAktif = sesiAktifData != null;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: _jadwal!.matakuliah.namaMatkul,
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
                    // ── QR Card section: tampil jika ada sesi aktif ──
                    if (isSesiAktif) ...[
                      FCard(
                        title: Text('Scan QR Code — ${sesiAktifData['label']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Metode: ${_jadwal!.metode.toUpperCase()} • Ruang: ${_jadwal!.ruangan.namaRuangan}'),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<Duration>(
                              valueListenable: _sisaWaktuNotifier,
                              builder: (_, durasi, __) => Text(
                                'Sisa Waktu: ${_formatDuration(durasi)}',
                                style: TextStyle(
                                  color: durasi.inMinutes < 5 ? Colors.red : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                  ),
                                  child: QrImageView(
                                    data: sesiAktifData['token_qr'],
                                    version: QrVersions.auto,
                                    size: 180.0,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _statChip(
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  label: '${sesiAktifData['jumlah_hadir']} Hadir',
                                ),
                                const SizedBox(width: 12),
                                _statChip(
                                  icon: Icons.people,
                                  color: Colors.blue,
                                  label: '${sesiAktifData['total_mahasiswa']} Total',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FButton(
                              variant: FButtonVariant.destructive,
                              onPress: () => _tutupPresensi(sesiAktifData['sesi_aktif_id']),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stop_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Tutup Presensi'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Text(
                      'Sesi Pertemuan (16 Sesi)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    // List of 16 Meetings
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _listPertemuan.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = _listPertemuan[index];
                        final pertemuanKe = p['pertemuan_ke'] as int;
                        final label = p['label'] as String;
                        final tanggal = p['tanggal'] as String;
                        final isSesiAktifItem = p['is_sesi_aktif'] as bool;
                        final totalMahasiswa = p['total_mahasiswa'] as int;
                        final jumlahHadir = p['jumlah_hadir'] as int;
                        final jumlahIzin = p['jumlah_izin'] as int;
                        final jumlahSakit = p['jumlah_sakit'] as int;
                        final jumlahAlpa = p['jumlah_alpa'] as int;


                        // UTS & UAS style
                        final isUjian = label == 'UTS' || label == 'UAS';

                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSesiAktifItem
                                  ? Colors.blue.shade300
                                  : (isDarkMode ? theme.colors.border : Colors.grey.shade200),
                              width: isSesiAktifItem ? 2 : 1,
                            ),
                          ),
                          color: isSesiAktifItem
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
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Baris statistik + tombol icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hadir: $jumlahHadir / $totalMahasiswa',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: theme.colors.foreground,
                                          ),
                                        ),
                                        Text(
                                          'Izin: $jumlahIzin • Sakit: $jumlahSakit • Alpa: $jumlahAlpa',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // ── Tombol QR — hanya muncul saat sesi aktif ──
                                        if (isSesiAktifItem) ...[
                                          Tooltip(
                                            message: 'Tampilkan QR Code',
                                            child: FButton.icon(
                                              size: FButtonSizeVariant.sm,
                                              onPress: () => _tampilkanQrDialog(p),
                                              child: const Icon(FIcons.qrCode, size: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        // ── Tombol Buka / Tutup presensi ──
                                        if (!isSesiAktifItem)
                                          Tooltip(
                                            message: 'Buka Presensi',
                                            child: FButton.icon(
                                              size: FButtonSizeVariant.sm,
                                              onPress: () => _bukaPresensi(pertemuanKe),
                                              child: const Icon(Icons.play_arrow_rounded, size: 18),
                                            ),
                                          )
                                        else
                                          Tooltip(
                                            message: 'Tutup Presensi',
                                            child: FButton.icon(
                                              variant: FButtonVariant.destructive,
                                              size: FButtonSizeVariant.sm,
                                              onPress: () => _tutupPresensi(p['sesi_aktif_id'] as int),
                                              child: const Icon(Icons.stop_rounded, size: 18),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        // ── Tombol Lihat Presensi ──
                                        Tooltip(
                                          message: 'Lihat Presensi',
                                          child: FButton.icon(
                                            variant: FButtonVariant.outline,
                                            size: FButtonSizeVariant.sm,
                                            onPress: () => _lihatDetailSesi(pertemuanKe, label),
                                            child: const Icon(FIcons.users, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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

class _ModalDetailSesi extends StatefulWidget {
  final int jadwalId;
  final int pertemuanKe;
  final String label;
  final DosenController controller;

  const _ModalDetailSesi({
    required this.jadwalId,
    required this.pertemuanKe,
    required this.label,
    required this.controller,
  });

  @override
  State<_ModalDetailSesi> createState() => _ModalDetailSesiState();
}

class _ModalDetailSesiState extends State<_ModalDetailSesi> {
  final _searchController = TextEditingController();
  bool _loading = true;
  List<Presensi> _list = [];
  List<Presensi> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterList);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await widget.controller.fetchPresensiSesi(widget.jadwalId, widget.pertemuanKe);
    if (mounted) {
      setState(() {
        _list = data;
        _filteredList = data;
        _loading = false;
      });
    }
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _list.where((p) {
        return p.mahasiswa.nama.toLowerCase().contains(query) ||
            p.mahasiswa.nomorIdentitas.toLowerCase().contains(query) ||
            p.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _eksporData() {
    if (_list.isEmpty) {
      showFToast(
        context: context,
        title: const Text('Tidak ada data untuk diekspor'),
        variant: FToastVariant.destructive,
      );
      return;
    }

    final headers = ['Nama Mahasiswa', 'NIM', 'Status Kehadiran', 'Jam Masuk'];
    final rows = _list.map((p) => [
      p.mahasiswa.nama,
      p.mahasiswa.nomorIdentitas,
      p.status,
      p.jamMasuk ?? '-',
    ]).toList();

    EksporHelper.eksporKeCSV(
      context: context,
      namaFile: 'Presensi_Kelas_${widget.label}',
      headers: headers,
      rows: rows,
    );
  }

  void _showUbahStatusDialog(Presensi item) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? theme.colors.background : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ubah Kehadiran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ubah status kehadiran untuk ${item.mahasiswa.nama} (${item.mahasiswa.nomorIdentitas}) pada ${widget.label}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              _buildPilihanStatus(context, item, 'hadir', 'HADIR', Colors.green),
              const SizedBox(height: 10),
              _buildPilihanStatus(context, item, 'sakit', 'SAKIT', Colors.amber),
              const SizedBox(height: 10),
              _buildPilihanStatus(context, item, 'izin', 'IZIN', Colors.blue),
              const SizedBox(height: 10),
              _buildPilihanStatus(context, item, 'alpa', 'ALPA', Colors.red),
              const SizedBox(height: 10),
              _buildPilihanStatus(context, item, 'belum_dimulai', 'BELUM ABSEN / RESET', Colors.grey),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPilihanStatus(
    BuildContext context,
    Presensi item,
    String statusKey,
    String statusLabel,
    Color warna,
  ) {
    final theme = FTheme.of(context);
    final isSelected = item.status.toLowerCase() == statusKey.toLowerCase();

    return InkWell(
      onTap: () async {
        Navigator.pop(context); // Tutup dialog
        setState(() => _loading = true);
        
        final success = await widget.controller.updatePresensiManual(
          widget.jadwalId,
          widget.pertemuanKe,
          item.mahasiswa.id,
          statusKey,
        );

        if (!context.mounted) return;

        if (success) {
          showFToast(
            context: context,
            title: Text('Berhasil mengubah status kehadiran menjadi $statusLabel'),
          );
          _load(); // Reload data presensi
        } else {
          showFToast(
            context: context,
            title: const Text('Gagal mengubah status kehadiran'),
            variant: FToastVariant.destructive,
          );
          setState(() => _loading = false);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? warna.withValues(alpha: 0.15) 
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? warna : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? warna : theme.colors.foreground,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: warna, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colors.background : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Detail Presensi - ${widget.label}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  FButton(
                    variant: FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    onPress: _eksporData,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FIcons.download, size: 14),
                        SizedBox(width: 4),
                        Text('Ekspor'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          FTextField(
            hint: 'Cari nama, NIM, atau status...',
            control: FTextFieldControl.managed(controller: _searchController),
          ),
          const SizedBox(height: 16),
          _loading
              ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
              : _filteredList.isEmpty
                  ? const SizedBox(
                      height: 150,
                      child: Center(child: Text('Tidak ada mahasiswa yang tercatat.')),
                    )
                  : SizedBox(
                      height: 350,
                      child: ListView.separated(
                        itemCount: _filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _filteredList[index];
                          final waktu = item.jamMasuk != null ? item.jamMasuk!.substring(0, 5) : '-';
                          
                          Color badgeColor;
                          switch (item.status.toLowerCase()) {
                            case 'hadir':
                              badgeColor = Colors.green;
                              break;
                            case 'sakit':
                              badgeColor = Colors.amber;
                              break;
                            case 'izin':
                              badgeColor = Colors.blue;
                              break;
                            case 'alpa':
                              badgeColor = Colors.red;
                              break;
                            default:
                              badgeColor = Colors.grey;
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.mahasiswa.nama),
                            subtitle: Text('${item.mahasiswa.nomorIdentitas} • Jam: $waktu'),
                            onTap: () => _showUbahStatusDialog(item),
                            trailing: InkWell(
                              onTap: () => _showUbahStatusDialog(item),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 12, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
