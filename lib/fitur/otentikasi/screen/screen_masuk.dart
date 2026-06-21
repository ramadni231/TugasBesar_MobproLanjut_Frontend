import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugas_besar/fitur/otentikasi/controller/otentikasi_controller.dart';
import 'package:tugas_besar/fitur/otentikasi/component/formulir_masuk.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

class ScreenMasuk extends StatefulWidget {
  const ScreenMasuk({super.key});

  @override
  State<ScreenMasuk> createState() => _ScreenMasukState();
}

class _ScreenMasukState extends State<ScreenMasuk> {
  final _kontrolerTema = KontrolerTema();

  @override
  void initState() {
    super.initState();
    _kontrolerTema.addListener(() => setState(() {}));
  }

  void _tampilkanModalOtentikasi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalOtentikasi(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Gambar Full
          Positioned.fill(
            child: Image.asset(
              'lib/umum/component/img/onboard.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay Gradient agar teks terbaca
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Tema di pojok kanan atas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton.icon(
                        variant: FButtonVariant.ghost,
                        onPress: () => _kontrolerTema.toggleTheme(),
                        child: Icon(
                          _kontrolerTema.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Teks Sambutan
                  const Text(
                    'Selamat Datang di\nMy Presensiku',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Silakan masuk ke akun Anda',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Buka Modal
                  SizedBox(
                    width: double.infinity,
                    child: FButton(
                      onPress: () => _tampilkanModalOtentikasi(context),
                      child: const Text('Mulai Sekarang'),
                    ),
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

class ModalOtentikasi extends StatefulWidget {
  const ModalOtentikasi({super.key});

  @override
  State<ModalOtentikasi> createState() => _ModalOtentikasiState();
}

class _ModalOtentikasiState extends State<ModalOtentikasi> {
  final _controller = OtentikasiController();
  final _identitasController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _identitasController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = FTheme.of(context);
    final isDarkMode = KontrolerTema().isDarkMode;
    final theme = isDarkMode
        ? parentTheme.copyWith(
            colors: parentTheme.colors.copyWith(
              background: const Color(0xFF0F172A), // navyGelap untuk input
              card: const Color(0xFF1E293B), // navyTerang untuk modal bg
            ),
          )
        : parentTheme;

    return FTheme(
      data: theme,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle Slider
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
                  'Masuk ke Akun',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk untuk melanjutkan',
                  style: TextStyle(color: theme.colors.mutedForeground),
                ),
                const SizedBox(height: 24),

                FormulirMasuk(
                  identitasController: _identitasController,
                  passwordController: _passwordController,
                ),

                const SizedBox(height: 24),
                FButton(
                  onPress: _controller.sedangLoading ? null : _handleLogin,
                  child: Text(
                    _controller.sedangLoading
                        ? 'MEMPROSES...'
                        : 'MASUK SEKARANG',
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final peran = await _controller.login(
      _identitasController.text,
      _passwordController.text,
    );
    
    if (!mounted) return;

    if (peran != null) {
      Navigator.pop(context); // Tutup modal
      // Arahkan sesuai peran dari database API
      Navigator.of(context).pushReplacementNamed('/$peran');
    } else {
      showFToast(
        context: context,
        title: const Text('Login Gagal. Identitas atau Sandi salah.'),
        variant: FToastVariant.destructive,
      );
    }
  }
}
