import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/mahasiswa/controller/mahasiswa_controller.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class KeranjangPeminatan extends StatefulWidget {
  const KeranjangPeminatan({super.key});

  @override
  State<KeranjangPeminatan> createState() => _KeranjangPeminatanState();
}

class _KeranjangPeminatanState extends State<KeranjangPeminatan> {
  final _controller = MahasiswaController();
  List<Map<String, dynamic>> _keranjang = [];
  bool _sedangLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _sedangLoading = true);
    final data = await _controller.fetchKeranjangPeminatan();
    if (mounted) {
      setState(() {
        _keranjang = data;
        _sedangLoading = false;
      });
    }
  }

  Future<void> _batalPeminatan(int id) async {
    final sukses = await _controller.batalPeminatan(id);
    if (sukses && mounted) {
      showFToast(context: context, title: const Text('Peminatan dibatalkan'));
      _loadData();
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
        judul: 'Keranjang Peminatan',
      ),
      body: _sedangLoading
          ? const Center(child: CircularProgressIndicator())
          : _keranjang.isEmpty
              ? const Center(child: Text('Belum ada matakuliah yang diajukan atau sudah diproses Admin.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _keranjang.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _keranjang[index];
                    final matkul = item['matakuliah']['nama_matkul'];
                    final kode = item['matakuliah']['kode_matkul'];
                    final sks = item['matakuliah']['sks'];
                    
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
                              '$kode - $matkul',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'SKS: $sks',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FBadge(
                                  child: Text(item['status'].toString().toUpperCase()),
                                ),
                                FButton(
                                  variant: FButtonVariant.destructive,
                                  size: FButtonSizeVariant.sm,
                                  onPress: () => _batalPeminatan(item['id']),
                                  child: const Text('Batal'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
