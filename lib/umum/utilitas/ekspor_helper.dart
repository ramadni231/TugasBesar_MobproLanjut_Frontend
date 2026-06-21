import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:forui/forui.dart';

class EksporHelper {
  static Future<void> eksporKeCSV({
    required BuildContext context,
    required String namaFile,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    try {
      // 1. Generate CSV String
      final csvBuffer = StringBuffer();
      
      // Write headers
      csvBuffer.writeln(headers.map((h) => '"${h.replaceAll('"', '""')}"').join(','));

      // Write rows
      for (final row in rows) {
        csvBuffer.writeln(row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','));
      }

      // 2. Write to a temporary file
      final tempDir = await getTemporaryDirectory();
      final sanitizedFileName = namaFile.replaceAll(RegExp(r'[^\w\s\-\.]'), '_').replaceAll(' ', '_');
      final file = File('${tempDir.path}/$sanitizedFileName.csv');
      await file.writeAsString(csvBuffer.toString());

      // 3. Share the file
      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null 
            ? box.localToGlobal(Offset.zero) & box.size 
            : null;

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'text/csv')],
            text: 'Ekspor Data $namaFile',
            sharePositionOrigin: sharePositionOrigin,
          ),
        );

        if (context.mounted) {
          showFToast(
            context: context,
            title: Text('Berhasil mengekspor $namaFile'),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showFToast(
          context: context,
          title: Text('Gagal mengekspor data: $e'),
          variant: FToastVariant.destructive,
        );
      }
    }
  }
}
