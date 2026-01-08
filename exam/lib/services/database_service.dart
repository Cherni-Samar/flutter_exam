import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';
import '../models/notification.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConfig.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create vehicles table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.vehicleTable} (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        mileage REAL NOT NULL,
        batteryLevel INTEGER NOT NULL,
        fuelLevel REAL NOT NULL,
        fuelConsumption REAL NOT NULL,
        isLocked INTEGER NOT NULL,
        lastUpdate TEXT
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.notificationTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL
      )
    ''');
  }

  // Vehicle operations
  Future<void> saveVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.insert(
      DatabaseConfig.vehicleTable,
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Vehicle?> getVehicle(String id) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConfig.vehicleTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<Vehicle?> getFirstVehicle() async {
    final db = await database;
    final maps = await db.query(
      DatabaseConfig.vehicleTable,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.update(
      DatabaseConfig.vehicleTable,
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> deleteVehicle(String id) async {
    final db = await database;
    await db.delete(
      DatabaseConfig.vehicleTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Notification operations
  Future<int> addNotification(VehicleNotification notification) async {
    final db = await database;
    return await db.insert(
      DatabaseConfig.notificationTable,
      notification.toMap(),
    );
  }

  Future<List<VehicleNotification>> getAllNotifications() async {
    final db = await database;
    final maps = await db.query(
      DatabaseConfig.notificationTable,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => VehicleNotification.fromMap(map)).toList();
  }

  Future<void> deleteNotificationByType(String type) async {
    final db = await database;
    await db.delete(
      DatabaseConfig.notificationTable,
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<void> clearAllNotifications() async {
    final db = await database;
    await db.delete(DatabaseConfig.notificationTable);
  }

  Future<void> deleteNotification(int id) async {
    final db = await database;
    await db.delete(
      DatabaseConfig.notificationTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
