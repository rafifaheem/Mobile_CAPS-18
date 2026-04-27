import 'package:cargoind/modules/wms/models/gudang_model.dart';
import 'package:cargoind/core/services/api_service.dart';

class GudangService extends BaseApiService {
  static const String _endpoint = '/api/master/gudang';

  Future<List<Gudang>> getGudang() async {
    try {
      print('🔧 Getting gudang list from $_endpoint');
      final result = await getList<Gudang>(_endpoint, Gudang.fromJson);
      print('🔧 Successfully loaded ${result.length} gudang');
      return result;
    } catch (e) {
      print('🔧 Error getting gudang: $e');
      rethrow;
    }
  }

  Future<Gudang> createGudang(Gudang gudang) async {
    final response = await makeRequest('POST', _endpoint, gudang.toJson());
    return Gudang.fromJson(response['data']);
  }

  Future<Gudang> updateGudang(int id, Gudang gudang) async {
    final response = await makeRequest('PUT', '$_endpoint/$id', gudang.toJson());
    return Gudang.fromJson(response['data']);
  }

  Future<void> deleteGudang(int id) async {
    await delete('$_endpoint/$id');
  }
}