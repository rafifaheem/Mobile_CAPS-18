import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:cargoind/modules/dms/screens/photo_guide_screen.dart';
import 'package:cargoind/modules/dms/screens/training_online_screen.dart';
import 'package:cargoind/modules/dms/services/api_service.dart';

class PhotoUploadScreen extends StatefulWidget {
  final bool isRejectionFlow;
  
  PhotoUploadScreen({this.isRejectionFlow = false});
  
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ApiService _apiService = ApiService();
  File? _photoImage;
  bool _isLoading = false;
  String _driverName = 'Driver';

  @override
  void initState() {
    super.initState();
    _loadDriverName();
  }

  Future<void> _loadDriverName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registrationDataJson = prefs.getString('registration_data');
      if (registrationDataJson != null) {
        final registrationData = json.decode(registrationDataJson);
        setState(() {
          _driverName = registrationData['nama'] ?? 'Driver';
        });
      }
    } catch (e) {
      print('Error loading driver name: $e');
    }
  }

  Future<void> _openPhotoGuide() async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoGuideScreen()),
    );
    
    if (capturedImage != null) {
      setState(() {
        _photoImage = capturedImage;
      });
    }
  }

  Future<void> _navigateToCompleteForm() async {
    if (_photoImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon ambil foto diri terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isRejectionFlow) {
        // Update rejected documents via API
        final bytes = await _photoImage!.readAsBytes();
        final base64String = base64Encode(bytes);
        
        final updateData = {
          'foto_profil': base64String,
        };

        await _apiService.updateRejectedDocuments(updateData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil diperbaiki'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to rejection details screen with success indicator
        Navigator.pop(context, true);
      } else {
        // Normal registration flow
        final prefs = await SharedPreferences.getInstance();
        final registrationDataJson = prefs.getString('registration_data');
        
        print('DEBUG - Registration data: $registrationDataJson');
        
        if (registrationDataJson == null) {
          throw Exception('Data registrasi tidak ditemukan. Silakan mulai dari awal.');
        }
        
        final registrationData = json.decode(registrationDataJson);
        
        // Update foto profil in database
        final bytes = await _photoImage!.readAsBytes();
        final base64String = base64Encode(bytes);
        
        final photoData = {
          'foto_profil': base64String,
        };
        
        await _apiService.updateDriverProfile(photoData);
        
        // Update registration data
        registrationData['foto_profil'] = base64String;
        await prefs.setString('registration_data', json.encode(registrationData));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingOnlineScreen(),
            settings: RouteSettings(
              arguments: {
                'isAuthenticated': true,
                'userEmail': registrationData['email'],
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              
              Text(
                'Hai $_driverName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 10),
              
              Text(
                'Anda akan mendaftar untuk layanan\nPlatformDriver',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              // Photo circle
              GestureDetector(
                onTap: _openPhotoGuide,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                    color: Colors.grey.shade100,
                  ),
                  child: _photoImage != null
                      ? ClipOval(
                          child: Image.file(
                            _photoImage!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                ),
              ),
              
              SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 16, color: Color(0xFF6C757D)),
                  SizedBox(width: 8),
                  Text(
                    'Unggah Foto Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF495057),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 60),
              
              // Buttons
              if (_photoImage != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openPhotoGuide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Foto Ulang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _navigateToCompleteForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDC3545),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.isRejectionFlow ? 'Perbaiki Foto' : 'Simpan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openPhotoGuide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDC3545),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}