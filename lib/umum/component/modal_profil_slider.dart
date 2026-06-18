import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class ModalProfilSlider extends StatefulWidget {
  final String nama;
  final String identitas;
  final String peran;

  const ModalProfilSlider({
    super.key,
    required this.nama,
    required this.identitas,
    required this.peran,
  });

  @override
  State<ModalProfilSlider> createState() => _ModalProfilSliderState();
}

class _ModalProfilSliderState extends State<ModalProfilSlider> {
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;
    final modalBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final inputBgColor = isDarkMode ? const Color(0xFF0F172A) : Colors.transparent;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: modalBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Profil Pengguna',
                style: theme.typography.xl2.copyWith(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : theme.colors.foreground),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF0F172A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isDarkMode ? null : Border.all(color: theme.colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : theme.colors.foreground)),
                    const SizedBox(height: 4),
                    Text('${widget.identitas} • ${widget.peran}', style: TextStyle(color: isDarkMode ? Colors.white70 : theme.colors.mutedForeground)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ubah Kata Sandi',
                style: theme.typography.md.copyWith(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : theme.colors.foreground),
              ),
              const SizedBox(height: 16),
              Theme(
                data: ThemeData(
                  inputDecorationTheme: InputDecorationTheme(
                    fillColor: inputBgColor,
                    filled: isDarkMode,
                  ),
                ),
                child: Column(
                  children: [
                    FTextField.password(
                      label: Text('Kata Sandi Lama', style: TextStyle(color: isDarkMode ? Colors.white70 : theme.colors.foreground)),
                      hint: 'Masukkan sandi lama',
                      control: FTextFieldControl.managed(controller: _passwordLamaController),
                    ),
                    const SizedBox(height: 12),
                    FTextField.password(
                      label: Text('Kata Sandi Baru', style: TextStyle(color: isDarkMode ? Colors.white70 : theme.colors.foreground)),
                      hint: 'Masukkan sandi baru',
                      control: FTextFieldControl.managed(controller: _passwordBaruController),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FButton(
                onPress: () {
                  showFToast(context: context, title: const Text('Kata Sandi Berhasil Diperbarui'));
                  Navigator.pop(context);
                },
                child: const Text('Simpan Perubahan'),
              ),
              const SizedBox(height: 12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                child: const Text('Keluar Aplikasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
