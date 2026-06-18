import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class KartuRiwayat extends StatelessWidget {
  final String matakuliah;
  final String tanggal;
  final String status;
  final bool isHadir;

  const KartuRiwayat({
    super.key,
    required this.matakuliah,
    required this.tanggal,
    required this.status,
    required this.isHadir,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      title: Text(matakuliah),
      subtitle: Text(tanggal),
      child: Align(
        alignment: Alignment.centerRight,
        child: FBadge(
          variant: isHadir ? FBadgeVariant.outline : FBadgeVariant.destructive,
          child: Text(status),
        ),
      ),
    );
  }
}
