import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'medications.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
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
        numberOfDoses INTEGER,
        frequencyTaken TEXT,
        numberOfDosesPerDay INTEGER,
        hourlyFrequency INTEGER,
        notes TEXT,
        endDate TEXT
      )
    ''');
  }
}
