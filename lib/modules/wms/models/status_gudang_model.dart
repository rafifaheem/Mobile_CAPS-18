class StatusGudang {
  final int id;
  final String nama;

  StatusGudang({
    required this.id,
    required this.nama,
  });

  factory StatusGudang.fromJson(Map<String, dynamic> json) {
    return StatusGudang(
      id: json['id_statusgudang'] ?? json['id'] ?? 0,
      nama: json['nama_status'] ?? json['nama'] ?? '',
    );
  }
}