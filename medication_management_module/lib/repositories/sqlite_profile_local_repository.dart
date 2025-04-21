import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import 'profile_local_repository.dart';
import 'package:medication_management_module/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SQLiteProfileLocalRepository implements ProfileLocalRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<String> addProfile(UserProfile profile) async {
    try {
      final Database db = await _databaseHelper.database;
      await db.insert('profiles', profile.toMap().cast<String, Object?>());

      if (kDebugMode) {
        print('Added profile with email: ${profile.email}');
      }

      return profile.email; // Return the email directly
    } catch (e) {
      if (kDebugMode) {
        print('Error adding profile: $e');
      }
      rethrow; // Propagate error to caller for handling
    }
  }

  @override
  Future<List<UserProfile>> fetchProfiles({String? email}) async {
    try {
      final Database db = await _databaseHelper.database;
      List<Map<String, Object?>> maps;
      final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
      if (currentUserEmail != null) {
        maps = await db.query(
          'profiles',
          where: 'email = ?',
          whereArgs: [currentUserEmail],
        );

        if (kDebugMode) {
          print('Retrieved profile for current user: $currentUserEmail');
        }
      } else {
        // No email provided and no current user, return empty list
        if (kDebugMode) {
          print('No email provided and no current user, returning empty list');
        }
        return [];
      }

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

      // Check if profile exists first
      final checkResult = await db.query(
        'profiles',
        where: 'email = ?',
        whereArgs: [profile.email],
      );

      if (checkResult.isEmpty) {
        if (kDebugMode) {
          print('Profile does not exist, creating instead of updating');
        }
        await addProfile(profile);
        return;
      }

      // Update profile
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
      rethrow;
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
