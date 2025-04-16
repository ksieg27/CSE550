import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import 'medication_repository.dart';
import '../services/database_helper.dart';

/// Repository implementation for SQLite database storage of medications
class SQLiteMedicationRepository implements MedicationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Adds a new medication to the database
  /// Returns the ID of the newly inserted medication
  @override
  Future<int> addMedication(MyMedication medication) async {
    try {
      final Database db = await _databaseHelper.database;
      final id = await db.insert(
        'medications',
        medication.toMap().cast<String, Object?>(),
      );

      if (kDebugMode) {
        print('Added medication with ID: $id');
      }

      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding medication: $e');
      }
      rethrow; // Propagate error to caller for handling
    }
  }

  /// Retrieves all medications from the database
  @override
  Future<List<MyMedication>> fetchMedications() async {
    try {
      final Database db = await _databaseHelper.database;
      final maps = await db.query('medications');

      if (kDebugMode) {
        print('Retrieved ${maps.length} medications from database');
      }

      return maps.map((map) => MyMedication.fromMap(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching medications: $e');
      }
      return []; // Return empty list on error to prevent app crashes
    }
  }

  /// Updates an existing medication in the database
  @override
  Future<void> updateMedication(MyMedication medication) async {
    try {
      final db = await _databaseHelper.database;

      await db.update(
        'medications',
        medication.toMap(),
        where: 'id = ?',
        whereArgs: [medication.id],
      );

      if (kDebugMode) {
        print(
          'Updated medication ID: ${medication.id}, New quantity: ${medication.quantity}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating medication: $e');
      }
      rethrow;
    }
  }

  /// Deletes a medication from the database by ID
  @override
  Future<void> deleteMedication(int id) async {
    try {
      if (kDebugMode) {
        print('Deleting medication with ID: $id');
      }

      final Database db = await _databaseHelper.database;
      final count = await db.delete(
        'medications',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (kDebugMode) {
        print('Deleted $count rows');
      }

      if (count == 0) {
        throw Exception('No medication found with ID $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting medication: $e');
      }
      rethrow;
    }
  }

  /// Retrieves a medication by ID
  @override
  Future<MyMedication?> getMedicationById(int id) async {
    try {
      final Database db = await _databaseHelper.database;

      final maps = await db.query(
        'medications',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return MyMedication.fromMap(maps.first);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting medication by ID: $e');
      }
      return null;
    }
  }

  /// Checks database connection and returns basic information about tables
  /// Useful for debugging database issues
  Future<bool> checkDatabaseConnection() async {
    try {
      final db = await _databaseHelper.database;

      if (kDebugMode) {
        print('Database connection successful');
      }

      // Test query to check if table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      if (kDebugMode) {
        print('Available tables: $tables');
      }

      // Try to fetch medications to verify table structure
      final meds = await db.query('medications');

      if (kDebugMode) {
        print('Found ${meds.length} medications in database');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Database connection error: $e');
      }
      return false;
    }
  }
}
