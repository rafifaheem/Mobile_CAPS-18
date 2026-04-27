import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleDataService {
  static const String _storageKey = 'vehicle_registrations';
  
  // Get all vehicles from SharedPreferences
  static Future<List<Map<String, dynamic>>> getAllVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey) ?? '[]';
    final List<dynamic> vehicles = jsonDecode(data);
    return vehicles.map((v) => Map<String, dynamic>.from(v)).toList();
  }
  
  // Save vehicle to SharedPreferences
  static Future<void> saveVehicle(Map<String, dynamic> vehicle) async {
    final vehicles = await getAllVehicles();
    
    // Check if vehicle already exists (update) or new (add)
    final existingIndex = vehicles.indexWhere((v) => v['id'] == vehicle['id']);
    
    if (existingIndex >= 0) {
      vehicles[existingIndex] = vehicle;
    } else {
      vehicles.add(vehicle);
    }
    
    await _saveToStorage(vehicles);
  }
  
  // Update vehicle status
  static Future<void> updateVehicleStatus(String vehicleId, String status, String substatus) async {
    final vehicles = await getAllVehicles();
    final vehicleIndex = vehicles.indexWhere((v) => v['id'] == vehicleId);
    
    if (vehicleIndex >= 0) {
      vehicles[vehicleIndex]['verification_status'] = status;
      vehicles[vehicleIndex]['verification_substatus'] = substatus;
      vehicles[vehicleIndex]['updated_at'] = DateTime.now().toIso8601String();
      
      if (status == 'approved') {
        vehicles[vehicleIndex]['approved_at'] = DateTime.now().toIso8601String();
      }
      
      await _saveToStorage(vehicles);
    }
  }
  
  // Get vehicles by status
  static Future<List<Map<String, dynamic>>> getVehiclesByStatus(String status) async {
    final vehicles = await getAllVehicles();
    
    switch (status) {
      case 'pending':
        return vehicles.where((v) => 
          v['verification_status'] == 'pending' || 
          v['verification_substatus'] == 'under_review' ||
          v['verification_substatus'] == 'document_review'
        ).toList();
      case 'approved':
        return vehicles.where((v) => v['verification_status'] == 'approved').toList();
      case 'rejected':
        return vehicles.where((v) => v['verification_status'] == 'rejected').toList();
      case 'needs_repair':
        return vehicles.where((v) => v['verification_status'] == 'needs_repair').toList();
      default:
        return vehicles;
    }
  }

  // Get managed vehicles (approved, rejected, needs_repair)
  static Future<List<Map<String, dynamic>>> getManagedVehicles() async {
    final vehicles = await getAllVehicles();
    return vehicles.where((v) => 
      v['verification_status'] == 'approved' ||
      v['verification_status'] == 'rejected' ||
      v['verification_status'] == 'needs_repair'
    ).toList();
  }

  // Add vehicle from verification
  static Future<void> addVehicle(Map<String, dynamic> vehicle) async {
    final vehicles = await getAllVehicles();
    
    // Check if vehicle already exists (update instead of add)
    final existingIndex = vehicles.indexWhere((v) => 
      v['registration_number'] == vehicle['registration_number'] ||
      (v['id'] != null && v['id'] == vehicle['id'])
    );
    
    if (existingIndex != -1) {
      vehicles[existingIndex] = vehicle;
    } else {
      vehicles.add(vehicle);
    }
    
    await _saveToStorage(vehicles);
  }
  
  // Sample data completely removed - only real data from registration
  static List<Map<String, dynamic>> getSampleData() {
    return [];
  }
  
  // Initialize with sample data if empty - DISABLED
  static void initializeSampleData() {
    // Completely disabled - only use real data from vehicle registration
    return;
  }
  
  // Private methods
  static Future<void> _saveToStorage(List<Map<String, dynamic>> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(vehicles));
  }
  
  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove('vehicle_verifications'); // Also clear verification data
  }
  
  // Clear sample data specifically
  static Future<void> clearSampleData() async {
    final vehicles = await getAllVehicles();
    final realVehicles = vehicles.where((v) => 
      v['id'] == null || 
      !v['id'].toString().startsWith('sample_')
    ).toList();
    await _saveToStorage(realVehicles);
  }
}