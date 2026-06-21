import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/fitur/admin/controller/admin_controller.dart';
import 'package:tugas_besar/fitur/admin/model/matakuliah_model.dart';
import 'package:tugas_besar/fitur/admin/screen/kelola_peminatan.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/fitur/admin/component/modal_form_matkul.dart';
import 'package:tugas_besar/fitur/admin/component/dialog_konfirmasi.dart';
import 'package:tugas_besar/umum/component/custom_app_bar.dart';

class ManajemenMatkul extends StatefulWidget {
  const ManajemenMatkul({super.key});

  @override
  State<ManajemenMatkul> createState() => _ManajemenMatkulState();
}

class _ManajemenMatkulState extends State<ManajemenMatkul> {
  final _controller = AdminController();
  final _searchController = TextEditingController();
  
  List<Matakuliah> _matkul = [];
  List<Matakuliah> _filteredMatkul = [];
  bool _sedangLoading = true;
  bool _isMasaPeminatan = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterData);
  }

  Future<void> _loadInitialState() async {
    final status = await _controller.getPeminatanStatus();
    if (mounted) setState(() => _isMasaPeminatan = status);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _sedangLoading = true);
    await _loadInitialState();
    final data = await _controller.fetchMatakuliah();
    if (mounted) {
      setState(() {
        _matkul = data;
        _filteredMatkul = data;
        _sedangLoading = false;
      });
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMatkul = _matkul.where((m) {
        return m.namaMatkul.toLowerCase().contains(query) || 
               m.kodeMatkul.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _togglePeminatan() async {
    final newState = !_isMasaPeminatan;
    final sukses = await _controller.toggleMasaPeminatan(newState);
    if (sukses && mounted) {
      setState(() => _isMasaPeminatan = newState);
      showFToast(context: context, title: Text('Masa peminatan ${newState ? 'dibuka' : 'ditutup'}'));
    }
  }

  void _tambahMatkul() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormMatkul(
        onSubmit: (data) async {
          final success = await _controller.tambahMatakuliah(data);
          if (!mounted) return;
          if (success) {
            _loadData();
            showFToast(context: context, title: const Text('Matakuliah berhasil ditambahkan'));
          } else {
            showFToast(context: context, title: const Text('Gagal menambahkan matakuliah'));
          }
        },
      ),
    );
  }

  void _editMatkul(Matakuliah item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalFormMatkul(
        matkul: item,
        onSubmit: (data) async {
          final success = await _controller.updateMatakuliah(item.id, data);
          if (!mounted) return;
          if (success) {
            _loadData();
            showFToast(context: context, title: const Text('Matakuliah berhasil diperbarui'));
          } else {
            showFToast(context: context, title: const Text('Gagal memperbarui matakuliah'));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? theme.colors.background : Colors.white,
      appBar: buatAppBar(
        context: context,
        judul: 'Manajemen Mata Kuliah',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahMatkul,
          ),
        ],
      ),
      body: _sedangLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Action Bar: Toggle and Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Masa Peminatan: ', style: TextStyle(color: theme.colors.foreground, fontWeight: FontWeight.bold)),
                        Switch(
                          value: _isMasaPeminatan,
                          onChanged: (val) => _togglePeminatan(),
                          activeTrackColor: theme.colors.primary,
                        ),
                      ],
                    ),
                    FButton(
                      size: FButtonSizeVariant.sm,
                      onPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaPeminatan())),
                      child: const Text('Kelola Peminatan'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search Bar
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
                              hintText: 'Cari Kode atau Nama Matkul...',
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

                // List Matakuliah
                Expanded(
                  child: _filteredMatkul.isEmpty 
                    ? const Center(child: Text('Matakuliah tidak ditemukan.'))
                    : ListView.separated(
                        itemCount: _filteredMatkul.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filteredMatkul[index];
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
                                    item.namaMatkul,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kode: ${item.kodeMatkul} • SKS: ${item.sks} • Semester: ${item.semester}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FButton(
                                        variant: FButtonVariant.ghost,
                                        size: FButtonSizeVariant.sm,
                                        onPress: () => _editMatkul(item),
                                        child: const Icon(FIcons.pencil, size: 16),
                                      ),
                                      FButton(
                                        variant: FButtonVariant.ghost,
                                        size: FButtonSizeVariant.sm,
                                        onPress: () => tampilkanKonfirmasiHapus(
                                          context: context,
                                          item: item.namaMatkul,
                                          onHapus: () async {
                                            final success = await _controller.hapusMatakuliah(item.id);
                                            if (success) _loadData();
                                          },
                                        ),
                                        child: const Icon(FIcons.trash2, size: 16),
                                      ),
                                    ],
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
