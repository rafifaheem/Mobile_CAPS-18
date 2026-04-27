enum StatusPengajuan {
  pending,
  diterima,
  ditolak,
  terverifikasiSesuai,
  terverifikasiTidakSesuai,
}

class PenitipanBarang {
  final String id;
  final String namaBarang;
  final int jumlahEkspektasi;
  final String jenisBarang;
  final String klasifikasi;
  final DateTime periodeAwal;
  final DateTime periodeAkhir;
  final String namaCustomer;
  final String kontakCustomer;
  final double tarifPerHari;
  final double biayaHandling;
  final double biayaAdministrasi;
  final DateTime tanggalPengajuan;
  StatusPengajuan statusPengajuan;
  String? keteranganPenolakan;
  String? nomorResi;
  int? jumlahAktual;
  String? kondisiVerifikasi;
  String? keteranganVerifikasi;
  String? namaPetugas;

  PenitipanBarang({
    required this.id,
    required this.namaBarang,
    required this.jumlahEkspektasi,
    required this.jenisBarang,
    required this.klasifikasi,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.namaCustomer,
    required this.kontakCustomer,
    required this.tarifPerHari,
    required this.biayaHandling,
    required this.biayaAdministrasi,
    required this.tanggalPengajuan,
    this.statusPengajuan = StatusPengajuan.pending,
    this.keteranganPenolakan,
    this.nomorResi,
    this.jumlahAktual,
    this.kondisiVerifikasi,
    this.keteranganVerifikasi,
    this.namaPetugas,
  });

  int get totalHari => periodeAkhir.difference(periodeAwal).inDays;
  double get biayaPenitipan => tarifPerHari * totalHari;
  double get totalBiaya => biayaPenitipan + biayaHandling + biayaAdministrasi;

  String get statusLabel {
    switch (statusPengajuan) {
      case StatusPengajuan.pending:
        return 'Menunggu Seleksi';
      case StatusPengajuan.diterima:
        return 'Diterima';
      case StatusPengajuan.ditolak:
        return 'Ditolak';
      case StatusPengajuan.terverifikasiSesuai:
        return 'Sesuai';
      case StatusPengajuan.terverifikasiTidakSesuai:
        return 'Tidak Sesuai';
    }
  }
}

List<PenitipanBarang> mockPengajuanList = [
  PenitipanBarang(
    id: 'PNT-2024-001',
    namaBarang: 'Elektronik Consumer — Laptop & Aksesoris',
    jumlahEkspektasi: 50,
    jenisBarang: 'Elektronik',
    klasifikasi: 'Barang Berharga',
    periodeAwal: DateTime(2024, 10, 24),
    periodeAkhir: DateTime(2024, 12, 24),
    namaCustomer: 'PT Maju Bersama Teknologi',
    kontakCustomer: '+62 812-3456-7890',
    tarifPerHari: 15000,
    biayaHandling: 250000,
    biayaAdministrasi: 100000,
    tanggalPengajuan: DateTime(2024, 10, 20),
    statusPengajuan: StatusPengajuan.diterima,
  ),
  PenitipanBarang(
    id: 'PNT-2024-002',
    namaBarang: 'Furniture Kantor — Meja & Kursi',
    jumlahEkspektasi: 20,
    jenisBarang: 'Furniture',
    klasifikasi: 'Barang Umum',
    periodeAwal: DateTime(2024, 10, 25),
    periodeAkhir: DateTime(2025, 1, 25),
    namaCustomer: 'CV Sejahtera Mandiri',
    kontakCustomer: '+62 821-9876-5432',
    tarifPerHari: 8000,
    biayaHandling: 150000,
    biayaAdministrasi: 75000,
    tanggalPengajuan: DateTime(2024, 10, 22),
    statusPengajuan: StatusPengajuan.pending,
  ),
  PenitipanBarang(
    id: 'PNT-2024-003',
    namaBarang: 'Dokumen Arsip Perusahaan',
    jumlahEkspektasi: 100,
    jenisBarang: 'Dokumen',
    klasifikasi: 'Dokumen Sensitif',
    periodeAwal: DateTime(2024, 10, 26),
    periodeAkhir: DateTime(2025, 4, 26),
    namaCustomer: 'PT Griya Konstruksi Indonesia',
    kontakCustomer: '+62 811-5544-3322',
    tarifPerHari: 5000,
    biayaHandling: 200000,
    biayaAdministrasi: 100000,
    tanggalPengajuan: DateTime(2024, 10, 23),
    statusPengajuan: StatusPengajuan.ditolak,
    keteranganPenolakan:
        'Kapasitas gudang dokumen sensitif sudah penuh. Silakan ajukan kembali pada bulan November.',
  ),
  PenitipanBarang(
    id: 'PNT-2024-004',
    namaBarang: 'Spare Part Mesin Industri',
    jumlahEkspektasi: 35,
    jenisBarang: 'Suku Cadang',
    klasifikasi: 'Barang Industri',
    periodeAwal: DateTime(2024, 10, 28),
    periodeAkhir: DateTime(2024, 11, 28),
    namaCustomer: 'UD Teknik Jaya Abadi',
    kontakCustomer: '+62 856-7788-9900',
    tarifPerHari: 12000,
    biayaHandling: 300000,
    biayaAdministrasi: 100000,
    tanggalPengajuan: DateTime(2024, 10, 24),
    statusPengajuan: StatusPengajuan.terverifikasiSesuai,
    nomorResi: 'RG-2024-0041',
    jumlahAktual: 35,
    kondisiVerifikasi: 'sesuai',
    namaPetugas: 'Budi Santoso',
  ),
  PenitipanBarang(
    id: 'PNT-2024-005',
    namaBarang: 'Bahan Baku Tekstil — Kain Roll',
    jumlahEkspektasi: 80,
    jenisBarang: 'Tekstil',
    klasifikasi: 'Barang Umum',
    periodeAwal: DateTime(2024, 10, 29),
    periodeAkhir: DateTime(2025, 2, 28),
    namaCustomer: 'PT Fashion Nusantara',
    kontakCustomer: '+62 878-1122-3344',
    tarifPerHari: 6000,
    biayaHandling: 180000,
    biayaAdministrasi: 75000,
    tanggalPengajuan: DateTime(2024, 10, 25),
    statusPengajuan: StatusPengajuan.pending,
  ),
];
