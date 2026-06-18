import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class KotakKameraPemindai extends StatelessWidget {
  const KotakKameraPemindai({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FIcons.camera, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              'Arahkan kamera ke QR Code',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
