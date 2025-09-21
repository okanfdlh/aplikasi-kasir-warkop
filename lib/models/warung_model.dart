class Warung {
  final int id;
  final String namaWarung;
  final String alamat;
  final String nomorTelepon;
  final String? gambarWarung;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Warung({
    required this.id,
    required this.namaWarung,
    required this.alamat,
    required this.nomorTelepon,
    this.gambarWarung,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Warung.fromJson(Map<String, dynamic> json) {
    return Warung(
      id: json['id'] ?? 0,
      namaWarung: json['nama_warung'] ?? '',
      alamat: json['alamat'] ?? '',
      nomorTelepon: json['nomor_telepon'] ?? '',
      gambarWarung: json['gambar_warung'],
      userId: json['user_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_warung': namaWarung,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
      'gambar_warung': gambarWarung,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
