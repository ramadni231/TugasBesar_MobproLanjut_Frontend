import 'package:flutter/material.dart';
import 'package:tugas_besar/inti/tema/kontroler_tema.dart';

PreferredSizeWidget buatAppBar({
  required BuildContext context,
  required String judul,
  List<Widget>? actions,
  Widget? leading,
  Color? warnaKontras,
}) {
  final isDarkMode = KontrolerTema().isDarkMode;
  final finalColor = warnaKontras ?? (isDarkMode ? Colors.white : Colors.black87);
  return AppBar(
    leading: leading,
    title: Text(judul),
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: finalColor),
    actions: actions,
    titleTextStyle: TextStyle(
      color: finalColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );
}
