import 'package:flutter/material.dart';

// Notification types
class NotificationTypes {
  static const String unlock = 'unlock';
  static const String lock = 'lock';
  static const String lowAutonomy = 'low_autonomy';
  static const String maintenance = 'maintenance';
}

// Notification messages
class NotificationMessages {
  static const String unlock = 'État de Verrouillage désactivé : Assurez vous de l\'activer';
  static const String lowAutonomy = 'Niveau de carburant/batterie trop bas, Rechargez votre véhicule';
  static const String maintenance = 'C\'est l\'heure de l\'entretien, Vous avez dépassé les 10 000 KM';
}

// Thresholds
class Thresholds {
  static const double lowAutonomy = 60.0; // KM
  static const int maintenanceMileageInterval = 10000; // KM
}

// Colors
class AppColors {
  static const Color primaryColor = Color(0xFF2E3B4E);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color lockButtonColor = Color(0xFF4CAF50);
  static const Color unlockButtonColor = Color(0xFFFF9800);
  static const Color findMeButtonColor = Color(0xFF2196F3);
  static const Color syncButtonColor = Color(0xFF9C27B0);
  static const Color connectButtonColor = Color(0xFF2196F3);
}

// API Configuration
class ApiConfig {
  // Note: Replace with actual API endpoint
  static const String baseUrl = 'https://api.example.com';
  static const String vehicleEndpoint = '/vehicle';
}

// Database configuration
class DatabaseConfig {
  static const String databaseName = 'vehicle_app.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String vehicleTable = 'vehicles';
  static const String notificationTable = 'notifications';
}

// Shared preferences keys
class PrefsKeys {
  static const String isConnected = 'is_connected';
  static const String vehicleId = 'vehicle_id';
}
