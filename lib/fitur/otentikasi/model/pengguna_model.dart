class Pengguna {
  final int id;
  final String nama;
  final String nomorIdentitas;
  final String email;
  final String peran;

  Pengguna({
    required this.id,
    required this.nama,
    required this.nomorIdentitas,
    required this.email,
    required this.peran,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'],
      nama: json['nama'],
      nomorIdentitas: json['nomor_identitas'],
      email: json['email'],
      peran: json['peran'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nomor_identitas': nomorIdentitas,
      'email': email,
      'peran': peran,
    };
  }
}
