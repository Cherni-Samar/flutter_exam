import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../models/notification.dart';
import '../services/database_service.dart';
import '../services/vehicle_service.dart';
import '../utils/constants.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/control_button.dart';
import '../widgets/info_indicator.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final VehicleService _vehicleService = VehicleService();
  Vehicle? _vehicle;
  bool _isLoading = true;
  bool _isSyncing = false;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = await _databaseService.getFirstVehicle();
      if (vehicle != null) {
        setState(() {
          _vehicle = vehicle;
          _isLoading = false;
        });
        
        // Check and generate notifications
        await _checkAndGenerateNotifications();
        await _updateNotificationCount();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationCount() async {
    final notifications = await _databaseService.getAllNotifications();
    setState(() {
      _notificationCount = notifications.length;
    });
  }

  Future<void> _checkAndGenerateNotifications() async {
    if (_vehicle == null) return;

    // Check for low autonomy notification
    if (_vehicle!.autonomy <= Thresholds.lowAutonomy) {
      await _addNotificationIfNotExists(
        NotificationTypes.lowAutonomy,
        NotificationMessages.lowAutonomy,
      );
    }

    // Check for maintenance notification
    final prefs = await SharedPreferences.getInstance();
    final lastMaintenanceMileage = prefs.getDouble(PrefsKeys.lastMaintenanceMileage) ?? 0.0;
    
    if (FormatUtils.isMaintenanceDue(_vehicle!.mileage, lastMaintenanceMileage)) {
      await _addNotificationIfNotExists(
        NotificationTypes.maintenance,
        NotificationMessages.maintenance,
      );
      // Update last maintenance mileage
      await prefs.setDouble(PrefsKeys.lastMaintenanceMileage, _vehicle!.mileage);
    }
  }

  Future<void> _addNotificationIfNotExists(String type, String message) async {
    final notifications = await _databaseService.getAllNotifications();
    final exists = notifications.any((n) => n.type == type);
    
    if (!exists) {
      final notification = VehicleNotification(
        type: type,
        message: message,
        timestamp: DateTime.now(),
      );
      await _databaseService.addNotification(notification);
      await _updateNotificationCount();
    }
  }

  Future<void> _syncVehicle() async {
    if (_vehicle == null) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final vehicleId = prefs.getString(PrefsKeys.vehicleId);
      
      if (vehicleId != null) {
        final updatedVehicle = await _vehicleService.syncVehicle(vehicleId);
        await _databaseService.updateVehicle(updatedVehicle);
        
        setState(() {
          _vehicle = updatedVehicle;
        });
        
        await _checkAndGenerateNotifications();
        await _updateNotificationCount();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données synchronisées')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de synchronisation')),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _toggleLock() async {
    if (_vehicle == null) return;

    final newLockState = !_vehicle!.isLocked;
    
    try {
      await _vehicleService.updateLockStatus(_vehicle!.id, newLockState);
      
      final updatedVehicle = _vehicle!.copyWith(
        isLocked: newLockState,
        lastUpdate: DateTime.now(),
      );
      
      await _databaseService.updateVehicle(updatedVehicle);
      
      setState(() {
        _vehicle = updatedVehicle;
      });

      // Handle unlock notification
      if (!newLockState) {
        // Vehicle is unlocked - add notification
        final notification = VehicleNotification(
          type: NotificationTypes.unlock,
          message: NotificationMessages.unlock,
          timestamp: DateTime.now(),
        );
        await _databaseService.addNotification(notification);
      } else {
        // Vehicle is locked - remove unlock notification
        await _databaseService.deleteNotificationByType(NotificationTypes.unlock);
      }
      
      await _updateNotificationCount();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newLockState ? 'Véhicule verrouillé' : 'Véhicule déverrouillé',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du changement d\'état')),
        );
      }
    }
  }

  Future<void> _findVehicle() async {
    if (_vehicle == null) return;

    try {
      final location = await _vehicleService.locateVehicle(_vehicle!.id);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Localisation du véhicule'),
            content: Text(
              'Latitude: ${location['latitude']?.toStringAsFixed(6)}\n'
              'Longitude: ${location['longitude']?.toStringAsFixed(6)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de localisation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Mon Véhicule'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                  await _updateNotificationCount();
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicle == null
              ? const Center(child: Text('Aucun véhicule connecté'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vehicle card
                      VehicleCard(vehicle: _vehicle!),
                      const SizedBox(height: 24),
                      
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ControlButton(
                            icon: _vehicle!.isLocked ? Icons.lock : Icons.lock_open,
                            label: _vehicle!.isLocked ? 'Lock' : 'Unlock',
                            color: _vehicle!.isLocked 
                                ? AppColors.lockButtonColor 
                                : AppColors.unlockButtonColor,
                            onPressed: _toggleLock,
                          ),
                          ControlButton(
                            icon: Icons.location_on,
                            label: 'Find me',
                            color: AppColors.findMeButtonColor,
                            onPressed: _findVehicle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Info indicators
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InfoIndicator(
                                icon: Icons.battery_charging_full,
                                label: 'Batterie',
                                value: '${_vehicle!.batteryLevel}%',
                                iconColor: Colors.green,
                              ),
                              InfoIndicator(
                                icon: Icons.route,
                                label: 'Autonomie',
                                value: '${_vehicle!.autonomy.toStringAsFixed(0)} KM',
                                iconColor: Colors.blue,
                              ),
                              InfoIndicator(
                                icon: Icons.local_gas_station,
                                label: 'Carburant',
                                value: '${_vehicle!.fuelLevel.toStringAsFixed(0)}L',
                                iconColor: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Last update info
                      if (_vehicle!.lastUpdate != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Dernière mise à jour: ${DateFormat('dd/MM/yyyy HH:mm').format(_vehicle!.lastUpdate!)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      
                      // Sync button
                      ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _syncVehicle,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: const Text('Sync'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.syncButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
