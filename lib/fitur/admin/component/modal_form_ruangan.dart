import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tugas_besar/fitur/admin/model/ruangan_model.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class ModalFormRuangan extends StatefulWidget {
  final Ruangan? ruangan; // if null, then it's for 'Tambah'
  final Function(Map<String, dynamic>) onSubmit;

  const ModalFormRuangan({super.key, this.ruangan, required this.onSubmit});

  @override
  State<ModalFormRuangan> createState() => _ModalFormRuanganState();
}

class _ModalFormRuanganState extends State<ModalFormRuangan> {
  final _namaController = TextEditingController();
  final _kapasitasController = TextEditingController();

  double _latitude = -7.4243;
  double _longitude = 109.2302;
  double _radius = 50.0;
  bool _loadingGPS = false;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.ruangan != null) {
      _namaController.text = widget.ruangan!.namaRuangan;
      _kapasitasController.text = widget.ruangan!.kapasitas.toString();
      _latitude = widget.ruangan!.latitude;
      _longitude = widget.ruangan!.longitude;
      _radius = widget.ruangan!.radiusMeter.toDouble();
    } else {
      _loadCurrentLocation();
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _loadingGPS = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showFToast(
            context: context,
            title: const Text('Layanan lokasi (GPS) dinonaktifkan di perangkat Anda.'),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            showFToast(
              context: context,
              title: const Text('Izin akses lokasi ditolak oleh pengguna.'),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showFToast(
            context: context,
            title: const Text('Izin lokasi ditolak permanen, harap aktifkan di pengaturan.'),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(LatLng(_latitude, _longitude), 16.0);
        } catch (e) {
          debugPrint('MapController move error: $e');
        }
      });

      if (mounted) {
        showFToast(
          context: context,
          title: const Text('Lokasi berhasil diperbarui dari GPS.'),
        );
      }
    } catch (e) {
      debugPrint('Error loading GPS: $e');
      if (mounted) {
        showFToast(
          context: context,
          title: Text('Gagal mengambil lokasi GPS: $e'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingGPS = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kapasitasController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_namaController.text.isEmpty) {
      showFToast(context: context, title: const Text('Nama ruangan tidak boleh kosong'));
      return;
    }
    final data = {
      'nama_ruangan': _namaController.text,
      'kapasitas': int.tryParse(_kapasitasController.text) ?? 30,
      'latitude': _latitude,
      'longitude': _longitude,
      'radius_meter': _radius.toInt(),
    };
    widget.onSubmit(data);
    Navigator.pop(context);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hint,
  }) {
    final isDarkMode = KontrolerTema().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = KontrolerTema().isDarkMode;
    final modalBgColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: modalBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.ruangan == null ? 'Tambah Ruangan' : 'Ubah Ruangan',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Colors.black54),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildField(
                    label: 'Nama Ruangan',
                    controller: _namaController,
                    hint: 'Misal: Lab Komputer 1',
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Kapasitas',
                    controller: _kapasitasController,
                    keyboardType: TextInputType.number,
                    hint: 'Misal: 30',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Lokasi & Radius (OSM)',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextButton.icon(
                        icon: _loadingGPS
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              )
                            : const Icon(Icons.my_location, size: 16, color: Colors.blue),
                        label: const Text(
                          'Lokasi Saat Ini',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                        onPressed: _loadCurrentLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Map display
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(_latitude, _longitude),
                        initialZoom: 16.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _latitude = point.latitude;
                            _longitude = point.longitude;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tugas_besar.app',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(_latitude, _longitude),
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderStrokeWidth: 2,
                              borderColor: Colors.blue,
                              useRadiusInMeter: true,
                              radius: _radius,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_latitude, _longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Koordinat: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  
                  // Radius selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Radius Toleransi',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_radius.toInt()} meter',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setState(() {
                        _radius = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  FButton(
                    onPress: _submit,
                    child: const Text('Simpan Ruangan'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
