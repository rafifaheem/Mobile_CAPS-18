import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/core/services/api_service.dart';
import 'package:cargoind/modules/wms/models/status_gudang_model.dart';

class StatusGudangService extends BaseApiService {
  static const String _endpoint = '/api/master/status-gudang';

  Future<List<StatusGudang>> getStatusGudang() async {
    return await getList<StatusGudang>(_endpoint, StatusGudang.fromJson);
  }
}
class WMSService extends BaseApiService {
  // Method untuk test koneksi API
  static Future<bool> testApiConnection() async {
    try {
      final service = WMSService();
      // Gunakan endpoint yang sudah terbukti bekerja
      await service.makeRequest('GET', '/api/po/list');
      return true;
    } catch (e) {
      print('🔧 API connection test failed: $e');
      return false;
    }
  }

  // Method untuk test endpoint PO list
  static Future<bool> testPOListEndpoint() async {
    try {
      final service = WMSService();
      await service.makeRequest('GET', '/api/po/list');
      return true;
    } catch (e) {
      print('🔧 PO list endpoint test failed: $e');
      return false;
    }
  }

  // Static methods for backward compatibility
  static Future<List<PO>> getPurchaseOrders() async {
    final service = WMSService();
    return await service.getList<PO>('/api/po/list', PO.fromJson);
  }

static Future<bool> createPurchaseOrder(Map<String, dynamic> newPO) async {
    try {
      final service = WMSService();
      await service.makeRequest('POST', '/api/po/create', newPO, false);
      return true;
    } catch (e) {
      print('Create PO error: $e');
      return false;
    }
  }

  static Future<List<DetailPO>> getPODetails(String uuidOrder) async {
    try {
      final service = WMSService();
      print('🔧 Getting PO details for UUID: $uuidOrder');
      
      // Validasi UUID
      if (uuidOrder.isEmpty) {
        throw Exception('UUID Order is empty');
      }
      
      // Berdasarkan log, endpoint pertama memberikan respons yang benar
      // "No details found for this PO" artinya endpoint benar tapi tidak ada data
      final result = await service.getList<DetailPO>(
        '/api/po/detail/$uuidOrder',
        DetailPO.fromJson,
      );
      
      return result;
    } catch (e) {
      print('🔧 getPODetails error: $e');
      // Jika error karena tidak ada data, return list kosong
      if (e.toString().contains('No details found for this PO')) {
        return [];
      }
      rethrow;
    }
  }


  static Future<List<HeaderDeliveryOrder>> getDeliveryOrders() async {
    final service = WMSService();
    final endpoint = '/api/do/list'; // GANTI sesuai backend kamu
    return await service.getList<HeaderDeliveryOrder>(endpoint, HeaderDeliveryOrder.fromJson);
  }

  // Static methods for backward compatibility
  static Future<bool> createGoodsReceipt(Map<String, dynamic> receiptData) async {
    try {
      final service = WMSService();
      await service.makeRequest('POST', '/api/goods-receipt', receiptData);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<DetailPO>> getQualityControlList() async {
    final service = WMSService();
    return await service.getList<DetailPO>('/api/qc/list', DetailPO.fromJson);
  }

  static Future<bool> createQualityControl(Map<String, dynamic> qcData) async {
    try {
      final service = WMSService();
      await service.makeRequest('POST', '/api/qc/create', qcData);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<LokasiRak>> getAvailableLocations(int idGudang) async {
    final service = WMSService();
    return await service.getList<LokasiRak>('/api/wms/lokasi-rak?id_gudang=$idGudang', LokasiRak.fromJson);
  }

  static Future<bool> putAwayItems(Map<String, dynamic> putAwayData) async {
    try {
      final service = WMSService();
      await service.makeRequest('POST', '/api/wms/put-away', putAwayData);
      return true;
    } catch (e) {
      return false;
    }
  }

    static Future<List<Produk>> getProducts(int idTenant) async {
    final service = WMSService();
    final endpoint = '/api/master/produk?id_tenant=$idTenant';
    return await service.getList<Produk>(endpoint, Produk.fromJson);
  }

 
    static Future<List<Tenant>> getTenants() async {
    final service = WMSService();
    return await service.getList<Tenant>('/api/master/tenant', Tenant.fromJson);
  } 

  Future<List<Stok>> getStock({int? idLokasi, int? idProduk}) async {
    String endpoint = '/api/inventory/stok';
    List<String> params = [];
    if (idLokasi != null) params.add('id_lokasi=$idLokasi');
    if (idProduk != null) params.add('id_produk=$idProduk');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';
    
    return await getList<Stok>(endpoint, Stok.fromJson);
  }
}
