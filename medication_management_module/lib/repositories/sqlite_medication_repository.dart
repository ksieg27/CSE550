import 'package:sqflite/sqflite.dart';
import '../models/medication.dart';
import 'medication_repository.dart';
import '../services/database_helper.dart';

class SQLiteMedicationRepository implements MedicationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<void> addMedication(MyMedication medication) async {
    final Database db = await _databaseHelper.database;
    await db.insert('medications', medication.toMap().cast<String, Object?>());
  }

  @override
  Future<List<MyMedication>> fetchMedications() async {
    final Database db = await _databaseHelper.database;

    final maps = await db.query('medications');
    return maps.map((map) => MyMedication.fromMap(map)).toList();
  }

  @override
  Future<void> updateMedication(MyMedication medication) async {
    final Database db = await _databaseHelper.database;
    await db.update(
      'medications',
      medication.toMap().cast<String, Object?>(),
      where: 'id = ?',
      whereArgs: [medication.brandName],
    );
  }

  @override
  Future<void> deleteMedication(int id) async {
    print('Deleting medication with ID: $id');
    final Database db = await _databaseHelper.database;

    final count = await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );

    print('Deleted $count rows');

    if (count == 0) {
      throw Exception('No medication found with ID $id');
    }
  }
}
