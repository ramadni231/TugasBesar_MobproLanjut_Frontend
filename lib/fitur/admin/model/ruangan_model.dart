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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      namaRuangan: json['nama_ruangan']?.toString() ?? '',
      kapasitas: json['kapasitas'] is int ? json['kapasitas'] : int.parse(json['kapasitas'].toString()),
      latitude: json['latitude'] is double 
          ? json['latitude'] 
          : (json['latitude'] is int 
              ? (json['latitude'] as int).toDouble() 
              : double.parse(json['latitude']?.toString() ?? '0.0')),
      longitude: json['longitude'] is double 
          ? json['longitude'] 
          : (json['longitude'] is int 
              ? (json['longitude'] as int).toDouble() 
              : double.parse(json['longitude']?.toString() ?? '0.0')),
      radiusMeter: json['radius_meter'] is int ? json['radius_meter'] : int.parse(json['radius_meter'].toString()),
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
