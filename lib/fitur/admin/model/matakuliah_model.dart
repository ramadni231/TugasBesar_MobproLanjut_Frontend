class Matakuliah {
  final int id;
  final String kodeMatkul;
  final String namaMatkul;
  final int sks;

  Matakuliah({
    required this.id,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.sks,
  });

  factory Matakuliah.fromJson(Map<String, dynamic> json) {
    return Matakuliah(
      id: json['id'],
      kodeMatkul: json['kode_matkul'],
      namaMatkul: json['nama_matkul'],
      sks: json['sks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_matkul': kodeMatkul,
      'nama_matkul': namaMatkul,
      'sks': sks,
    };
  }
}
