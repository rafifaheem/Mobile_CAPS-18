import 'package:shared_preferences/shared_preferences.dart';
import 'package:cargoind/modules/wms/models/gudang_model.dart';
import 'dart:convert';

class SelectedGudangService {
  static const String _selectedGudangKey = 'selected_gudang';
  static Gudang? _selectedGudang;

  static Future<void> setSelectedGudang(Gudang gudang) async {
    _selectedGudang = gudang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedGudangKey, json.encode(gudang.toJson()));
  }

  static Future<Gudang?> getSelectedGudang() async {
    if (_selectedGudang != null) return _selectedGudang;
    
    final prefs = await SharedPreferences.getInstance();
    final gudangJson = prefs.getString(_selectedGudangKey);
    
    if (gudangJson != null) {
      final gudangData = json.decode(gudangJson);
      _selectedGudang = Gudang.fromJson(gudangData);
      return _selectedGudang;
    }
    
    return null;
  }

  static Future<void> clearSelectedGudang() async {
    _selectedGudang = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedGudangKey);
  }
}