import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'medications.db');
    return openDatabase(
      path,
      version: 2, // <-- Increment the version number (e.g., from 1 to 2)
      onCreate: _createDb,
      onUpgrade: _upgradeDb, // Make sure onUpgrade is provided
    );
  }

  // Your existing _createDb method (should already include the new columns for fresh installs)
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE profiles(
      email TEXT PRIMARY KEY,
      firstName TEXT,
      lastName TEXT,
      doctorName TEXT,
      doctorPhone TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE medications(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile TEXT,
      brandName TEXT,
      genericName TEXT,
      quantity INTEGER,
      startDate INTEGER,
      refillDate TEXT,
      time INTEGER,
      dosage TEXT,
      numberOfDosesPerDay INTEGER,
      frequencyTaken TEXT,
      hourlyFrequency INTEGER,
      numberOfDoses INTEGER,
      notes TEXT,
      endDate TEXT,
      takenToday INTEGER DEFAULT 0,
      lastTakenDate INTEGER
    )
  ''');
  }

  // Add or update the onUpgrade method
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion");
    if (oldVersion < 2) {
      // Add the columns if upgrading from a version before 2
      try {
        print("Adding takenToday column...");
        await db.execute(
          'ALTER TABLE medications ADD COLUMN takenToday INTEGER DEFAULT 0',
        );
        print("Adding lastTakenDate column...");
        await db.execute(
          'ALTER TABLE medications ADD COLUMN lastTakenDate INTEGER',
        );
        print("Columns added successfully.");
      } catch (e) {
        print('Error upgrading database table: $e');
        // Handle potential errors, e.g., column already exists if run multiple times
      }
    }
    // Add more 'if (oldVersion < X)' blocks for future upgrades
  }
}
