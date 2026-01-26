import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import '../utils/constants.dart';

class VehicleService {
  // Fetch vehicle data from server
  Future<Vehicle> fetchVehicle(String vehicleId) async {
    try {
      // In a real application, this would be an actual API call
      // For demo purposes, we'll simulate with a delay and return mock data
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate API response
      // In production, use: final response = await http.get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicleEndpoint}/$vehicleId'));
      
      // Mock data for vehicle "123"
      if (vehicleId == '123') {
        return Vehicle(
          id: vehicleId,
          brand: 'Sonas Dong',
          model: 'PHEV',
          mileage: 4980.0,
          batteryLevel: 89,
          fuelLevel: 34.0,
          fuelConsumption: 6.5, // L/100km
          isLocked: true,
          lastUpdate: DateTime.now(),
        );
      }
      
      throw Exception('Vehicle not found');
    } catch (e) {
      throw Exception('Failed to fetch vehicle data: $e');
    }
  }

  // Sync vehicle data (refresh from server)
  Future<Vehicle> syncVehicle(String vehicleId) async {
    return await fetchVehicle(vehicleId);
  }

  // Update vehicle lock status (send to server)
  Future<void> updateLockStatus(String vehicleId, bool isLocked) async {
    try {
      // In a real application, this would send a request to the server
      // For demo purposes, we'll just simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In production:
      // final response = await http.post(
      //   Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicleEndpoint}/$vehicleId/lock'),
      //   body: jsonEncode({'isLocked': isLocked}),
      //   headers: {'Content-Type': 'application/json'},
      // );
      // if (response.statusCode != 200) {
      //   throw Exception('Failed to update lock status');
      // }
    } catch (e) {
      throw Exception('Failed to update lock status: $e');
    }
  }

  // Locate vehicle (send to server)
  Future<Map<String, double>> locateVehicle(String vehicleId) async {
    try {
      // In a real application, this would send a request to the server
      // For demo purposes, we'll return mock coordinates
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'latitude': 36.8065,
        'longitude': 10.1815,
      };
    } catch (e) {
      throw Exception('Failed to locate vehicle: $e');
    }
  }
}
