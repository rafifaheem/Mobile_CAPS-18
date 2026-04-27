import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gudang_provider.dart';

mixin GudangAwareMixin<T extends StatefulWidget> on State<T> {
  GudangProvider? _gudangProvider;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gudangProvider = Provider.of<GudangProvider>(context, listen: false);
      _gudangProvider?.addListener(_onGudangChanged);
      onGudangInitialized(_gudangProvider?.selectedGudangId);
    });
  }
  
  @override
  void dispose() {
    _gudangProvider?.removeListener(_onGudangChanged);
    super.dispose();
  }
  
  void _onGudangChanged() {
    if (mounted) {
      onGudangChanged(_gudangProvider?.selectedGudangId);
    }
  }
  
  // Override these methods in your screen
  void onGudangInitialized(int? gudangId) {}
  void onGudangChanged(int? gudangId) {}
  
  // Helper method to get current gudang ID
  int? get currentGudangId => _gudangProvider?.selectedGudangId;
  String get currentGudangName => _gudangProvider?.selectedGudangName ?? 'Pilih Gudang';
}