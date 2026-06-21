import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/fitur/mahasiswa/screen/keranjang_peminatan.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class PeminatanMatakuliah extends StatefulWidget {
  const PeminatanMatakuliah({super.key});

  @override
  State<PeminatanMatakuliah> createState() => _PeminatanMatakuliahState();
}

class _PeminatanMatakuliahState extends State<PeminatanMatakuliah> {
  final _controller = MahasiswaController();
  final _semesterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _semesterController.dispose();
    super.dispose();
  }

  void _loadData() {
    int? semester = int.tryParse(_semesterController.text);
    _controller.fetchMatakuliahPeminatan(semester);
  }

  void _submitPeminatan(int matakuliahId) async {
    final sukses = await _controller.ajukanPeminatan(matakuliahId);
    if (!mounted) return;

    if (sukses) {
      showFToast(context: context, title: const Text('Berhasil diajukan'));
    } else {
      showFToast(
        context: context, 
        title: const Text('Gagal. Sudah dipilih atau masa peminatan tutup.'),
        variant: FToastVariant.destructive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Peminatan Matakuliah',
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KeranjangPeminatan()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FTextField(
                    label: const Text('Filter Semester'),
                    hint: 'Masukkan angka (misal: 3)',
                    keyboardType: TextInputType.number,
                    control: FTextFieldControl.managed(controller: _semesterController),
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: FButton(
                    onPress: _loadData,
                    child: const Text('Cari'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _controller.sedangLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _controller.matakuliahPeminatan.isEmpty
                      ? const Center(child: Text('Data tidak ditemukan atau sesi tutup.'))
                      : ListView.separated(
                          itemCount: _controller.matakuliahPeminatan.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final matkul = _controller.matakuliahPeminatan[index];
                            return Card(
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
                                      matkul.namaMatkul,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kode: ${matkul.kodeMatkul} • SKS: ${matkul.sks}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FButton(
                                        size: FButtonSizeVariant.sm,
                                        onPress: () => _submitPeminatan(matkul.id),
                                        child: const Text('Ambil'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
