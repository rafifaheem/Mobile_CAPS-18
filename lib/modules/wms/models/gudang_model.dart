class Gudang {
  final int? idGudang;
  final String namaGudang;
  final int jumlah;
  final String alamat;
  final int idStatusGudang;
  final String? namaStatus;
  final int dibuatOleh;
  final DateTime? dibuatPada;
  final int diubahOleh;
  final DateTime? diubahPada;

  Gudang({
    this.idGudang,
    required this.namaGudang,
    this.jumlah = 0,
    required this.alamat,
    this.idStatusGudang = 1,
    this.namaStatus,
    this.dibuatOleh = 1,
    this.dibuatPada,
    this.diubahOleh = 1,
    this.diubahPada,
  });

  factory Gudang.fromJson(Map<String, dynamic> json) {
    return Gudang(
      idGudang: json['id_gudang'],
      namaGudang: json['nama_gudang'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      alamat: json['alamat'] ?? '',
      idStatusGudang: json['id_statusgudang'] ?? 1,
      namaStatus: json['nama_status'],
      dibuatOleh: json['dibuat_oleh'] ?? 1,
      dibuatPada: json['dibuat_pada'] != null ? DateTime.parse(json['dibuat_pada']) : null,
      diubahOleh: json['diubah_oleh'] ?? 1,
      diubahPada: json['diubah_pada'] != null ? DateTime.parse(json['diubah_pada']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_gudang': namaGudang,
      'jumlah': jumlah,
      'alamat': alamat,
      'id_statusgudang': idStatusGudang,
      'dibuat_oleh': dibuatOleh,
      'diubah_oleh': diubahOleh,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gudang && other.idGudang == idGudang;
  }

  @override
  int get hashCode => idGudang.hashCode;
}