class Matakuliah {
  final int id;
  final String kodeMatkul;
  final String namaMatkul;
  final int sks;
  final int semester;

  Matakuliah({
    required this.id,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.sks,
    required this.semester,
  });

  factory Matakuliah.fromJson(Map<String, dynamic> json) {
    return Matakuliah(
      id: json['id'],
      kodeMatkul: json['kode_matkul'],
      namaMatkul: json['nama_matkul'],
      sks: json['sks'],
      semester: json['semester'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_matkul': kodeMatkul,
      'nama_matkul': namaMatkul,
      'sks': sks,
      'semester': semester,
    };
  }
}
