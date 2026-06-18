import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class PengajuanIzin extends StatefulWidget {
  const PengajuanIzin({super.key});

  @override
  State<PengajuanIzin> createState() => _PengajuanIzinState();
}

class _PengajuanIzinState extends State<PengajuanIzin> {
  final _keteranganController = TextEditingController();
  String? _jenisIzin = 'Sakit';

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(title: Text('Pengajuan Izin')),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FCard(
              title: const Text('Form Izin / Sakit'),
              subtitle: const Text('Silakan lengkapi alasan ketidakhadiran.'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FSelect<String>.rich(
                    label: const Text('Jenis Izin'),
                    hint: 'Pilih Jenis',
                    format: (value) => value,
                    control: FSelectControl.lifted(
                      value: _jenisIzin,
                      onChange: (v) => setState(() => _jenisIzin = v),
                    ),
                    children: [
                      .item(title: const Text('Sakit'), value: 'Sakit'),
                      .item(
                        title: const Text('Izin Keluarga'),
                        value: 'Izin Keluarga',
                      ),
                      .item(title: const Text('Lainnya'), value: 'Lainnya'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FTextField(
                    label: const Text('Keterangan'),
                    hint: 'Tuliskan detail alasan...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lampiran Foto (Opsional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FTappable(
                    onPress: () => showFToast(
                      context: context,
                      title: const Text('Membuka Galeri...'),
                    ),
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FIcons.image, color: Colors.grey),
                            Text(
                              'Klik untuk Unggah',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FButton(
              onPress: () {
                showFToast(
                  context: context,
                  title: const Text('Izin Berhasil Diajukan'),
                );
                Navigator.pop(context);
              },
              child: const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }
}
