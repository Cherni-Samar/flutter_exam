import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vehicle_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _vehicleIdController = TextEditingController();
  final VehicleService _vehicleService = VehicleService();
  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _vehicleIdController.dispose();
    super.dispose();
  }

  Future<void> _connectToVehicle() async {
    final vehicleId = _vehicleIdController.text.trim();
    
    if (vehicleId.isEmpty) {
      _showSnackBar('Veuillez entrer un ID de véhicule');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch vehicle data from server
      final vehicle = await _vehicleService.fetchVehicle(vehicleId);
      
      // Save vehicle to local database
      await _databaseService.saveVehicle(vehicle);
      
      // Save connection state to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsKeys.isConnected, true);
      await prefs.setString(PrefsKeys.vehicleId, vehicleId);
      
      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Aucun véhicule avec cet ID n\'est disponible');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo/icon
                Icon(
                  Icons.cloud,
                  size: 100,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Contrôle de Véhicule',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Aucun véhicule associé pour le moment, connectez votre véhicule...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Vehicle ID input field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _vehicleIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID du Véhicule',
                        hintText: 'Entrez l\'ID du véhicule',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Connect button
                ElevatedButton(
                  onPressed: _isLoading ? null : _connectToVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.connectButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                
                // Help text
                Text(
                  'Astuce: Utilisez l\'ID "123" pour tester',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
