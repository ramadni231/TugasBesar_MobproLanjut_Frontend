import 'dart:math';

class UtilitasDummy {
  static String generateId() {
    return Random().nextInt(1000000).toString().padLeft(6, '0');
  }

  static String formatTanggal(DateTime date) {
    return '${date.day} ${_getNamaBulan(date.month)} ${date.year}';
  }

  static String _getNamaBulan(int month) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return bulan[month - 1];
  }
}
