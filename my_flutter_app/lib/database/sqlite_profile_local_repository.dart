import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../profile_model.dart';
import 'profile_local_repository.dart';
import 'package:medication_management_module/services/database_helper.dart';

class SQLiteProfileLocalRepository implements ProfileLocalRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<int> addProfile(UserProfile profile) async {
    try {
      final Database db = await _databaseHelper.database;
      final id = await db.insert(
        'profiles',
        profile.toMap().cast<String, Object?>(),
      );

      if (kDebugMode) {
        print('Added profile with: $id');
      }

      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding profile: $e');
      }
      rethrow; // Propagate error to caller for handling
    }
  }

  @override
  Future<List<UserProfile>> fetchProfiles() async {
    try {
      final Database db = await _databaseHelper.database;
      final maps = await db.query('profiles');

      if (kDebugMode) {
        print('Retrieved ${maps.length} profiles from database');
      }

      return maps.map((map) => UserProfile.fromMap(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profiles: $e');
      }
      return []; // Return empty list on error to prevent app crashes
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'profiles',
        profile.toMap().cast<String, Object?>(),
        where: 'email = ?',
        whereArgs: [profile.email],
      );

      if (kDebugMode) {
        print('Updated profile with email: ${profile.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
    }
  }

  @override
  Future<void> deleteProfile(UserProfile profile) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'profiles',
        where: 'email = ?',
        whereArgs: [profile.email],
      );

      if (kDebugMode) {
        print('Deleted profile with email: ${profile.email}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile: $e');
      }
    }
  }
}
