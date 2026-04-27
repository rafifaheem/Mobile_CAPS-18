class Driver {
  final int idDriver;
  final String nama;
  final String noSim;
  final String noHp;
  final String email;
  final String status;
  final DateTime wktDaftar;
  final String? kota;
  final String alamat;
  final DateTime ttl;
  final String nik;
  final String jenisSim;
  final DateTime? tanggalKedaluarsaSim;
  final String noBpjs;
  final DateTime? tanggalKedaluarsaBpjs;
  final String? noSertifikat;
  final DateTime? tanggalKedaluarsaSertifikat;
  final String namaKontakDarurat;
  final String nomorKontakDarurat;
  final String hubunganKontakDarurat;
  final String? fotoKtp;
  final String? fotoSim;
  final String? fotoProfil;
  final String? fotoSertifikat;
  final String? fotoBpjs;
  final String? namaBank;
  final String? nomorRekening;
  final String? alasanPenolakan;

  Driver({
    required this.idDriver,
    required this.nama,
    required this.noSim,
    required this.noHp,
    required this.email,
    required this.status,
    required this.wktDaftar,
    this.kota,
    required this.alamat,
    required this.ttl,
    required this.nik,
    required this.jenisSim,
    this.tanggalKedaluarsaSim,
    required this.noBpjs,
    this.tanggalKedaluarsaBpjs,
    this.noSertifikat,
    this.tanggalKedaluarsaSertifikat,
    required this.namaKontakDarurat,
    required this.nomorKontakDarurat,
    required this.hubunganKontakDarurat,
    this.fotoKtp,
    this.fotoSim,
    this.fotoProfil,
    this.fotoSertifikat,
    this.fotoBpjs,
    this.namaBank,
    this.nomorRekening,
    this.alasanPenolakan,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      idDriver: json['id'] ?? json['id_driver'] ?? 0,
      nama: json['nama_lengkap'] ?? json['nama'] ?? json['name'] ?? '',
      noSim: json['no_sim'] ?? json['license_number'] ?? '',
      noHp: json['no_telepon'] ?? json['no_hp'] ?? json['phone'] ?? '',
      email: json['user']?['email'] ?? json['email'] ?? '',
      status: json['status'] ?? 'PENDING',
      wktDaftar: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['wkt_daftar'] != null ? DateTime.parse(json['wkt_daftar']) : DateTime.now()),
      kota: json['kota'],
      alamat: json['alamat'] ?? json['address'] ?? '',
      ttl: json['ttl'] != null ? DateTime.parse(json['ttl']) : DateTime.now(),
      nik: json['no_ktp'] ?? json['nik'] ?? '',
      jenisSim: json['jenis_sim'] ?? 'A',
      tanggalKedaluarsaSim: json['tanggal_kedaluarsa_sim'] != null 
          ? DateTime.parse(json['tanggal_kedaluarsa_sim']) : null,
      noBpjs: json['no_bpjs'] ?? '',
      tanggalKedaluarsaBpjs: json['tanggal_kedaluarsa_bpjs'] != null 
          ? DateTime.parse(json['tanggal_kedaluarsa_bpjs']) : null,
      noSertifikat: json['no_sertifikat'],
      tanggalKedaluarsaSertifikat: json['tanggal_kedaluarsa_sertifikat'] != null 
          ? DateTime.parse(json['tanggal_kedaluarsa_sertifikat']) : null,
      namaKontakDarurat: json['nama_kontak_darurat'] ?? '',
      nomorKontakDarurat: json['nomor_kontak_darurat'] ?? '',
      hubunganKontakDarurat: json['hubungan_kontak_darurat'] ?? '',
      fotoKtp: json['foto_ktp'],
      fotoSim: json['foto_sim'],
      fotoProfil: json['foto_profil'],
      fotoSertifikat: json['foto_sertifikat'],
      fotoBpjs: json['foto_bpjs'],
      namaBank: json['nama_bank'],
      nomorRekening: json['nomor_rekening'],
      alasanPenolakan: json['alasan_penolakan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_lengkap': nama,
      'no_telepon': noHp,
      'alamat': alamat,
      'no_ktp': nik,
      'kota': kota,
      'status': status,
      'no_sim': noSim,
      'jenis_sim': jenisSim,
      'tanggal_kedaluarsa_sim': tanggalKedaluarsaSim?.toIso8601String().split('T')[0],
      'no_bpjs': noBpjs,
      'tanggal_kedaluarsa_bpjs': tanggalKedaluarsaBpjs?.toIso8601String().split('T')[0],
      'no_sertifikat': noSertifikat,
      'tanggal_kedaluarsa_sertifikat': tanggalKedaluarsaSertifikat?.toIso8601String().split('T')[0],
      'nama_kontak_darurat': namaKontakDarurat,
      'nomor_kontak_darurat': nomorKontakDarurat,
      'hubungan_kontak_darurat': hubunganKontakDarurat,
      'foto_ktp': fotoKtp,
      'foto_sim': fotoSim,
      'foto_profil': fotoProfil,
      'foto_sertifikat': fotoSertifikat,
      'foto_bpjs': fotoBpjs,
      'nama_bank': namaBank,
      'nomor_rekening': nomorRekening,
    };
  }

  // Legacy compatibility getters
  int get id => idDriver;
  String get name => nama;
  String get licenseNumber => noSim;
  String get phone => noHp;
  DateTime get createdAt => wktDaftar;
}