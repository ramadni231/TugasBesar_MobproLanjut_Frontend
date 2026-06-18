class Ruangan {
  final int id;
  final String namaRuangan;
  final int kapasitas;
  final double latitude;
  final double longitude;
  final int radiusMeter;

  Ruangan({
    required this.id,
    required this.namaRuangan,
    required this.kapasitas,
    required this.latitude,
    required this.longitude,
    required this.radiusMeter,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'],
      namaRuangan: json['nama_ruangan'],
      kapasitas: json['kapasitas'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radiusMeter: json['radius_meter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_ruangan': namaRuangan,
      'kapasitas': kapasitas,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meter': radiusMeter,
    };
  }
}
