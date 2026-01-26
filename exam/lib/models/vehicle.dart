class Vehicle {
  final String id;
  final String brand;
  final String model;
  final double mileage;
  final int batteryLevel; // percentage 0-100
  final double fuelLevel; // liters
  final double fuelConsumption; // liters per 100 km
  final bool isLocked;
  final DateTime? lastUpdate;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.mileage,
    required this.batteryLevel,
    required this.fuelLevel,
    required this.fuelConsumption,
    required this.isLocked,
    this.lastUpdate,
  });

  // Calculate autonomy (range) in KM
  // Formula: fuel autonomy + battery autonomy
  // Battery: 100% = 345 KM (defined in constants)
  // Fuel: (fuelLevel / fuelConsumption) * 100
  double get autonomy {
    const batteryMaxRange = 345.0; // KM at 100% battery
    final batteryAutonomy = (batteryLevel / 100) * batteryMaxRange;
    final fuelAutonomy = (fuelLevel / fuelConsumption) * 100;
    return batteryAutonomy + fuelAutonomy;
  }

  // Copy with method for updating vehicle state
  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    double? mileage,
    int? batteryLevel,
    double? fuelLevel,
    double? fuelConsumption,
    bool? isLocked,
    DateTime? lastUpdate,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      mileage: mileage ?? this.mileage,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      fuelConsumption: fuelConsumption ?? this.fuelConsumption,
      isLocked: isLocked ?? this.isLocked,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'mileage': mileage,
      'batteryLevel': batteryLevel,
      'fuelLevel': fuelLevel,
      'fuelConsumption': fuelConsumption,
      'isLocked': isLocked ? 1 : 0,
      'lastUpdate': lastUpdate?.toIso8601String(),
    };
  }

  // Create Vehicle from Map (database)
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      mileage: map['mileage'] as double,
      batteryLevel: map['batteryLevel'] as int,
      fuelLevel: map['fuelLevel'] as double,
      fuelConsumption: map['fuelConsumption'] as double,
      isLocked: (map['isLocked'] as int) == 1,
      lastUpdate: map['lastUpdate'] != null
          ? DateTime.parse(map['lastUpdate'] as String)
          : null,
    );
  }

  // Create Vehicle from JSON (API response)
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      mileage: (json['mileage'] as num).toDouble(),
      batteryLevel: json['batteryLevel'] as int,
      fuelLevel: (json['fuelLevel'] as num).toDouble(),
      fuelConsumption: (json['fuelConsumption'] as num).toDouble(),
      isLocked: json['isLocked'] as bool,
      lastUpdate: DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'mileage': mileage,
      'batteryLevel': batteryLevel,
      'fuelLevel': fuelLevel,
      'fuelConsumption': fuelConsumption,
      'isLocked': isLocked,
    };
  }
}
