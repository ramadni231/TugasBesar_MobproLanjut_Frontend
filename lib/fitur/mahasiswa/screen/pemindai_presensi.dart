import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/indikator_gps.dart';
import 'package:tugas_besar/fitur/admin/model/jadwal_model.dart';
import 'package:tugas_besar/fitur/mahasiswa/component/kartu_jadwal_hari_ini.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class PemindaiPresensi extends StatefulWidget {
  const PemindaiPresensi({super.key});

  @override
  State<PemindaiPresensi> createState() => _PemindaiPresensiState();
}

class _PemindaiPresensiState extends State<PemindaiPresensi> {
  final _controller = MahasiswaController();
  final _qrController = TextEditingController();
  
  bool _initialized = false;
  Jadwal? _jadwal;
  
  bool _checkingGps = false;
  double? _jarak;
  bool _dalamRadius = false;
  Position? _currentPosition;

  bool _isScanning = true;
  Timer? _countdownTimer;
  Duration _sisaWaktu = Duration.zero;

  bool _loadingClasses = false;
  List<Jadwal> _activeClasses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Jadwal) {
        _jadwal = args;
        _qrController.text = '';
        _checkGps();
        _startCountdown();
      } else {
        _loadActiveClasses();
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _qrController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveClasses() async {
    setState(() => _loadingClasses = true);
    await _controller.fetchJadwalHariIni();
    if (mounted) {
      setState(() {
        _activeClasses = _controller.jadwalHariIni.where((j) => j.sesiAktif != null).toList();
        _loadingClasses = false;
      });
    }
  }

  void _pilihKelas(Jadwal j) {
    setState(() {
      _jadwal = j;
      _qrController.text = '';
      _isScanning = true;
    });
    _checkGps();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_jadwal?.sesiAktif == null) return;
    _sisaWaktu = _jadwal!.sesiAktif!.berakhirPada.difference(DateTime.now());
    if (_sisaWaktu.isNegative) _sisaWaktu = Duration.zero;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_jadwal?.sesiAktif == null) return;
        _sisaWaktu = _jadwal!.sesiAktif!.berakhirPada.difference(DateTime.now());
        if (_sisaWaktu.isNegative) {
          _sisaWaktu = Duration.zero;
          _countdownTimer?.cancel();
        }
      });
    });
  }

  // Simulated scan removed. Live camera QR scan enabled.

  Future<void> _checkGps() async {
    if (_jadwal == null) return;
    if (_jadwal!.metode != 'luring') return;
    setState(() => _checkingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          _jadwal!.ruangan.latitude,
          _jadwal!.ruangan.longitude,
        );
        setState(() {
          _currentPosition = pos;
          _jarak = distance;
          _dalamRadius = distance <= _jadwal!.ruangan.radiusMeter;
        });
      }
    } catch (e) {
      debugPrint('GPS Error: $e');
    }
    setState(() => _checkingGps = false);
  }

  Future<void> _submitPresensi() async {
    if (_jadwal == null) return;
    if (_qrController.text.isEmpty) {
      showFToast(context: context, title: const Text('Token QR tidak boleh kosong'));
      return;
    }

    if (_jadwal!.metode == 'luring' && !_dalamRadius) {
      showFToast(
        context: context,
        title: const Text('Gagal: Anda berada di luar radius kelas.'),
        variant: FToastVariant.destructive,
      );
      return;
    }

    final lat = _currentPosition?.latitude ?? 0.0;
    final lng = _currentPosition?.longitude ?? 0.0;

    final sukses = await _controller.pindaiPresensi(
      _qrController.text,
      lat,
      lng,
    );

    if (!mounted) return;

    if (sukses) {
      showFToast(context: context, title: const Text('Presensi Berhasil Dicatat!'));
      Navigator.pushNamedAndRemoveUntil(context, '/mahasiswa', (route) => false);
    } else {
      showFToast(
        context: context,
        title: const Text('Gagal melakukan presensi. Token tidak valid atau sudah absen.'),
        variant: FToastVariant.destructive,
      );
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
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
          judul: 'Scan Presensi',
          leading: IconButton(
            icon: const Icon(FIcons.chevronLeft),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/mahasiswa', (route) => false),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _loadingClasses
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _activeClasses.isEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 32),
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
                                  'Tidak Ada Kelas Aktif',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colors.foreground),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Saat ini tidak ada kelas aktif hari ini yang dibuka untuk absensi.',
                                  style: TextStyle(fontSize: 13, color: theme.colors.mutedForeground),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FButton(
                                    size: FButtonSizeVariant.sm,
                                    onPress: _loadActiveClasses,
                                    child: const Text('Segarkan'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Pilih kelas aktif hari ini:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ..._activeClasses.map((j) {
                              bool isSesiAktif = j.sesiAktif != null && j.sesiAktif!.isAktif && j.sesiAktif!.berakhirPada.isAfter(DateTime.now());
                              bool isSesiHabis = j.sesiAktif != null && (!j.sesiAktif!.isAktif || j.sesiAktif!.berakhirPada.isBefore(DateTime.now()));

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: KartuJadwalHariIni(
                                  matakuliah: '${j.matakuliah.kodeMatkul} - ${j.matakuliah.namaMatkul}',
                                  namaDosen: j.dosen.nama,
                                  waktu: '${j.jamMulai.substring(0, 5)} - ${j.jamSelesai.substring(0, 5)} • ${j.metode.toUpperCase()}',
                                  ruang: j.ruangan.namaRuangan,
                                  isSesiAktif: isSesiAktif,
                                  isSesiHabis: isSesiHabis,
                                  onTap: () => _pilihKelas(j),
                                ),
                              );
                            }),
                      ],
                    ),
        ),
      );
    }

    final isLuring = _jadwal!.metode == 'luring';
    final isExpired = _sisaWaktu == Duration.zero;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Scan Presensi: ${_jadwal!.matakuliah.namaMatkul}',
        leading: IconButton(
          icon: const Icon(FIcons.chevronLeft),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/mahasiswa', (route) => false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Expiry / Countdown Card
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
                      isExpired ? 'Sesi Berakhir' : 'Sesi Presensi Aktif',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colors.foreground),
                    ),
                    const SizedBox(height: 8),
                    isExpired 
                      ? Text('Waktu kelas sudah habis, Anda tidak dapat melakukan presensi.', style: TextStyle(fontSize: 13, color: theme.colors.mutedForeground))
                      : Text('Waktu Tersisa: ${_formatDuration(_sisaWaktu)}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GPS Location Status
            if (isLuring && !isExpired) ...[
              if (_checkingGps)
                const Center(child: CircularProgressIndicator())
              else if (_jarak != null)
                IndikatorGps(dalamRadius: _dalamRadius, jarak: _jarak!)
              else
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
                        Text('Gagal Mendapatkan Lokasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colors.foreground)),
                        const SizedBox(height: 8),
                        Text('Pastikan GPS aktif dan izin lokasi diberikan.', style: TextStyle(fontSize: 13, color: theme.colors.mutedForeground)),
                        const SizedBox(height: 12),
                        FButton(
                          size: FButtonSizeVariant.sm,
                          onPress: _checkGps,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else if (!isExpired)
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
                      Text('Kelas Daring (Online)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colors.foreground)),
                      const SizedBox(height: 8),
                      Text('Presensi kelas ini tidak memerlukan pengecekan radius lokasi/GPS.', style: TextStyle(fontSize: 13, color: theme.colors.mutedForeground)),
                      const SizedBox(height: 12),
                      const Icon(FIcons.wifi, color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Simulated Scan View / Input Form
            if (!isExpired)
              _isScanning
                ? Card(
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
                          Text('Sedang Memindai QR...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colors.foreground)),
                          const SizedBox(height: 8),
                          Text('Arahkan kamera ke QR Code yang ditampilkan Dosen.', style: TextStyle(fontSize: 13, color: theme.colors.mutedForeground)),
                          const SizedBox(height: 16),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: MobileScanner(
                                    onDetect: (capture) {
                                      final List<Barcode> barcodes = capture.barcodes;
                                      if (barcodes.isNotEmpty) {
                                        final String? code = barcodes.first.rawValue;
                                        if (code != null && _isScanning) {
                                          setState(() {
                                            _isScanning = false;
                                            _qrController.text = code;
                                          });
                                          showFToast(context: context, title: const Text('QR Code Terdeteksi!'));
                                          _submitPresensi();
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Stack(
                                      children: [
                                        _ScanAnimationLine(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FButton(
                            variant: FButtonVariant.outline,
                            onPress: () => setState(() => _isScanning = false),
                            child: const Text('Masukkan Token Manual'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
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
                          Text('Kirim Token Presensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colors.foreground)),
                          const SizedBox(height: 8),
                          Text('Masukkan token QR secara manual di bawah ini.', style: TextStyle(fontSize: 13, color: theme.colors.mutedForeground)),
                          const SizedBox(height: 12),
                          FTextField(
                            hint: 'Masukkan Token QR...',
                            control: FTextFieldControl.managed(controller: _qrController),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: FButton(
                                  variant: FButtonVariant.outline,
                                  onPress: () => setState(() => _isScanning = true),
                                  child: const Text('Kembali ke Scan'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FButton(
                                  onPress: _submitPresensi,
                                  child: const Text('Kirim Presensi'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ScanAnimationLine extends StatefulWidget {
  const _ScanAnimationLine();
  @override
  State<_ScanAnimationLine> createState() => _ScanAnimationLineState();
}

class _ScanAnimationLineState extends State<_ScanAnimationLine> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, _animController.value * 2 - 1),
          child: Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
