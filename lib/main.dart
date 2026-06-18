import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tugas_besar/inti/tema/tema_aplikasi.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';
import 'package:tugas_besar/inti/rute/rute_aplikasi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final KontrolerTema _kontrolerTema = KontrolerTema();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kontrolerTema,
      builder: (context, child) {
        final theme = _kontrolerTema.isDarkMode
            ? TemaAplikasi.dark()
            : TemaAplikasi.light();
        return MaterialApp(
          title: 'Sistem Presensi Mahasiswa',
          themeMode: _kontrolerTema.themeMode,
          theme: theme.toApproximateMaterialTheme(),
          builder: (context, child) => FTheme(
            data: theme,
            child: FToaster(child: FTooltipGroup(child: child!)),
          ),
          initialRoute: RuteAplikasi.masuk,
          routes: RuteAplikasi.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
