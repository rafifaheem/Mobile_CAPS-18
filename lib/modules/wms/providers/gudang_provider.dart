import 'package:flutter/foundation.dart';
import '../models/gudang_model.dart';
import '../services/selected_gudang_service.dart';

class GudangProvider extends ChangeNotifier {
  static final GudangProvider _instance = GudangProvider._internal();
  factory GudangProvider() => _instance;
  GudangProvider._internal();

  Gudang? _selectedGudang;
  
  Gudang? get selectedGudang => _selectedGudang;
  int? get selectedGudangId => _selectedGudang?.idGudang;
  String get selectedGudangName => _selectedGudang?.namaGudang ?? 'Pilih Gudang';

  Future<void> loadSelectedGudang() async {
    _selectedGudang = await SelectedGudangService.getSelectedGudang();
    notifyListeners();
  }

  Future<void> setSelectedGudang(Gudang gudang) async {
    _selectedGudang = gudang;
    await SelectedGudangService.setSelectedGudang(gudang);
    notifyListeners();
    print('🏭 Gudang changed to: ${gudang.namaGudang}');
  }

  Future<void> clearSelectedGudang() async {
    _selectedGudang = null;
    await SelectedGudangService.clearSelectedGudang();
    notifyListeners();
  }
}