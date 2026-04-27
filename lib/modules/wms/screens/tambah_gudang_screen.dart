import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/gudang_model.dart';
import 'package:cargoind/modules/wms/services/gudang_service.dart';
import 'package:cargoind/modules/wms/models/status_gudang_model.dart';
import 'package:cargoind/core/mixins/error_handler_mixin.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';

class TambahGudangScreen extends StatefulWidget {
  final Gudang? gudang;
  
  const TambahGudangScreen({super.key, this.gudang});

  @override
  State<TambahGudangScreen> createState() => _TambahGudangScreenState();
}

class _TambahGudangScreenState extends State<TambahGudangScreen> with ErrorHandlerMixin {
  final _formKey = GlobalKey<FormState>();
  final GudangService _gudangService = GudangService();
  final StatusGudangService _statusService = StatusGudangService();
  
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _jumlahController;
  bool _isAktif = true;
  bool _isLoading = false;
  List<StatusGudang> statusList = [];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.gudang?.namaGudang ?? '');
    _alamatController = TextEditingController(text: widget.gudang?.alamat ?? '');
    _jumlahController = TextEditingController(text: widget.gudang?.jumlah.toString() ?? '0');
    _isAktif = widget.gudang?.idStatusGudang == 7;
    _loadStatusGudang();
  }

  Future<void> _loadStatusGudang() async {
    try {
       statusList = await _statusService.getStatusGudang();
      setState(() {
        statusList = statusList;
      });
    } catch (e) {
      print('Error loading status: $e');
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _saveGudang() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final gudang = Gudang(
        idGudang: widget.gudang?.idGudang,
        namaGudang: _namaController.text,
        alamat: _alamatController.text,
        jumlah: int.tryParse(_jumlahController.text) ?? 0,
        idStatusGudang: _isAktif ? 7 : 8, // 7 = Aktif, 8 = Tidak Aktif
        dibuatOleh: 1, // TODO: Get from auth service
        diubahOleh: 1, // TODO: Get from auth service
      );

      if (widget.gudang == null) {
        await _gudangService.createGudang(gudang);
      } else {
        await _gudangService.updateGudang(widget.gudang!.idGudang!, gudang);
      }
      Navigator.pop(context);
    } catch (e) {
      handleError(context, e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gudang == null ? 'Tambah Gudang' : 'Edit Gudang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Gudang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama gudang harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Status: ${_isAktif ? 'Aktif' : 'Tidak Aktif'}',
                  style: TextStyle(
                    color: _isAktif ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isAktif,
                onChanged: (value) {
                  setState(() {
                    _isAktif = value;
                  });
                },
                activeThumbColor: Colors.green, //other option: activeTrackColor
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGudang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.gudang == null ? 'Tambah Gudang' : 'Perbarui Gudang',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}