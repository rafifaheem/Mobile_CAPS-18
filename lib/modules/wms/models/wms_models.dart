class Gudang {
  final int idGudang;
  final String namaGudang;
  final int jumlah;
  final String alamat;
  final int idStatusGudang;
  final int idTenant;
  final double latitude;
  final double longitude;
  final DateTime? dibuatPada;
  final DateTime? diubahPada;

  Gudang({
    required this.idGudang,
    required this.namaGudang,
    required this.jumlah,
    required this.alamat,
    required this.idStatusGudang,
    required this.idTenant,
    required this.latitude,
    required this.longitude,
    this.dibuatPada,
    this.diubahPada,
  });

  factory Gudang.fromJson(Map<String, dynamic> json) {
    return Gudang(
      idGudang: json['id_gudang'] ?? 0,
      namaGudang: json['nama_gudang'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      alamat: json['alamat'] ?? '',
      idStatusGudang: json['id_statusgudang'] ?? 0,
      idTenant: json['id_tenant'] ?? 0,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      dibuatPada: json['dibuat_pada'] != null && json['dibuat_pada'] != '0001-01-01T00:00:00Z' 
          ? DateTime.parse(json['dibuat_pada']) : null,
      diubahPada: json['diubah_pada'] != null && json['diubah_pada'] != '0001-01-01T00:00:00Z' 
          ? DateTime.parse(json['diubah_pada']) : null,
    );
  }
}

class Produk {
  final int idProduk;
  final String kodeProduk;
  final String namaProduk;
  final String barcodeProduk;
  final int idKategori;
  final int idSatuan;
  final int idMataUang;
  final int idTenant;
  final double harga;

  Produk({
    required this.idProduk,
    required this.kodeProduk,
    required this.namaProduk,
    required this.barcodeProduk,
    required this.idKategori,
    required this.idSatuan,
    required this.idMataUang,
    required this.idTenant,
    required this.harga,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      idProduk: json['id_produk'] ?? 0,
      kodeProduk: json['kode_produk'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      barcodeProduk: json['barcode_produk'] ?? '',
      idKategori: json['id_kategori'] ?? 0,
      idSatuan: json['id_satuan'] ?? 0,
      idMataUang: json['id_mata_uang'] ?? 0,
      idTenant: json['id_tenant'] ?? 0,
      harga: (json['harga'] ?? 0.0).toDouble(),
    );
  }
}


class PO {
  final String uuidOrder;
  final int idOrder;
  final double hargaTotal;
  final int? idGudang;
  final int? idVendor;
  final int? idGudangVendor;
  final Gudang? gudang;

  PO({
    required this.uuidOrder,
    required this.idOrder,
    required this.hargaTotal,
    this.idGudang,
    this.idVendor,
    this.idGudangVendor,
    this.gudang,
  });

  // Getter untuk kompatibilitas dengan kode lama
  int get idPO => idOrder;
  String get nomorPO => 'PO #$idOrder';
  DateTime? get tglPO => null; // Tidak ada di API response

  factory PO.fromJson(Map<String, dynamic> json) {
    return PO(
      uuidOrder: json['uuid_order'] ?? '',
      idOrder: json['id_order'] ?? 0,
      hargaTotal: (json['harga_total'] ?? 0).toDouble(),
      idGudang: json['id_gudang'],
      idVendor: json['id_vendor'],
      idGudangVendor: json['id_gudang_vendor'],
      gudang: json['gudang'] != null ? Gudang.fromJson(json['gudang']) : null,
    );
  }
}

class DetailPO {
  final int idDetailPO;
  final int idProduk;
  final int idSatuan;
  final int jumlah;
  final double harga;
  final Produk? produk;

  DetailPO({
    required this.idDetailPO,
    required this.idProduk,
    required this.idSatuan,
    required this.jumlah,
    required this.harga,
    this.produk,
  });

  factory DetailPO.fromJson(Map<String, dynamic> json) {
    return DetailPO(
      idDetailPO: json['id_detailpo'],
      idProduk: json['id_produk'],
      idSatuan: json['id_satuan'],
      jumlah: json['jumlah'],
      harga: (json['harga'] ?? 0).toDouble(),
      produk: json['produk'] != null ? Produk.fromJson(json['produk']) : null,
    );
  }
}

class QualityControl {
  final int idQC;
  final int idPO;
  final int idUser;
  final String catatan;
  final int idStatusQC;
  final DateTime dibuatPada;

  QualityControl({
    required this.idQC,
    required this.idPO,
    required this.idUser,
    required this.catatan,
    required this.idStatusQC,
    required this.dibuatPada,
  });

  factory QualityControl.fromJson(Map<String, dynamic> json) {
    return QualityControl(
      idQC: json['id_qc'],
      idPO: json['id_po'],
      idUser: json['id_user'],
      catatan: json['catatan'] ?? '',
      idStatusQC: json['id_status_qc'],
      dibuatPada: DateTime.parse(json['dibuat_pada']),
    );
  }
}

class DetailQC {
  final int idDetailQC;
  final String namaBarang;
  final String jumlahSample;
  final int idKriteriaProduk;
  final String hasilQC;
  final bool memenuhi;
  final DateTime tglCek;

  DetailQC({
    required this.idDetailQC,
    required this.namaBarang,
    required this.jumlahSample,
    required this.idKriteriaProduk,
    required this.hasilQC,
    required this.memenuhi,
    required this.tglCek,
  });

  factory DetailQC.fromJson(Map<String, dynamic> json) {
    return DetailQC(
      idDetailQC: json['id_detailqc'],
      namaBarang: json['nama_barang'] ?? '',
      jumlahSample: json['jumlah_sample'] ?? '',
      idKriteriaProduk: json['id_kriteria_produk'] ?? 0,
      hasilQC: json['hasil_qc'] ?? '',
      memenuhi: json['memenuhi'] ?? false,
      tglCek: DateTime.parse(json['tgl_cek']),
    );
  }
}

class Stok {
  final int idStok;
  final int idLokasi;
  final int idProduk;
  final int jumlah;
  final DateTime tglMasuk;
  final Produk? produk;
  final LokasiRak? lokasi;

  Stok({
    required this.idStok,
    required this.idLokasi,
    required this.idProduk,
    required this.jumlah,
    required this.tglMasuk,
    this.produk,
    this.lokasi,
  });

  factory Stok.fromJson(Map<String, dynamic> json) {
    return Stok(
      idStok: json['id_stok'],
      idLokasi: json['id_lokasi'],
      idProduk: json['id_produk'],
      jumlah: json['jumlah'],
      tglMasuk: DateTime.parse(json['tgl_masuk']),
      produk: json['produk'] != null ? Produk.fromJson(json['produk']) : 
              (json['nama_produk'] != null ? Produk(
                idProduk: json['id_produk'],
                kodeProduk: '',
                namaProduk: json['nama_produk'],
                barcodeProduk: '',
                idKategori: 0,
                idSatuan: 0,
                idMataUang: json['id_mata_uang'] ?? 0, // WAJIB
                idTenant: json['id_tenant'] ?? 0,      // WAJIB
                harga: 0.0,
              ) : null),
      lokasi: json['lokasi'] != null ? LokasiRak.fromJson(json['lokasi']) :
              (json['nama_lokasi'] != null ? LokasiRak(
                idLokasi: json['id_lokasi'],
                idGudang: 0,
                namaLokasi: json['nama_lokasi'],
                barcodeLokasi: '',
                kapasitasBerat: 0,
                statusPenuh: false,
              ) : null),
    );
  }
}

class LokasiRak {
  final int idLokasi;
  final int idGudang;
  final String namaLokasi;
  final String barcodeLokasi;
  final int kapasitasBerat;
  final bool statusPenuh;

  LokasiRak({
    required this.idLokasi,
    required this.idGudang,
    required this.namaLokasi,
    required this.barcodeLokasi,
    required this.kapasitasBerat,
    required this.statusPenuh,
  });

  factory LokasiRak.fromJson(Map<String, dynamic> json) {
    return LokasiRak(
      idLokasi: json['id_lokasi'],
      idGudang: json['id_gudang'],
      namaLokasi: json['nama_lokasi'],
      barcodeLokasi: json['barcode_lokasi'] ?? '',
      kapasitasBerat: json['kapasitas_berat'] ?? 0,
      statusPenuh: json['status_penuh'] ?? false,
    );
  }
}

class Tenant {
  final int idTenant;
  final String namaTenant;
  final String alamatTenant;

  Tenant({
    required this.idTenant,
    required this.namaTenant,
    required this.alamatTenant,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      idTenant: json['id_tenant'] ?? 0,
      namaTenant: json['nama_tenant'] ?? '',
      alamatTenant: json['alamat_tenant'] ?? '',
    );
  }
}

class User {
  final int idUser;
  final String nama;
  final String email;

  User({
    required this.idUser,
    required this.nama,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'],
      nama: json['nama'],
      email: json['email'],
    );
  }
}

/*class DeliveryOrder {
  final int? idOrderRef;
  final String? nomorOrderRef;
  final String? keteranganOrderRef;
  final String? tglOrderRef;

  final int? idTenant;
  final int? idGudang;
  final int? idVendor;
  final String? namaVendor;

  final int? idOrder;
  final String? nomorOrder;
  final String? keteranganOrder;
  final String? tglOrder;

  final int? idProduk;
  final String? namaProduk;

  final int? idSatuan;
  final int? quantityKirim;
  final String? simbolSatuan;

  final int? idUser;
  final String? namaUser;

  final int? idArmada;
  final String? noPolisi;
  final int? noLambung;

  final int? idStatusOrder;
  final String? statusOrder;

  DeliveryOrder({
    this.idOrderRef,
    this.nomorOrderRef,
    this.keteranganOrderRef,
    this.tglOrderRef,
    this.idTenant,
    this.idGudang,
    this.idVendor,
    this.namaVendor,
    this.idOrder,
    this.nomorOrder,
    this.keteranganOrder,
    this.tglOrder,
    this.idProduk,
    this.namaProduk,
    this.idSatuan,
    this.quantityKirim,
    this.simbolSatuan,
    this.idUser,
    this.namaUser,
    this.idArmada,
    this.noPolisi,
    this.noLambung,
    this.idStatusOrder,
    this.statusOrder,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      idOrderRef: json['id_order_ref'],
      nomorOrderRef: json['nomor_order_ref'],
      keteranganOrderRef: json['keterangan_order_ref'],
      tglOrderRef: json['tgl_order_ref'],

      idTenant: json['id_tenant'],
      idGudang: json['id_gudang'],
      idVendor: json['id_vendor'],
      namaVendor: json['nama_vendor'],

      idOrder: json['id_order'],
      nomorOrder: json['nomor_order'],
      keteranganOrder: json['keterangan_order'],
      tglOrder: json['tgl_order'],

      idProduk: json['id_produk'],
      namaProduk: json['nama_produk'],

      idSatuan: json['id_satuan'],
      quantityKirim: json['quantity_kirim'],
      simbolSatuan: json['simbol_satuan'],

      idUser: json['id_user'],
      namaUser: json['nama'],

      idArmada: json['id_armada'],
      noPolisi: json['no_polisi'],
      noLambung: json['no_lambung'],

      idStatusOrder: json['id_status_order'],
      statusOrder: json['status_order'],
    );
  }
} */

class HeaderDeliveryOrder {
  final int? idOrder;
  final String? nomerOrder;
  final String? keteranganOrder;
  final String? tglOrder;

  final String? noPolisi;
  final String? noLambung;

  final String? nama;

  final int? idDetailDo;
  final int? otherProduk;

  final int? idProduk;
  final String? namaProduk;

  HeaderDeliveryOrder({
    this.idOrder,
    this.nomerOrder,
    this.keteranganOrder,
    this.tglOrder,
    this.noPolisi,
    this.noLambung,
    this.nama,
    this.idDetailDo,
    this.otherProduk,
    this.idProduk,
    this.namaProduk,
  });

  factory HeaderDeliveryOrder.fromJson(Map<String, dynamic> json) {
    return HeaderDeliveryOrder(
      idOrder: json['id_order'] is int ? json['id_order'] : int.tryParse(json['id_order'].toString()),

      nomerOrder: json['nomer_order']?.toString(),
      keteranganOrder: json['keterangan_order']?.toString(),
      tglOrder: json['tgl_order']?.toString(),

      noPolisi: json['no_polisi']?.toString(),
      noLambung: json['no_lambung']?.toString(),  // ⬅ FIX penting

      nama: json['nama']?.toString(),

      idDetailDo: json['id_detail_do'] is int ? json['id_detail_do'] : int.tryParse(json['id_detail_do'].toString()),
      otherProduk: json['other_produk'] is int ? json['other_produk'] : int.tryParse(json['other_produk'].toString()),
      idProduk: json['id_produk'] is int ? json['id_produk'] : int.tryParse(json['id_produk'].toString()),

      namaProduk: json['nama_produk']?.toString(),
    );
  }
}


